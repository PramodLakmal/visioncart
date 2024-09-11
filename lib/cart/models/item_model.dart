class Item {
  final String id;
  final String image;
  final String name;
  final String description;
  final double price;
  int quantity;
  final String userId; // Add userId to track which user added the item

  Item({
    required this.id,
    required this.image,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.userId, // userId is required
  });

  // Convert Item object to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'userId': userId, // Include userId when adding to Firestore
    };
  }

  // Create Item from Firestore document
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      image: map['image'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      quantity: 1,
      userId: map['userId'], // Retrieve userId from Firestore
    );
  }
}
