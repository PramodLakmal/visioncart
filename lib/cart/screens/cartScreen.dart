import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:visioncart/Login%20SignUp/Services/cartItems.dart';
import 'package:visioncart/cart/models/item_model.dart';
import 'package:visioncart/cart/screens/checkout.dart';
import 'package:visioncart/cart/widget/cartlist.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  late Future<List<Item>> _cartItemsFuture;
  final String userId =
      FirebaseAuth.instance.currentUser!.uid; // Get logged-in user's ID

  @override
  void initState() {
    super.initState();
    _cartItemsFuture = CartDatabase()
        .fetchCartItems(userId); // Fetch items for the current user
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
      CartDatabase()
          .updateItemQuantity(cartItems[index].id, userId, newQuantity);
    });
  }

  // Function to delete an item from the cart
  void _deleteItem(int index, List<Item> cartItems) {
    setState(() {
      String itemId = cartItems[index].id;
      cartItems.removeAt(index);
      CartDatabase().deleteItem(itemId, userId);
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
              return const Text('Cart (0 items)');
            }

            List<Item> cartItems = snapshot.data!;
            return Text('Cart (${cartItems.length} items)');
          },
        ),
      ),
      body: FutureBuilder<List<Item>>(
        future: _cartItemsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Item> cartItems = snapshot.data!;

          return Column(
            children: [
              CartList(
                cart: cartItems,
                onQuantityChanged: (index, newQuantity) {
                  _updateQuantity(index, newQuantity, cartItems);
                },
                onDelete: (index) {
                  _deleteItem(index, cartItems);
                },
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 60),
                          backgroundColor:
                              Colors.blue, // Background color of the button
                          // Text color
                        ),
                        onPressed: () {
                          double grandTotal =
                              getGrandTotal(cartItems); // Get the total amount
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Checkout(grandTotal: grandTotal),
                            ),
                          );
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
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
