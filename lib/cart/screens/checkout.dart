import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:visioncart/cart/models/item_model.dart';
import 'package:visioncart/Login%20SignUp/Services/cartItems.dart';
import 'package:visioncart/cart/screens/placeorderScreen.dart'; // CartDatabase for fetching items

class Checkout extends StatefulWidget {
  final double grandTotal;
  const Checkout({super.key, required this.grandTotal});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  late Future<List<Item>> _cartItemsFuture;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  // Calculate grand total

  @override
  void initState() {
    super.initState();
    _cartItemsFuture =
        CartDatabase().fetchCartItems(userId); // Fetch cart items using user ID
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.blue,
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
              Container(
                color: Colors.blue,
                height: 150,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                           Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceOrder(
          cartItems: cartItems,
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
              ),
            ],
          );
        },
      ),
    );
  }
}
