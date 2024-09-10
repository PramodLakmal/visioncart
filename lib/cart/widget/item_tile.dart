import 'package:flutter/material.dart';
import 'package:visioncart/cart/models/item_model.dart';

class tile extends StatefulWidget {
  const tile(
      {super.key,
      required this.singleItem,
      required this.onQuantityChanged,
      required this.onDelete});

  final Item singleItem;
  final Function(int newQuantity) onQuantityChanged;
  final Function() onDelete;

  @override
  State<tile> createState() => _tileState();
}

class _tileState extends State<tile> {
  late int _quantity;
  late double total;

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
                Image.network(
                  widget.singleItem.image,
                  width: 100,
                  height: 100,
                ),
                const Spacer(),
              ],
            ),
            Row(
              children: [
                Row(
                  children: [
                    Text(
                      widget.singleItem.name,
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  'Rs: ${widget.singleItem.price}',
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Card(
              child: Row(
                children: [
                  Text(
                    widget.singleItem.description,
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
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
                const SizedBox(
                  width: 10,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    widget.onDelete();
                  },
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
