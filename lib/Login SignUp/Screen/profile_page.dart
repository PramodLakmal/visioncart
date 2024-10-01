import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'edit_profile.dart'; // Import the edit profile page
import 'login.dart'; // Import the login page

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _fetchUserData();
    }
  }

  Future<void> _fetchUserData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    if (doc.exists) {
      setState(() {
        userData = doc.data() as Map<String, dynamic>;
      });
    }
  }

  Widget _buildInfoBox(String label, String value) {
  return Semantics(
    label: '$label: $value', // Screen reader will read this out
    child: Container(
      width: double.infinity, // Make the container take the full width
      height: 130, // Fixed height for uniformity
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blueGrey[800], // High contrast background
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 20, // Larger font size for readability
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
              Text(
              value.isNotEmpty ? value : 'Empty $label',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: value.isNotEmpty ? Colors.yellowAccent : Colors.grey, // High contrast value color for non-empty, grey for empty
              ),
              ),
        ],
      ),
    ),
  );
}


 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black87,
    body: userData == null
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView( // Wrap with SingleChildScrollView
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Profile picture
                    Semantics(
                      label: 'Profile Picture',
                      child: user?.photoURL != null
                          ? CircleAvatar(
                              radius: 70,
                              backgroundImage: NetworkImage(user!.photoURL!),
                              backgroundColor: Colors.blueGrey[800],
                            )
                          : CircleAvatar(
                              radius: 70,
                              backgroundColor: Colors.blueGrey[800],
                              child: const Icon(Icons.person, size: 70, color: Colors.white),
                            ),
                    ),
                    const SizedBox(height: 20),
                    // Display user name
                    Semantics(
                      label: 'User Name: ${userData?['name'] ?? 'No Name'}',
                      child: Text(
                        userData?['name'] ?? 'No Name',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Info boxes for user data
                    _buildInfoBox("Email", userData?['email'] ?? ''),
                    _buildInfoBox("Username", userData?['username'] ?? ''),
                    _buildInfoBox("Telephone", userData?['telephone'] ?? ''),
                    _buildInfoBox("Address", userData?['address'] ?? ''),
                    _buildInfoBox("Age", userData?['age'] ?? ''),
                    _buildInfoBox("Country", userData?['country'] ?? ''),
                    _buildInfoBox("Postal Code", userData?['postalCode'] ?? ''),
                    const SizedBox(height: 40),
                    // Edit Profile Button
                    Semantics(
                      button: true,
                      label: 'Edit Profile',
                      child: ElevatedButton(
                        onPressed: () async {
                          // Navigate to the EditProfile page and wait for the result
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfile(),
                            ),
                          );

                          // If the result is true, refresh the user data
                          if (result == true) {
                            _fetchUserData(); // Refresh the user data
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Edit Profile'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Log Out Button
                    Semantics(
                      button: true,
                      label: 'Log Out',
                      child: ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Log Out'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
  );
}


}