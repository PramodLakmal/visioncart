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
    _quantity = widget.singleItem.quantity;
  }

  void _increaseQuantity() {
    setState(() {
      _quantity++;
    });
    widget.onQuantityChanged(_quantity);
  }

  void _decreaseQuantity() {
    setState(() {
      if (_quantity > 0) {
        _quantity--;
      }
    });
    widget.onQuantityChanged(_quantity);
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
                SizedBox(
                  width: 300,
                  child: Image.network(
                    widget.singleItem.image,
                    width: 100,
                    height: 100,
                  ),
                ),
                const Spacer(),
              ],
            ),
            Row(
              children: [
                Text(
                  widget.singleItem.name,
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  'Rs: ${widget.singleItem.price}',
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.bold),
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
                        fontSize: 10, fontWeight: FontWeight.bold),
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
                  onTap: widget.onDelete,
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
