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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
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
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5, width: double.infinity),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center( // Center the Column within the SingleChildScrollView
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Profile picture
                      user?.photoURL != null
                          ? CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(user!.photoURL!),
                            )
                          : const CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, size: 50),
                            ),
                            const SizedBox(height: 20),
                  // Display user data
                  Center(
                    child: Text(
                      userData?['name'] ?? 'No Name',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                            
                      const SizedBox(height: 20),
                      _buildInfoBox("Email", userData?['email'] ?? 'No Email'),
                      _buildInfoBox("Username", userData?['username'] ?? 'No Username'),
                      _buildInfoBox("Telephone", userData?['telephone'] ?? 'No Telephone'),
                      _buildInfoBox("Address", userData?['address'] ?? 'No Address'),
                      _buildInfoBox("Age", userData?['age'] ?? 'No Age'),
                      _buildInfoBox("Country", userData?['country'] ?? 'No Country'),
                      _buildInfoBox("Postal Code", userData?['postalCode'] ?? 'No Postal Code'),
                      const SizedBox(height: 30),
                      // Edit Profile Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfile(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(33, 150, 243, 1),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Edit Profile', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(height: 20),
                      // Log Out Button
                      ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Log Out', style: TextStyle(fontSize: 20)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
