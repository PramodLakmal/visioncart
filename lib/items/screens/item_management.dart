import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'item_form.dart';
import '../models/item_model.dart';

class ItemManagement extends StatefulWidget {
  const ItemManagement({super.key});

  @override
  _ItemManagementState createState() => _ItemManagementState();
}

class _ItemManagementState extends State<ItemManagement> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final Color lightBlue = const Color.fromRGBO(33, 150, 243, 1);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Method to generate a PDF report of the items
  Future<void> _generateReport(List<QueryDocumentSnapshot> items) async {
    final pdf = pw.Document();

    // Adding a title and a table to the PDF
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "Items Report",
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              context: context,
              data: <List<String>>[
                <String>['Item ID', 'Name', 'Price', 'Quantity'],
                ...items.map(
                  (item) {
                    final data = item.data() as Map<String, dynamic>;
                    return [
                      item.id, // Add item ID here
                      data['name'] ?? '',
                      data['price'].toString(),
                      data['quantity'].toString(),
                    ];
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // Print or save the PDF
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Item Management"),
        backgroundColor: lightBlue,
        actions: [
          // Icon button to generate the report
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              // Fetch the list of items from Firestore
              final snapshot = await FirebaseFirestore.instance.collection('items').get();
              final items = snapshot.docs;
              // Generate the PDF report
              _generateReport(items);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('items').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(lightBlue)));
          }

          var items = snapshot.data!.docs
              .where((doc) {
                var itemData = doc.data() as Map<String, dynamic>;
                var name = itemData['name']?.toLowerCase() ?? '';
                return name.contains(_searchQuery);
              })
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              var itemData = items[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  leading: itemData.containsKey('imageUrl') && itemData['imageUrl'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(itemData['imageUrl'], width: 60, height: 60, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.image_not_supported, size: 60, color: Colors.black),
                  title: Text(itemData['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "\$${itemData['price']} (${itemData['quantity']} in stock)",
                    style: const TextStyle(color: Colors.black),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('items')
                          .doc(items[index].id)
                          .delete();
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemFormPage(
                          item: ItemModel(
                            id: items[index].id,
                            name: itemData['name'],
                            description: itemData['description'],
                            price: itemData['price'],
                            quantity: itemData['quantity'],
                            imageUrl: itemData.containsKey('imageUrl') ? itemData['imageUrl'] : null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ItemFormPage()),
          );
        },
        backgroundColor: const Color.fromRGBO(33, 150, 243, 1),
        child: const Icon(Icons.add),
      ),
    );
  }
}
