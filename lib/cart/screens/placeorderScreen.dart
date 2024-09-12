import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:visioncart/cart/models/item_model.dart';
import 'package:visioncart/cart/screens/orderScreen.dart';

class PlaceOrder extends StatefulWidget {
  final List<Item> cartItems;
  final double grandTotal;

  const PlaceOrder(
      {super.key, required this.cartItems, required this.grandTotal});

  @override
  State<PlaceOrder> createState() => _PlaceOrderState();
}

class _PlaceOrderState extends State<PlaceOrder> {
  String paymentOption = 'Pay at Shop';
  double finalTotal = 0;
  bool isCashOnDelivery = false;
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    finalTotal = widget.grandTotal;
  }

  // Function to handle payment option change
  void _handlePaymentOption(String value) {
    setState(() {
      paymentOption = value;
      isCashOnDelivery = value == 'Cash on Delivery';
      // Add extra charge if "Cash on Delivery" is selected
      finalTotal =
          isCashOnDelivery ? widget.grandTotal + 250 : widget.grandTotal;
    });
  }

  // Function to delete cart items from Firebase after placing the order
  Future<void> _deleteCartItems(String userId) async {
    final cartCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(
            'cart'); // Assuming cart items are stored in a 'cart' subcollection under each user document

    final cartSnapshot = await cartCollection.get();

    // Loop through the cart items and delete each
    for (var doc in cartSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Submit order to Firebase
  Future<void> _submitOrder() async {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    final orderData = {
      'userId': userId,
      'items': widget.cartItems
          .map((item) => {
                'id': item.id,
                'name': item.name,
                'quantity': item.quantity,
                'price': item.price,
              })
          .toList(),
      'total': finalTotal,
      'paymentMethod': paymentOption,
      if (isCashOnDelivery) 'address': addressController.text,
      if (isCashOnDelivery) 'phone': phoneController.text,
      'timestamp': FieldValue.serverTimestamp(), // Store the current timestamp
    };

    try {
      // Add order to Firebase Firestore
      await FirebaseFirestore.instance.collection('orders').add(orderData);

      // Delete the cart items after placing the order
      await _deleteCartItems(userId);

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );

      // Clear local cartItems to reflect changes on the UI
      setState(() {
        widget.cartItems.clear(); // Clear local cart items list
      });

      // Navigate to Orders screen after placing the order
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const Orders(), // Assuming you have the Orders screen setup
        ),
      );
    } catch (e) {
      // Show error message if order placement fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Order'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Display cart items
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle:
                        Text('Quantity: ${item.quantity} | Rs: ${item.price}'),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // Payment Options
            const Text('Select Payment Option:',
                style: TextStyle(fontSize: 18)),
            ListTile(
              title: const Text('Pay at Shop'),
              leading: Radio(
                value: 'Pay at Shop',
                groupValue: paymentOption,
                onChanged: (value) => _handlePaymentOption(value!),
              ),
            ),
            ListTile(
              title: const Text('Cash on Delivery (+ Rs. 250)'),
              leading: Radio(
                value: 'Cash on Delivery',
                groupValue: paymentOption,
                onChanged: (value) => _handlePaymentOption(value!),
              ),
            ),
            // If Cash on Delivery, show address and phone input
            if (isCashOnDelivery) ...[
              const SizedBox(height: 10),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
            ],
            const SizedBox(height: 20),
            // Display Final Total
            Text('Total: Rs ${finalTotal.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // Place Order Button
            ElevatedButton(
              onPressed: _submitOrder,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text('Place Order'),
            ),
          ],
        ),
      ),
    );
  }
}
