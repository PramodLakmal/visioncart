import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:visioncart/items/models/item_model.dart';
import 'package:visioncart/cart/screens/cartScreen.dart';
import 'package:visioncart/cart/models/item_model.dart';
import 'package:visioncart/Login%20SignUp/Services/cartItems.dart';
import 'package:visioncart/cart/screens/checkout.dart';

class ItemCard extends StatefulWidget {
  final String id;
  final String name;
  final String description;
  final double price;
  final double initialQuantity; // Renamed to distinguish from local state
  final String imageUrl;
  final Function(double) onQuantityChanged; // Add this line

  const ItemCard({
    super.key,
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.initialQuantity,
    required this.imageUrl,
    required this.onQuantityChanged, // Add this line
  });

  @override
  _ItemCardState createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  late double _quantity; // State variable for quantity

  @override
  void initState() {
    super.initState();
    // Initialize the quantity state with the initial quantity
    _quantity = widget.initialQuantity;
  }

  // Method to convert ItemModel to Item
  Item convertItemModelToItem(ItemModel itemModel) {
    return Item(
      userId: FirebaseAuth.instance.currentUser!.uid,
      id: itemModel.id ?? 'default_id',
      image: itemModel.imageUrl ?? 'default_image_url',
      name: itemModel.name ?? 'Unnamed Item',
      description: itemModel.description ?? 'No description available',
      price: itemModel.price ?? 0.0,
      quantity: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        backgroundColor: const Color.fromRGBO(33, 150, 243, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: widget.imageUrl.isNotEmpty
                    ? Image.network(
                        widget.imageUrl,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.image, size: 250),
              ),
              const SizedBox(height: 16),

              // Item name section
              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Item description
              Text(
                widget.description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 16),

              // Price and Quantity section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${widget.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  Text(
                    'Quantity: ${_quantity.toInt()}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Bottom action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _quantity > 0
                        ? () async {
                            // Make the callback asynchronous
                            if (_quantity > 0) {
                              // Ensure there's quantity to add
                              // Create ItemModel
                              ItemModel itemModel = ItemModel(
                                id: widget.id,
                                name: widget.name,
                                description: widget.description,
                                price: widget.price,
                                quantity: _quantity,
                                imageUrl: widget.imageUrl,
                              );

                              // Convert ItemModel to Item
                              Item item = convertItemModelToItem(itemModel);

                              // Add item to cart and await the operation
                              await CartDatabase().addToCart(item);

                              // Decrease the quantity
                              setState(() {
                                _quantity--;
                                widget.onQuantityChanged(
                                    _quantity); // Call the callback here
                              });

                              // Navigate to the cart screen after the item is successfully added
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Cart()),
                              );
                            }
                          }
                        : null, // Disable button when quantity is 0
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 62, 60, 64),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Pass item details directly to the Checkout screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Checkout(
                            grandTotal: widget.price * _quantity,
                            buyNowItem: Item(
                              userId: FirebaseAuth.instance.currentUser!.uid,
                              id: widget.id,
                              name: widget.name,
                              description: widget.description,
                              price: widget.price,
                              quantity: 1,
                              image: widget.imageUrl,
                            ),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 62, 60, 64),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      'Buy Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
