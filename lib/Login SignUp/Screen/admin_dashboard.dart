import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:visioncart/Login%20SignUp/Screen/admin_login.dart';
import 'user_management.dart';
import 'order_management.dart';
import 'item_management.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: GridView.count(
                      shrinkWrap: true, // Ensures GridView does not take full height
                      crossAxisCount: constraints.maxWidth > 600 ? 3 : 1,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.2, // Adjust the aspect ratio to make cards smaller
                      children: [
                        _buildDashboardCard(
                          context,
                          title: 'User Management',
                          icon: Icons.people,
                          color: Colors.blueAccent,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const UserManagement()),
                            );
                          },
                        ),
                        _buildDashboardCard(
                          context,
                          title: 'Order Management',
                          icon: Icons.shopping_cart,
                          color: Colors.green,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const OrderManagement()),
                            );
                          },
                        ),
                        _buildDashboardCard(
                          context,
                          title: 'Item Management',
                          icon: Icons.inventory,
                          color: Colors.orange,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ItemManagement()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Space between grid and logout button
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const AdminLogin()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Log Out', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  // Dashboard card widget
  Widget _buildDashboardCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onPressed}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Adjust padding to make the card smaller
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 35, color: color), // Adjust icon size
              const SizedBox(height: 10), // Space between icon and text
              Text(
                title,
                style: TextStyle(
                  fontSize: 20, // Adjust text size
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
