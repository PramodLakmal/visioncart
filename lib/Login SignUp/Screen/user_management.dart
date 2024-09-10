import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserManagementState createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  // Controller for the search bar
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: const Color.fromARGB(255, 33, 150, 243),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Attractive Search Bar
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // Position of shadow
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
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: Colors.blueAccent),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.blueAccent),
                      onPressed: () {
                        // Clear the search input
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
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
                      // Handle editing user details
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Handle deleting the user
                      await FirebaseFirestore.instance.collection('users').doc(doc.id).delete();
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
                      // Handle editing user details
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Handle deleting the user
                      await FirebaseFirestore.instance.collection('users').doc(doc.id).delete();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.admin_panel_settings),
                    onPressed: () async {
                      // Toggle admin status
                      bool isAdmin = data['isAdmin'] ?? false;
                      await FirebaseFirestore.instance.collection('users').doc(doc.id).update({'isAdmin': !isAdmin});
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
}
