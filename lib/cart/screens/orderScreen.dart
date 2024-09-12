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

  // Function to delete an order
  Future<void> _cancelOrder(String orderId) async {
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

  // Function to check if 30 minutes have passed since the order was placed
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
              final Timestamp orderTimestamp = order['timestamp']
                  as Timestamp; // Assuming order has 'timestamp'

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Order Total: Rs ${order['total']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payment Method: ${order['paymentMethod']}'),
                      ...items.map(
                        (item) => Text(
                          '${item['name']} - Quantity: ${item['quantity']} - Price: Rs ${item['price']}',
                        ),
                      ),
                      if (order['paymentMethod'] == 'Cash on Delivery') ...[
                        Text('Address: ${order['address']}'),
                        Text('Phone: ${order['phone']}'),
                      ],
                      Text(
                          'Order Placed: ${DateFormat.yMMMd().add_jm().format(orderTimestamp.toDate())}'),
                      const SizedBox(height: 10),
                      // Check if the order can be cancelled
                      if (_canCancelOrder(orderTimestamp))
                        ElevatedButton(
                          onPressed: () => _cancelOrder(orderDoc.id),
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
