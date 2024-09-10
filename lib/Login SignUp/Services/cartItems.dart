import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:visioncart/cart/models/item_model.dart';

class CartDatabase {
  final CollectionReference cartsCollection =
      FirebaseFirestore.instance.collection('Carts');

  // Add item to cart
  Future<void> addToCart(Item item) async {
    final userCart = cartsCollection
        .doc(item.userId)
        .collection('userCart'); // Replace 'user_id' with logged-in user's ID

    await userCart.doc(item.id).set({
      'id': item.id,
      'name': item.name,
      'description': item.description,
      'price': item.price,
      'quantity': 1,
      'image': item.image,
    });
  }

  // Fetch cart items (you can customize this further if needed)
  Future<List<Item>> fetchCartItems(String userId) async {
    final userCart = cartsCollection.doc(userId).collection('userCart');
    QuerySnapshot snapshot = await userCart.get();
    return snapshot.docs.map((doc) {
      return Item(
        userId: userId,
        id: doc['id'],
        image: doc['image'],
        name: doc['name'],
        description: doc['description'],
        price: doc['price'],
        quantity: doc['quantity'],
      );
    }).toList();
  }

  // Update item quantity
  Future<void> updateItemQuantity(
      String itemId, int newQuantity, String userId) async {
    final userCart = cartsCollection
        .doc(userId)
        .collection('userCart'); // Replace 'user_id' with logged-in user's ID
    await userCart.doc(itemId).update({'quantity': newQuantity});
  }

  // Delete item from cart
  Future<void> deleteItem(String itemId, String userId) async {
    final userCart = cartsCollection
        .doc('user_id')
        .collection('userCart'); // Replace 'user_id' with logged-in user's ID
    await userCart.doc(itemId).delete();
  }
}
