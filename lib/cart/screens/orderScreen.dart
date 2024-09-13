import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  late final Stream<QuerySnapshot> _ordersStream;

  @override
  void initState() {
    super.initState();
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    _ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // Function to delete an order from Firestore
  Future<void> _cancelOrder(BuildContext context, String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order cancelled successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cancelling order: $e')),
      );
    }
  }

  // Check if the order can be cancelled (within 2 minutes)
  bool _canCancelOrder(Timestamp orderTimestamp) {
    final DateTime orderTime = orderTimestamp.toDate();
    final DateTime currentTime = DateTime.now();
    return currentTime.difference(orderTime).inMinutes <= 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _ordersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderDoc = orders[index];
              final order = orderDoc.data() as Map<String, dynamic>;
              final items = order['items'] as List<dynamic>;
              final Timestamp orderTimestamp = order['timestamp'] as Timestamp;
              final String paymentMethod = order['paymentMethod'] as String;
              final String status = order['status'] ?? 'pending';

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main Title
                      Text(
                        'Your Order',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Order Total
                      Text(
                        'Order Total: Rs ${order['total']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Payment Method
                      Text('Payment Method: $paymentMethod'),
                      const SizedBox(height: 10),

                      // Table Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Expanded(child: Text('Item Name')),
                          Expanded(child: Text('Quantity')),
                          Expanded(child: Text('Unit Price')),
                          Expanded(child: Text('Amount')),
                        ],
                      ),
                      const Divider(height: 10),

                      // Order Items
                      ...items.map(
                        (item) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(item['name'])),
                            Expanded(child: Text('${item['quantity']}')),
                            Expanded(child: Text('Rs ${item['price']}')),
                            Expanded(
                              child: Text(
                                'Rs ${item['price'] * item['quantity']}',
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 10),

                      // Order Placed
                      Text(
                        'Order Placed: ${DateFormat.yMMMd().add_jm().format(orderTimestamp.toDate())}',
                      ),
                      const SizedBox(height: 10),
                      // Show a message based on the order status
                      if (status == 'packed') ...[
                        if (paymentMethod == 'Cash on Delivery')
                          const Text(
                            'Order is on the way',
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          )
                        else
                          const Text(
                            'Pick your order at the shop',
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                      ],
                      const SizedBox(height: 10),
                      // Show Delete or Confirmed based on time since order was placed
                      if (_canCancelOrder(orderTimestamp))
                        ElevatedButton(
                          onPressed: () => _cancelOrder(context, orderDoc.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Cancel Order'),
                        )
                      else
                        const Text(
                          'Confirmed',
                          style: TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        ),

                      const SizedBox(height: 10),

                      // Quote
                      const Center(
                        child: Text(
                          'Thank you for shopping with us!',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
