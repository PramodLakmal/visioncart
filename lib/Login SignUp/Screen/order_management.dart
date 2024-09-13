import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderManagement extends StatelessWidget {
  const OrderManagement({super.key});

  // Function to handle order packed action and update Firestore
  Future<void> _handleOrderPacked(
      BuildContext context, String orderId, String paymentMethod) async {
    // Update order status to 'packed' in Firestore
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': 'packed',
    });

    // Show a message based on the payment method
    if (paymentMethod == 'Cash on Delivery') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order is on the way')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick your order at the shop')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(child: Text('No orders available'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderDoc = orders[index];
              final order = orderDoc.data() as Map<String, dynamic>;
              final orderItems = order['items'] as List<dynamic>;
              final total = order['total'] as double;
              final paymentMethod = order['paymentMethod'] as String;
              final status = order['status'] ?? 'pending'; // Order status

              // Check if there's a contact and address for COD orders
              final phone = order['phone'] as String?;
              final address = order['address'] as String?;

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order ID and Customer Information
                      Text('Order ID: ${orderDoc.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),

                      if (phone != null) Text('Customer Contact: $phone'),
                      if (address != null) Text('Customer Address: $address'),

                      const Divider(),
                      const SizedBox(height: 10),

                      // Table Header (Without Borders)
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(3), // Item name takes more space
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(1),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                            ),
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Item Name',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left, // Corrected
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Quantity',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left, // Corrected
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Unit Price',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left, // Corrected
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Amount',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left, // Corrected
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Table Rows for each order item (Without Borders)
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(3), // Item name takes more space
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(1),
                        },
                        children: orderItems.map((item) {
                          final itemName = item['name'] ?? 'Unknown';
                          final quantity = item['quantity'] ?? 0;
                          final unitPrice = item['price'] ?? 0.0;
                          final totalAmount = unitPrice * quantity;

                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child:
                                    Text(itemName, textAlign: TextAlign.left),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(quantity.toString(),
                                    textAlign: TextAlign.left),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Rs $unitPrice',
                                    textAlign: TextAlign.left),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Rs $totalAmount',
                                    textAlign: TextAlign.left),
                              ),
                            ],
                          );
                        }).toList(),
                      ),

                      const Divider(),

                      // Total Amount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount:',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Rs $total',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Order Status
                      if (status == 'packed')
                        const Center(
                          child: Text(
                            'Order Completed',
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        )
                      else
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              _handleOrderPacked(
                                  context, orderDoc.id, paymentMethod);
                            },
                            child: const Text('Order Packed'),
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
