
class Item {
  final String id;
  final String image;
  final String name;
  final String description;
  final String userId;

  final double price;
  late int quantity;

  Item({
    required this.id,
    required this.image,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.userId,
  });
}
