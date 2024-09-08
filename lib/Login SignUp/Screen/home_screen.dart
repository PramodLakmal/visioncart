import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Login With Google/google_auth.dart';
import '../Widget/button.dart';
import 'login.dart';
import 'profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  // Navigation pages
  static const List<Widget> _pages = <Widget>[
    Center(child: Text('Home Page Content', style: TextStyle(fontSize: 24))),
    Center(child: Text('Orders Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Cart Page', style: TextStyle(fontSize: 24))),
    ProfilePage(),
  ];

  // Function to handle navigation tap
  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VisionCart'),
        backgroundColor: const Color.fromARGB(255, 33, 150, 243),
      ),
      body: selectedIndex == 0
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Congratulation\nYou have successfully Logged In",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  // You can uncomment below for Google User details
                  // Image.network("${FirebaseAuth.instance.currentUser!.photoURL}"),
                  // Text("${FirebaseAuth.instance.currentUser!.email}"),
                  // Text("${FirebaseAuth.instance.currentUser!.displayName}")
                ],
              ),
            )
          : _pages[selectedIndex], // Load different pages based on the tab
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 33, 150, 243),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        selectedFontSize: 14,
        unselectedFontSize: 12,
      ),
    );
  }
}
