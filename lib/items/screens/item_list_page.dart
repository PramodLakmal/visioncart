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

  final Color lightBlue = Colors.black87;

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
        var itemName = (item.data() as Map<String, dynamic>)['name']
                ?.toString()
                .toLowerCase() ??
            '';
        return itemName.contains(query.toLowerCase());
      }).toList();
    }

    setState(() {
      filteredItems = results;
    });
  }

  Future<void> _updateItemQuantity(String id, double newQuantity) async {
    await itemsCollection.doc(id).update({'quantity': newQuantity});
    await _fetchItems();
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Center(
            child: Text(
          'Item List',
          style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontWeight: FontWeight.bold,
              fontSize: 28,
              letterSpacing: 1.2),
        )),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
        color: Colors.blueGrey[800],
        child: filteredItems.isEmpty
            ? const Center(
                child: Text('No items found', style: TextStyle(fontSize: 20)),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  childAspectRatio: 0.65,
                ),
                itemCount: filteredItems.length,
                padding: const EdgeInsets.all(10),
                itemBuilder: (context, index) {
                  var itemData =
                      filteredItems[index].data() as Map<String, dynamic>?;
                  String id = filteredItems[index].id;
                  String name = itemData?['name'] ?? 'Unnamed Item';
                  String description =
                      itemData?['description'] ?? 'No description';
                  double price = itemData?['price']?.toDouble() ?? 0.0;
                  double quantity = itemData?['quantity']?.toDouble() ?? 0.0;
                  String imageUrl = itemData?['imageUrl'] ?? '';

                  // Capitalize the first letter of the item name
                  name = capitalizeFirstLetter(name);

                  return GestureDetector(
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
                    child: Card(
                      color: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(imageUrl,
                                      width: double.infinity, fit: BoxFit.cover)
                                  : const Icon(Icons.image, size: 80),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'In stock: ${quantity.toInt()}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Rs: ${price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
