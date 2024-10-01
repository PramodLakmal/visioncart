import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:visioncart/cart/models/item_model.dart';

class ItemTile extends StatefulWidget {
  const ItemTile({
    super.key,
    required this.singleItem,
    required this.onQuantityChanged,
    required this.onDelete,
  });

  final Item singleItem;
  final Function(int newQuantity) onQuantityChanged;
  final Function() onDelete;

  @override
  State<ItemTile> createState() => _ItemTileState();
}

class _ItemTileState extends State<ItemTile> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity =
        widget.singleItem.quantity; // Initialize with the current quantity
  }

  // Function to update quantity in Firestore for the item
  Future<void> _updateQuantityInItemsCollection(int quantityChange) async {
    try {
      await FirebaseFirestore.instance
          .collection('items') // Assuming the collection is 'items'
          .doc(widget.singleItem.id) // Reference the document by the item ID
          .update({
        'quantity': FieldValue.increment(
            quantityChange), // Increment or decrement the quantity
      });
      print('Quantity updated in items collection');
    } catch (e) {
      print('Failed to update quantity: $e');
    }
  }

  // Function to update quantity in Firestore when deleting the item
  Future<void> _deleteItem() async {
    try {
      await widget.onDelete(); // Call the delete function from parent widget
      await _updateQuantityInItemsCollection(
          _quantity); // Add back the quantity
      print('Item deleted and quantity updated in items collection');
    } catch (e) {
      print('Failed to delete item: $e');
    }
  }

  void _increaseQuantity() {
    setState(() {
      _quantity++;
    });
    widget.onQuantityChanged(
        _quantity); // Notify parent widget of quantity change
    _updateQuantityInItemsCollection(-1); // Decrement the quantity in Firestore
  }

  void _decreaseQuantity() {
    if (_quantity > 0) {
      setState(() {
        _quantity--;
      });
      widget.onQuantityChanged(
          _quantity); // Notify parent widget of quantity change
      _updateQuantityInItemsCollection(
          1); // Increment the quantity in Firestore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Image(
                    image: NetworkImage(widget.singleItem.image),
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  widget.singleItem.name,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'Rs: ${widget.singleItem.price}',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 300,
                  child: Text(
                    widget.singleItem.description,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _increaseQuantity,
                  child: const Icon(Icons.add),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    '$_quantity',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                ElevatedButton(
                  onPressed: _decreaseQuantity,
                  child: const Icon(Icons.remove),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _deleteItem, // Call the delete item function
                  child: const Icon(Icons.delete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
