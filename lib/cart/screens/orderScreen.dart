import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class Orders extends StatefulWidget {
  const Orders({Key? key}) : super(key: key);

  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  late final Stream<QuerySnapshot> _ordersStream;
  double fontSizeMultiplier =
      1.0; // To track the font size multiplier (1x or 2x)

  @override
  void initState() {
    super.initState();
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    _ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // Function to toggle the font size multiplier between 1x and 2x
  void _toggleFontSize() {
    setState(() {
      fontSizeMultiplier = fontSizeMultiplier == 1.0 ? 1.5 : 1.0;
    });
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

  // Function to generate and download the receipt
  Future<void> _downloadReceipt(
      Map<String, dynamic> order, String orderId) async {
    final pdf = pw.Document();
    final orderItems = order['items'] as List<dynamic>;
    final orderTimestamp = order['timestamp'] as Timestamp;
    final total = order['total'];
    final paymentMethod = order['paymentMethod'] as String;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text('Receipt', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            pw.Text('Order ID: $orderId'),
            pw.Text('Payment Method: $paymentMethod'),
            pw.Text('Order Total: Rs $total'),
            pw.SizedBox(height: 20),
            pw.Text('Items:', style: pw.TextStyle(fontSize: 18)),
            pw.ListView.builder(
              itemCount: orderItems.length,
              itemBuilder: (context, index) {
                final item = orderItems[index];
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(item['name']),
                    pw.Text('Quantity: ${item['quantity']}'),
                    pw.Text('Price: Rs ${item['price']}'),
                  ],
                );
              },
            ),
            pw.SizedBox(height: 20),
            pw.Text('Thank you for shopping with us!',
                style: pw.TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );

    // Get the storage directory
    final output = await getTemporaryDirectory();
    final filePath = '${output.path}/receipt_$orderId.pdf';
    final file = File(filePath);

    // Save the PDF file
    await file.writeAsBytes(await pdf.save());

    // Open the PDF file
    OpenFile.open(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'My Orders',
            style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.bold,
                fontSize: 28,
                letterSpacing: 1.2),
          ),
        ),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          // Toggle Button to switch between 1x and 2x font sizes
          TextButton(
            onPressed: _toggleFontSize,
            child: Text(
              fontSizeMultiplier == 1.0 ? '1x' : '2x',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.black87, // Set background color for the entire screen
        child: StreamBuilder<QuerySnapshot>(
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
                final Timestamp orderTimestamp =
                    order['timestamp'] as Timestamp;
                final String paymentMethod = order['paymentMethod'] as String;
                final String status = order['status'] ?? 'pending';

                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text('Order ID: ${orderDoc.id}',
                            style: TextStyle(
                                fontSize: 16 * fontSizeMultiplier,
                                fontWeight: FontWeight.bold)),
                        Text(
                          'Order Total: Rs ${order['total']}',
                          style: TextStyle(
                            fontSize: 16 * fontSizeMultiplier,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text('Payment Method: $paymentMethod',
                            style:
                                TextStyle(fontSize: 14 * fontSizeMultiplier)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text('Item Name',
                                  style: TextStyle(
                                      fontSize: 14 * fontSizeMultiplier)),
                            ),
                            Expanded(
                              child: Text('Quantity',
                                  style: TextStyle(
                                      fontSize: 14 * fontSizeMultiplier)),
                            ),
                            Expanded(
                              child: Text('Unit Price',
                                  style: TextStyle(
                                      fontSize: 14 * fontSizeMultiplier)),
                            ),
                            Expanded(
                              child: Text('Amount',
                                  style: TextStyle(
                                      fontSize: 14 * fontSizeMultiplier)),
                            ),
                          ],
                        ),
                        const Divider(height: 10),
                        ...items.map(
                          (item) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item['name'],
                                  style: TextStyle(
                                      fontSize: 14 * fontSizeMultiplier),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${item['quantity']}',
                                  style: TextStyle(
                                      fontSize: 14 * fontSizeMultiplier),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Rs ${item['price']}',
                                  style: TextStyle(
                                      fontSize: 14 * fontSizeMultiplier),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Rs ${item['price'] * item['quantity']}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 14 * fontSizeMultiplier),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 10),
                        Text(
                          'Order Placed: ${DateFormat.yMMMd().add_jm().format(orderTimestamp.toDate())}',
                          style: TextStyle(fontSize: 14 * fontSizeMultiplier),
                        ),
                        const SizedBox(height: 10),
                        if (status == 'packed') ...[
                          if (paymentMethod == 'Cash on Delivery')
                            Text(
                              'Order is on the way',
                              style: TextStyle(
                                  fontSize: 14 * fontSizeMultiplier,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            )
                          else
                            Text(
                              'Pick your order at the shop',
                              style: TextStyle(
                                  fontSize: 14 * fontSizeMultiplier,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                        ],
                        const SizedBox(height: 10),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white),
                            onPressed: () =>
                                _downloadReceipt(order, orderDoc.id),
                            child: Text('Download Receipt',
                                style: TextStyle(
                                    fontSize: 14 * fontSizeMultiplier)),
                          ),
                        ),
                        if (_canCancelOrder(orderTimestamp))
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white),
                              onPressed: () =>
                                  _cancelOrder(context, orderDoc.id),
                              child: Text(
                                'Cancel Order',
                                style: TextStyle(
                                    fontSize: 14 * fontSizeMultiplier,
                                    color: Colors.white),
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
      ),
    );
  }
}
