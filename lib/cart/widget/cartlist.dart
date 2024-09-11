import 'package:flutter/material.dart';
import 'package:visioncart/cart/models/item_model.dart';
import 'package:visioncart/cart/widget/item_tile.dart';

class CartList extends StatelessWidget {
  const CartList({
    super.key,
    required this.cart,
    required this.onQuantityChanged,
    required this.onDelete,
  });

  final List<Item> cart;
  final Function(int index, int newQuantity) onQuantityChanged;
  final Function(int index) onDelete;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: cart.length,
        itemBuilder: (context, index) {
          return ItemTile(
            singleItem: cart[index],
            onQuantityChanged: (newQuantity) => onQuantityChanged(index, newQuantity),
            onDelete: () => onDelete(index),
          );
        },
      ),
    );
  }
}
