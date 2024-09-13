import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:visioncart/cart/models/item_model.dart';
import 'package:visioncart/Login%20SignUp/Services/cartItems.dart';
import 'package:visioncart/cart/screens/placeorderScreen.dart'; // CartDatabase for fetching items

class Checkout extends StatefulWidget {
  final double grandTotal;
  final Item? buyNowItem; // The item from "Buy Now" button (optional)

  const Checkout({
    super.key,
    required this.grandTotal,
    this.buyNowItem, // Optional item passed from "Buy Now"
  });

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  late Future<List<Item>> _cartItemsFuture;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();

    // Only fetch cart items if coming from the cart, not from "Buy Now"
    if (widget.buyNowItem == null) {
      _cartItemsFuture = CartDatabase().fetchCartItems(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.blue,
      ),
      body: widget.buyNowItem != null
          ? _buildBuyNowItem() // Build the checkout page for Buy Now item
          : _buildCartItems(), // Build the checkout page for cart items
    );
  }

  // Build checkout page when coming from "Buy Now"
  Widget _buildBuyNowItem() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.buyNowItem!.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          'Rs: ${widget.buyNowItem!.price}',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Quantity: ${widget.buyNowItem!.quantity}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        _buildFooter(cartItems: [
          widget.buyNowItem!
        ]), // The footer with the total and place order button
      ],
    );
  }

  // Build checkout page when coming from the cart
  Widget _buildCartItems() {
    return FutureBuilder<List<Item>>(
      future: _cartItemsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Item> cartItems = snapshot.data!;

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 40),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  cartItems[index].name,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                Text(
                                  'Rs: ${cartItems[index].price}',
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Quantity: ${cartItems[index].quantity}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            _buildFooter(
                cartItems:
                    cartItems), // The footer with the total and place order button
          ],
        );
      },
    );
  }

  // Footer section for both "Buy Now" and cart items
  Widget _buildFooter({required List<Item> cartItems}) {
    return Container(
      color: Colors.blue,
      height: 150,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60),
        child: Row(
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to place order screen with either Buy Now item or cart items
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlaceOrder(
                      cartItems: cartItems, // Pass the cart or Buy Now items
                      grandTotal: widget.grandTotal,
                    ),
                  ),
                );
              },
              child: const Text('Place Order'),
            ),
            const Spacer(),
            Text(
              ' Total: Rs ${widget.grandTotal}',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
