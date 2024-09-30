import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'item_card.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  _ItemListPageState createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  final CollectionReference itemsCollection =
      FirebaseFirestore.instance.collection('items');
  List<DocumentSnapshot> allItems = [];
  List<DocumentSnapshot> filteredItems = [];
  TextEditingController searchController = TextEditingController();
  String _searchQuery = '';

  final Color lightBlue = const Color.fromRGBO(33, 150, 243, 1);

  @override
  void initState() {
    super.initState();
    _fetchItems();
    searchController.addListener(() {
      setState(() {
        _searchQuery = searchController.text.toLowerCase();
        _filterItems(_searchQuery);
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchItems() async {
    QuerySnapshot snapshot = await itemsCollection.get();
    setState(() {
      allItems = snapshot.docs;
      filteredItems = allItems;
    });
  }

  void _filterItems(String query) {
    List<DocumentSnapshot> results = [];
    if (query.isEmpty) {
      results = allItems;
    } else {
      results = allItems.where((item) {
        var itemName = (item.data() as Map<String, dynamic>)['name']?.toString().toLowerCase() ?? '';
        return itemName.contains(query.toLowerCase());
      }).toList();
    }

    setState(() {
      filteredItems = results;
    });
  }

  Future<void> _updateItemQuantity(String id, double newQuantity) async {
    // Update the quantity in Firestore
    await itemsCollection.doc(id).update({'quantity': newQuantity});
    // Refetch the items to get updated data
    await _fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item List'),
        backgroundColor: lightBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: Icon(Icons.search, color: lightBlue),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: lightBlue),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[200],
        child: filteredItems.isEmpty
            ? const Center(
                child: Text('No items found', style: TextStyle(fontSize: 20)),
              )
            : ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  var itemData = filteredItems[index].data() as Map<String, dynamic>?; // Use nullable type
                  String id = filteredItems[index].id;
                  String name = itemData?['name'] ?? 'Unnamed Item'; // Null check
                  String description = itemData?['description'] ?? 'No description'; // Null check
                  double price = itemData?['price']?.toDouble() ?? 0.0; // Null check
                  double quantity = itemData?['quantity']?.toDouble() ?? 0.0; // Null check
                  String imageUrl = itemData?['imageUrl'] ?? ''; // Null check

                  return Card(
                    color: Colors.white,
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8.0),
                        leading: imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(imageUrl,
                                    width: 80, height: 80, fit: BoxFit.cover),
                              )
                            : const Icon(Icons.image, size: 50),
                        title: Text(
                          name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        subtitle: Text(
                          'Total Sales(Qty) - ${quantity.toInt()}',
                          style: const TextStyle(color: Colors.blueGrey, fontSize: 16),
                        ),
                        trailing: Text(
                          '\$${price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ItemCard(
                                id: id,
                                name: name,
                                description: description,
                                price: price,
                                initialQuantity: quantity,
                                imageUrl: imageUrl,
                                onQuantityChanged: (newQuantity) {
                                  _updateItemQuantity(id, newQuantity);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
