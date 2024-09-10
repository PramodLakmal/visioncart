import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:visioncart/Login%20SignUp/Services/cartItems.dart';
import 'package:visioncart/cart/models/item_model.dart';
import 'package:visioncart/cart/widget/cartlist.dart';
// Import your database class

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  late Future<List<Item>> _cartItemsFuture;

  bool isAddbutton = true;

  @override
  void initState() {
    super.initState();
    _cartItemsFuture =
        CartDatabase().fetchCartItems(); // Fetch data from Firestore
  }

  // Method to calculate grand total
  double getGrandTotal(List<Item> cartItems) {
    double total = 0;
    for (var item in cartItems) {
      total += item.price * item.quantity;
    }
    return total;
  }

  // Function to update the quantity when it's increased or decreased
  void _updateQuantity(int index, int newQuantity, List<Item> cartItems) {
    setState(() {
      cartItems[index].quantity = newQuantity;

      CartDatabase().updateItemQuantity(cartItems[index].id, newQuantity);
    });
  }

  // Function to delete an item from the cart and Firestore
  void _deleteItem(int index, List<Item> cartItems) {
    setState(() {
      // Remove the item from the local list
      String itemId = cartItems[index].id;
      cartItems.removeAt(index);

      // Also delete the item from Firestore
      CartDatabase().deleteItem(itemId);
    });
  }

  //Functon to toggle the add button

  void _toggleAddButton() {
    setState(() {
      isAddbutton = !isAddbutton;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<List<Item>>(
          future: _cartItemsFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text('Cart (0 items) ');
            }

            List<Item> cartItems = snapshot.data!;
            double grandTotal = getGrandTotal(cartItems);

            return Text('Cart (${cartItems.length} items) ');
          },
        ),
        backgroundColor: Colors.blue,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextButton(
              child: isAddbutton
                  ? const Text(
                      '1x',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    )
                  : const Text('2x',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
              onPressed: () {
                _toggleAddButton();
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Item>>(
        future: _cartItemsFuture, // Future to get the cart items
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Item> cartItems = snapshot.data!;

          return Column(
            children: [
              cartList(
                cart: cartItems,
                onQuantityChanged: (index, newQuantity) {
                  _updateQuantity(index, newQuantity, cartItems);
                },
                onDelete: (index) {
                  _deleteItem(index, cartItems);
                },
              ),
              Container(
                height: 150,
                color: Colors.blue,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(200, 60), // Width, Height
                          ),
                          onPressed: () {
                            // Place the order
                          },
                          child: const Text('Checkout',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold))),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Text(
                            'Total: \$${getGrandTotal(cartItems).toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}