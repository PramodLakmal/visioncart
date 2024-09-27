import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'edit_profile.dart'; // Import the edit profile page
import 'login.dart'; // Import the login page

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black87, // High contrast background
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 18, // Larger font size for readability
                color: Colors.white, // High contrast text color
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5, width: double.infinity),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
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
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Profile picture
                      Semantics(
                        label: 'Profile Picture',
                        child: user?.photoURL != null
                            ? CircleAvatar(
                                radius: 60,
                                backgroundImage: NetworkImage(user!.photoURL!),
                                backgroundColor: Colors.black87, // Contrast background
                              )
                            : const CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.black87, // High contrast
                                child: Icon(Icons.person, size: 60, color: Colors.white),
                              ),
                      ),
                      const SizedBox(height: 20),
                      // Display user name
                      Semantics(
                        label: 'User Name: ${userData?['name'] ?? 'No Name'}',
                        child: Text(
                          userData?['name'] ?? 'No Name',
                          style: const TextStyle(
                            fontSize: 30, // Large, readable font
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // High contrast
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Info boxes for user data
                      _buildInfoBox("Email", userData?['email'] ?? 'No Email'),
                      _buildInfoBox("Username", userData?['username'] ?? 'No Username'),
                      _buildInfoBox("Telephone", userData?['telephone'] ?? 'No Telephone'),
                      _buildInfoBox("Address", userData?['address'] ?? 'No Address'),
                      _buildInfoBox("Age", userData?['age'] ?? 'No Age'),
                      _buildInfoBox("Country", userData?['country'] ?? 'No Country'),
                      _buildInfoBox("Postal Code", userData?['postalCode'] ?? 'No Postal Code'),
                      const SizedBox(height: 30),
                      // Edit Profile Button
                      Semantics(
                        button: true,
                        label: 'Edit Profile',
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfile(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontSize: 22), // Large button text
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
                            backgroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Large button text
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
