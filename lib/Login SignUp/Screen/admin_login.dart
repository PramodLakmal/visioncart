import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_dashboard.dart'; // Web-based admin dashboard
import 'home_screen.dart'; // Mobile user dashboard

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  _AdminLoginState createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Function for login
  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
    });
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        bool isAdmin = doc.exists && doc.get('isAdmin') == true;

        // If running on web, only allow admin login
        if (isAdmin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboard()),  // Web Admin Dashboard
          );
        } else {
          // Navigate to respective dashboard
          if (isAdmin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboard()),  // Web Admin Dashboard
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),  // Mobile User Home
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message ?? 'Error occurred');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: SizedBox(
              height: 500, // Adjust height based on your preference
              width: 900,  // Adjust width based on your preference
              child: Row(
                children: [
                  // Left side: Image
                  Expanded(
                    child: Image.network(
                      'https://firebasestorage.googleapis.com/v0/b/visioncart-5e1b8.appspot.com/o/Login%20and%20SignUp%2FVisionCart%20Logo.png?alt=media&token=45f2e245-c250-4336-a782-cad91d6b2618',
                      width: 400,
                      height: 400,
                    ),
                  ),

                  // Right side: Login Form
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Login Title
                          Text(
                            'VisionCart Admin Login',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                  fontSize: 30,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          // Email Input
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Password Input
                          TextField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 20),
                          // Login Button
                          ElevatedButton(
                            onPressed: loginUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Color.fromARGB(255, 170, 203, 209))
                                : const Text(
                                    'Login',
                                    style: TextStyle(fontSize: 18),
                                  ),
                          ),
                          const SizedBox(height: 10),
                          // Forgot Password (Optional)
                          TextButton(
                            onPressed: () {
                              // Add forgot password logic here
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void showSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(content: Text(message));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
