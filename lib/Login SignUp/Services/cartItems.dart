import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:visioncart/cart/models/item_model.dart';

class CartDatabase {
  final CollectionReference cartItemsCollection =
      FirebaseFirestore.instance.collection('cartItems');

  // Add item to cart for the logged-in user
  Future<void> addToCart(Item item) async {
    // Use a composite key like userId + itemId to make the document ID unique for each user
    String documentId = '${item.userId}_${item.id}';
    await cartItemsCollection.doc(documentId).set(item.toMap());
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
}
