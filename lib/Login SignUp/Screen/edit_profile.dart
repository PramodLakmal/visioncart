import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userData.exists) {
        fullNameController.text = userData['name'] ?? '';
        usernameController.text = userData['username'] ?? '';
        telephoneController.text = userData['telephone'] ?? '';
        addressController.text = userData['address'] ?? '';
        ageController.text = userData['age'] ?? '';
        countryController.text = userData['country'] ?? '';
        postalCodeController.text = userData['postalCode'] ?? '';
        emailController.text = userData['email'] ?? '';
        profileImageUrl = userData['profileImageUrl'] ?? '';
        setState(() {});
      }
    }
  }

  Future<void> updateProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': fullNameController.text,
        'username': usernameController.text,
        'telephone': telephoneController.text,
        'address': addressController.text,
        'age': ageController.text,
        'country': countryController.text,
        'postalCode': postalCodeController.text,
        'email': emailController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // Added SingleChildScrollView
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
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 50),
                    ),
              const SizedBox(height: 20),
              _buildTextField(fullNameController, "Full Name"),
              _buildTextField(usernameController, "Username"),
              _buildTextField(telephoneController, "Telephone"),
              _buildTextField(addressController, "Address"),
              _buildTextField(ageController, "Age"),
              _buildTextField(countryController, "Country"),
              _buildTextField(postalCodeController, "Postal Code"),
              _buildTextField(emailController, "Email"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await updateProfile();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(33, 150, 243, 1),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Update Profile'),
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
        color: Colors.white,
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
        decoration: InputDecoration(
          labelText: labelText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
