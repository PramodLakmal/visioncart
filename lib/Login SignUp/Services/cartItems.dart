import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:visioncart/cart/models/item_model.dart';

class CartDatabase {
  final CollectionReference cartItemsCollection = FirebaseFirestore.instance.collection('cartItems');

  // Add item to cart for the logged-in user
  Future<void> addToCart(Item item) async {
    await cartItemsCollection.doc(item.id).set(item.toMap()); // Store the item with the userId
  }

  // Fetch cart items for the logged-in user
  Future<List<Item>> fetchCartItems(String userId) async {
    QuerySnapshot snapshot = await cartItemsCollection
        .where('userId', isEqualTo: userId) // Query only items for the logged-in user
        .get();

    return snapshot.docs.map((doc) {
      return Item.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  // Update item quantity for the logged-in user
  Future<void> updateItemQuantity(String itemId, int newQuantity) async {
    await cartItemsCollection.doc(itemId).update({'quantity': newQuantity});
  }

  // Delete item from cart for the logged-in user
  Future<void> deleteItem(String itemId) async {
    await cartItemsCollection.doc(itemId).delete();
  }
}
