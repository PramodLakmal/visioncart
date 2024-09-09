import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageUrl.isNotEmpty
                ? Image.network(imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover)
                : const Icon(Icons.image, size: 200),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Price: \$$price', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Quantity: $quantity', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
