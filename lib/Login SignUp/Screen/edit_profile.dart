import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<EditProfile> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String profileImageUrl = '';
  // Get current user from Firebase Authentication
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userData.exists && userData.data() != null) {
        Map<String, dynamic> data =
            userData.data() as Map<String, dynamic>; // Safely cast to a Map
        // Use the data only if the field exists, otherwise assign an empty string or default value
        fullNameController.text = data.containsKey('name') ? data['name'] : '';
        usernameController.text =
            data.containsKey('username') ? data['username'] : '';
        telephoneController.text =
            data.containsKey('telephone') ? data['telephone'] : '';
        addressController.text =
            data.containsKey('address') ? data['address'] : '';
        ageController.text = data.containsKey('age') ? data['age'] : '';
        countryController.text =
            data.containsKey('country') ? data['country'] : '';
        postalCodeController.text =
            data.containsKey('postalCode') ? data['postalCode'] : '';
        // For email, we are fetching it from FirebaseAuth instead of Firestore
        emailController.text = user.email ?? '';
        profileImageUrl =
            data.containsKey('profileImageUrl') ? data['profileImageUrl'] : '';
        setState(() {});
      }
    }
  }

  Future<void> updateProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': fullNameController.text,
        'username': usernameController.text,
        'email': emailController.text,
        'telephone': telephoneController.text,
        'address': addressController.text,
        'age': ageController.text,
        'country': countryController.text,
        'postalCode': postalCodeController.text,
      });
    }
  }

  Future<void> deleteUserProfile() async {
    try {
      if (user != null) {
        // Delete user data from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .delete();

        // Delete the user from FirebaseAuth
        await user!.delete();

        // Sign out the user after deletion
        await FirebaseAuth.instance.signOut();

        // Navigate back to login or another page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) =>
                  const LoginScreen()), // Ensure you have LoginScreen imported
        );
      }
    } catch (e) {
      // Handle error, such as when trying to delete the user but re-authentication is required
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Added SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      child: Icon(Icons.person, size: 50),
                    ),
              const SizedBox(height: 20),
              _buildTextField(fullNameController, "Full Name"),
              _buildTextField(usernameController, "Username"),
              _buildTextField(emailController, "Email"),
              _buildTextField(telephoneController, "Telephone"),
              _buildTextField(addressController, "Address"),
              _buildTextField(ageController, "Age"),
              _buildTextField(countryController, "Country"),
              _buildTextField(postalCodeController, "Postal Code"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await updateProfile();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Profile updated successfully!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Update Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Ask for confirmation before deleting
                  bool? confirmDelete = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete Profile'),
                        content: const Text(
                            'Are you sure you want to delete your profile? This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false); // User canceled
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true); // User confirmed
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                  if (confirmDelete == true) {
                    await deleteUserProfile();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87, // Red color for delete button
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller, 
        style: const TextStyle(fontSize: 20, color: Colors.white),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
