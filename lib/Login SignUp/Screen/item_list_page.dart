import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'item_card.dart'; // Assuming you have this file created for detailed view

class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  _ItemListPageState createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  final CollectionReference itemsCollection =
      FirebaseFirestore.instance.collection('items');
  List<DocumentSnapshot> allItems = []; // List to hold all items
  List<DocumentSnapshot> filteredItems = []; // List to hold filtered items

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  // Fetch items from Firestore
  Future<void> _fetchItems() async {
    QuerySnapshot snapshot = await itemsCollection.get();
    setState(() {
      allItems = snapshot.docs;
      filteredItems = allItems; // Initially display all items
    });
  }

  // Filter items based on search query
  void _filterItems(String query) {
    setState(() {
      filteredItems = allItems
          .where((item) => (item.data() as Map<String, dynamic>)['name']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: ItemSearch(allItems));
            },
          ),
        ],
      ),
      body: filteredItems.isEmpty
          ? const Center(
              child: Text('No items found', style: TextStyle(fontSize: 20)),
            )
          : ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                var itemData =
                    filteredItems[index].data() as Map<String, dynamic>;
                String id = filteredItems[index].id;
                String name = itemData['name'] ?? 'Unnamed Item';
                String description = itemData['description'] ?? 'No description';
                double price = itemData['price']?.toDouble() ?? 0.0;
                double quantity = itemData['quantity']?.toDouble() ?? 0.0;
                String imageUrl = itemData['imageUrl'] ?? '';

                return ListTile(
                  leading: imageUrl.isNotEmpty
                      ? Image.network(imageUrl, width: 50, height: 50)
                      : const Icon(Icons.image, size: 50),
                  title: Text(name),
                  subtitle: Text('Price: \$$price, Quantity: $quantity'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemCard(
                          id: id,
                          name: name,
                          description: description,
                          price: price,
                          quantity: quantity,
                          imageUrl: imageUrl,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

// Search Delegate for searching items
class ItemSearch extends SearchDelegate<String> {
  final List<DocumentSnapshot> items;

  ItemSearch(this.items);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, ''); // Use an empty string or some default value
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = items
        .where((item) => (item.data() as Map<String, dynamic>)['name']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        var itemData = results[index].data() as Map<String, dynamic>;
        String id = results[index].id;
        String name = itemData['name'] ?? 'Unnamed Item';
        String description = itemData['description'] ?? 'No description';
        double price = itemData['price']?.toDouble() ?? 0.0;
        double quantity = itemData['quantity']?.toDouble() ?? 0.0;
        String imageUrl = itemData['imageUrl'] ?? '';

        return ListTile(
          leading: imageUrl.isNotEmpty
              ? Image.network(imageUrl, width: 50, height: 50)
              : const Icon(Icons.image, size: 50),
          title: Text(name),
          subtitle: Text('Price: \$$price, Quantity: $quantity'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemCard(
                  id: id,
                  name: name,
                  description: description,
                  price: price,
                  quantity: quantity,
                  imageUrl: imageUrl,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = items
        .where((item) => (item.data() as Map<String, dynamic>)['name']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        var itemData = suggestions[index].data() as Map<String, dynamic>;
        String name = itemData['name'] ?? 'Unnamed Item';

        return ListTile(
          title: Text(name),
          onTap: () {
            query = name;
            showResults(context);
          },
        );
      },
    );
  }
}
