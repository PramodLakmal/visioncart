import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:visioncart/Login%20SignUp/Screen/item_model.dart';
import 'package:visioncart/cart/screens/cartScreen.dart';
import 'package:visioncart/cart/models/item_model.dart';
import 'package:visioncart/Login%20SignUp/Services/cartItems.dart';
import 'package:visioncart/cart/screens/checkout.dart';

class ItemCard extends StatelessWidget {
  final String id;
  final String name;
  final String description;
  final double price;
  final double quantity;
  final String imageUrl;

  const ItemCard({
    super.key,
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

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
        backgroundColor: const Color.fromRGBO(33, 150, 243, 1), // Top bar color
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
                borderRadius: BorderRadius.circular(
                    15.0), // Rounded corners for the image
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.image, size: 250),
              ),
              const SizedBox(height: 16),

              // Item name section
              Text(
                name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // Darker font for emphasis
                ),
              ),
              const SizedBox(height: 8),

              // Item description
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(
                      255, 0, 0, 0), // Light color for description
                ),
              ),
              const SizedBox(height: 16),

              // Price and Quantity section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  Text(
                    'Quantity: ${quantity.toInt()}',
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
                    onPressed: () {
                      // Create ItemModel
                      ItemModel itemModel = ItemModel(
                        id: id,
                        name: name,
                        description: description,
                        price: price,
                        quantity: 1,
                        imageUrl: imageUrl,
                      );

                      // Convert ItemModel to Item
                      Item item = convertItemModelToItem(itemModel);

                      // Add item to cart
                      CartDatabase().addToCart(item);

                      // Navigate to the Cart screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Cart()),
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
                            grandTotal:
                                price * quantity, // Pass the grand total
                            buyNowItem: Item(
                              userId: FirebaseAuth.instance.currentUser!.uid,
                              id: id,
                              name: name,
                              description: description,
                              price: price,
                              quantity: 1,
                              image: imageUrl,
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
