import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:visioncart/Login%20SignUp/Screen/admin_login.dart';
import 'login.dart';
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Check if it's a larger screen (web/tablet) or a small screen (mobile)
            if (constraints.maxWidth > 600) {
              // Large screen layout (tablet, web)
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UserManagement()),
                      );
                    },
                    child: const Text('User Management'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OrderManagement()),
                      );
                    },
                    child: const Text('Order Management'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ItemManagement()),
                      );
                    },
                    child: const Text('Item Management'),
                  ),
                  // Log Out Button with consistent TextStyle
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const AdminLogin()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Log Out'),
                  ),
                ],
              );
            } else {
              // Small screen layout (mobile)
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UserManagement()),
                      );
                    },
                    child: const Text('User Management'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OrderManagement()),
                      );
                    },
                    child: const Text('Order Management'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ItemManagement()),
                      );
                    },
                    child: const Text('Item Management'),
                  ),
                  const SizedBox(height: 40),
                  // Log Out Button with consistent TextStyle
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Log Out'),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
