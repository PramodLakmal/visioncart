import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For haptic feedback
import 'package:visioncart/cart/screens/cartScreen.dart';
import 'package:visioncart/cart/screens/orderScreen.dart';
import '../../items/screens/item_list_page.dart';
import 'profile_page.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    Center(
      child: Text(
        'Home Page Content',
        style: TextStyle(fontSize: 28), // Larger font size for readability
      ),
    ),
    Orders(),
    Cart(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    HapticFeedback.selectionClick(); // Provide haptic feedback
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: selectedIndex == 0
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black, // Darker background for higher contrast
                    Colors.blue[600]!,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Semantics(
                    label: 'Welcome to VisionCart. Explore our items or start a voice interaction.',
                    child: const Text(
                      "Welcome to VisionCart",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 40, // Larger, high-contrast text
                        fontWeight: FontWeight.bold,
                        color: Colors.yellowAccent, // High-contrast color
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Semantics(
                    label: 'Welcome to VisionCart. Explore our items or start a voice interaction.',
                    child: const Text(
                      "Explore our items or start a voice interaction.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30, // Larger, high-contrast text
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // High-contrast color
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Semantics(
                    label: 'View all items button',
                    button: true,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.vibrate(); // Provide haptic feedback
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ItemListPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // High contrast background
                        padding: const EdgeInsets.symmetric(
                            horizontal: 60, vertical: 25), // Increased button size
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        "View All Items",
                        style: TextStyle(
                          fontSize: 24, // Larger text
                          color: Colors.white, // High-contrast text
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Semantics(
                    label: 'Start voice interaction button',
                    button: true,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.vibrate(); // Provide haptic feedback
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ChatScreen()), // Navigate to voice interaction
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87, // High contrast background
                        padding: const EdgeInsets.symmetric(
                            horizontal: 60, vertical: 25), // Increased button size
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        elevation: 5,
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // Center the row content
                          children: [
                            Expanded(
                              child: Text(
                                "Start Voice Interaction",
                                style: TextStyle(
                                  fontSize: 26, // Larger text for readability
                                  color: Colors.white, // High-contrast color
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center, // Center the text within the Expanded widget
                              ),
                            ),
                            SizedBox(width: 8), // Add some space between the text and the icon
                            Icon(
                              Icons.mic, // Voice icon
                              color: Colors.white, // Same color as the text for consistency
                              size: 50, // Match the text size
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : _pages[selectedIndex],
      bottomNavigationBar: Semantics(
        label: 'Bottom navigation bar',
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 35), // Increased icon size
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag, size: 35), // Increased icon size
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart, size: 35), // Increased icon size
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 35), // Increased icon size
              label: 'Profile',
            ),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Colors.yellowAccent,
          unselectedItemColor: Colors.white,
          selectedLabelStyle:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Larger label size
          unselectedLabelStyle: const TextStyle(fontSize: 16), // Larger label size
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          elevation: 12,
          backgroundColor: Colors.black87,
        ),
      ),
    );
  }
}
