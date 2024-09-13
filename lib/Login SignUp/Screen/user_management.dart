import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserManagementState createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  // Search controller and query
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: const Color.fromARGB(255, 33, 150, 243),
        actions: [
          // PDF Generation button in AppBar
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              _generatePDF(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search bar
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                    prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 20.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.blueAccent),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                        FocusScope.of(context).requestFocus(FocusNode()); // Hide keyboard
                      },
                    ),
                  ),
                  onChanged: (query) {
                    setState(() {
                      _searchQuery = query.toLowerCase();
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 800) {
                      return _buildUserTable(context);
                    } else {
                      return _buildUserList(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to filter user documents based on the search query
  List<QueryDocumentSnapshot> _filterUsers(List<QueryDocumentSnapshot> users) {
    if (_searchQuery.isEmpty) {
      return users;
    }
    return users.where((doc) {
      var data = doc.data() as Map<String, dynamic>;
      var name = (data['name'] ?? '').toLowerCase();
      var email = (data['email'] ?? '').toLowerCase();
      return name.contains(_searchQuery) || email.contains(_searchQuery);
    }).toList();
  }

  Widget _buildUserTable(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No users found.'));
        }

        // Filter users based on search query
        var filteredUsers = _filterUsers(snapshot.data!.docs);

        // DataTable for large screens
        return DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Actions')),
          ],
          rows: filteredUsers.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return DataRow(cells: [
              DataCell(Text(data['name'] ?? 'Unknown')),
              DataCell(Text(data['email'] ?? 'Unknown')),
              DataCell(Text(data['isAdmin'] ? 'Admin' : 'User')),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _showEditUserDialog(context, data, doc.id);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmationDialog(context, doc.id);
                    },
                  ),
                ],
              )),
            ]);
          }).toList(),
        );
      },
    );
  }

  Widget _buildUserList(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No users found.'));
        }

        // Filter users based on search query
        var filteredUsers = _filterUsers(snapshot.data!.docs);

        // ListView for small screens
        return ListView.builder(
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            var doc = filteredUsers[index];
            var data = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['name'] ?? 'Unknown'),
              subtitle: Text(data['email'] ?? 'Unknown'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _showEditUserDialog(context, data, doc.id);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmationDialog(context, doc.id);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // PDF generation function
  void _generatePDF(BuildContext context) async {
    final pdf = pw.Document();

    // Fetch users from Firestore
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
    List<QueryDocumentSnapshot> users = usersSnapshot.docs;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('User Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                headers: ['Name', 'Email', 'Role'],
                data: users.map((user) {
                  Map<String, dynamic> data = user.data() as Map<String, dynamic>;
                  return [
                    data['name'] ?? 'Unknown',
                    data['email'] ?? 'Unknown',
                    data['isAdmin'] ? 'Admin' : 'User',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    // Display or share the PDF
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'user_report.pdf');
  }

  // User edit dialog (as in your previous code)
  void _showEditUserDialog(BuildContext context, Map<String, dynamic> data, String userId) {
    // TextEditingControllers for user details
    TextEditingController nameController = TextEditingController(text: data['name']);
    TextEditingController emailController = TextEditingController(text: data['email']);
    bool isAdmin = data['isAdmin'] ?? false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Ensures the dialog resizes based on content
            children: [
              // Name input field
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              // Email input field
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              // Checkbox for Admin status
              Row(
                children: [
                  const Text('Admin'),
                  Checkbox(
                    value: isAdmin,
                    onChanged: (value) {
                      isAdmin = value ?? false;
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Handle update - update Firestore with new data
                await FirebaseFirestore.instance.collection('users').doc(userId).update({
                  'name': nameController.text,
                  'email': emailController.text,
                  'isAdmin': isAdmin,
                });
                Navigator.of(context).pop(); // Close the dialog after saving
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // User delete confirmation dialog
  void _showDeleteConfirmationDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: const Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Delete the user document
                await FirebaseFirestore.instance.collection('users').doc(userId).delete();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
