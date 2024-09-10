import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:visioncart/cart/models/item_model.dart';

class CartDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to fetch cart items from Firestore
  Future<List<Item>> fetchCartItems() async {
    try {
      // Fetch data from the 'cartItems' collection in Firestore
      QuerySnapshot snapshot = await _firestore.collection('Item').get();

      // Map each document to an Item object and return the list
      return snapshot.docs.map((doc) {
        return Item(
          id: doc.id,
          image: doc['image'],
          name: doc['name'],
          description: doc['description'],
          price: doc['price'].toDouble(), // Convert to double if needed
          quantity: doc['quantity'],
        );
      }).toList();
    } catch (e) {
      // Handle errors by printing the error or returning an empty list
      print('Error fetching cart items: $e');
      return [];
    }
  }

  // Function to update the quantity of an item in Firestore
  Future<void> updateItemQuantity(String id, int newQuantity) async {
    try {
      // Update the quantity field in the Firestore document with the specified ID
      await _firestore.collection('Item').doc(id).update({
        'quantity': newQuantity,
      });
      print('Item quantity updated successfully');
    } catch (e) {
      print('Error updating item quantity: $e');
    }
  }

  // Add a method to delete an item from the cart
  Future<void> deleteItem(String id) async {
    try {
      await _firestore.collection('Item').doc(id).delete();
      print('Item deleted successfully');
    } catch (e) {
      print('Error deleting item: $e');
    }
  }
}
