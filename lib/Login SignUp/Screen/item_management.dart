import 'package:flutter/material.dart';

class ItemManagement extends StatelessWidget {
  const ItemManagement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Management'),
      ),
      body: const Center(
        child: Text('Item Management Screen'),
      ),
    );
  }
}
