import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:visioncart/cart/models/item_model.dart';

class CartDatabase {
  final CollectionReference cartItemsCollection =
      FirebaseFirestore.instance.collection('cartItems');

  // Add item to cart for the logged-in user
  Future<void> addToCart(Item item) async {
    // Use a composite key like userId + itemId to make the document ID unique for each user
    String documentId = '${item.userId}_${item.id}';

    // Check if the document already exists
    DocumentSnapshot docSnapshot =
        await cartItemsCollection.doc(documentId).get();

    if (docSnapshot.exists) {
      // If the item already exists, increment the quantity
      await cartItemsCollection.doc(documentId).update({
        'quantity': FieldValue.increment(1),
      });
    } else {
      // If the item does not exist, add it with default quantity of 1
      await cartItemsCollection.doc(documentId).set(item.toMap());
    }
  }

  // Fetch cart items for the logged-in user
  Future<List<Item>> fetchCartItems(String userId) async {
    QuerySnapshot snapshot = await cartItemsCollection
        .where('userId',
            isEqualTo: userId) // Query only items for the logged-in user
        .get();

    return snapshot.docs.map((doc) {
      return Item.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  // Update item quantity for the logged-in user
  Future<void> updateItemQuantity(
      String itemId, String userId, int newQuantity) async {
    String documentId = '${userId}_$itemId';
    await cartItemsCollection.doc(documentId).update({'quantity': newQuantity});
  }

  // Delete item from cart for the logged-in user
  Future<void> deleteItem(String itemId, String userId) async {
    String documentId = '${userId}_$itemId';
    await cartItemsCollection.doc(documentId).delete();
  }

  // Deduct item quantity for the logged-in user
  Future<void> deductItemQuantity(
      String itemId, String userId, int quantityToDeduct) async {
    String documentId = '${userId}_$itemId';

    // Run a transaction to ensure safe updates
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the current item document
      DocumentReference itemRef = cartItemsCollection.doc(documentId);
      DocumentSnapshot snapshot = await transaction.get(itemRef);

      if (!snapshot.exists) {
        throw Exception("Item does not exist in the cart!");
      }

      // Get the current quantity
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      int currentQuantity = data['quantity'];

      // Calculate the new quantity
      int newQuantity = currentQuantity - quantityToDeduct;

      // Ensure the quantity does not go below zero
      if (newQuantity < 0) {
        throw Exception("Insufficient quantity in cart!");
      }

      // Update the quantity in Firestore
      transaction.update(itemRef, {'quantity': newQuantity});

      // Optionally remove the item from the cart if quantity becomes zero
      if (newQuantity == 0) {
        transaction.delete(itemRef);
      }
    });
  }
}
