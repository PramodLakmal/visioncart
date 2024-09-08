import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color.fromARGB(255, 33, 150, 243),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Check the available width to adjust the layout accordingly
              if (constraints.maxWidth > 800) {
                // Large screen (desktop/tablet) layout
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'User Management',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance.collection('users').snapshots(),
                        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text('No users found.'));
                          }

                          // DataTable for large screens
                          return DataTable(
                            columns: const [
                              DataColumn(label: Text('Name')),
                              DataColumn(label: Text('Email')),
                              DataColumn(label: Text('Role')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: snapshot.data!.docs.map((doc) {
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
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        // Handle deleting the user
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(doc.id)
                                            .delete();
                                      },
                                    ),
                                  ],
                                )),
                              ]);
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                );
              } else {
                // Small screen (mobile) layout
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'User Management',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance.collection('users').snapshots(),
                        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text('No users found.'));
                          }

                          // ListView for small screens
                          return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var doc = snapshot.data!.docs[index];
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
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        // Handle deleting the user
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(doc.id)
                                            .delete();
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.admin_panel_settings),
                                      onPressed: () async {
                                        // Toggle admin status
                                        bool isAdmin = data['isAdmin'] ?? false;
                                        await FirebaseFirestore.instance.collection('users').doc(doc.id).update({
                                          'isAdmin': !isAdmin,
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
