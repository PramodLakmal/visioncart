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
        Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
        fullNameController.text = data['name'] ?? '';
        usernameController.text = data['username'] ?? '';
        telephoneController.text = data['telephone'] ?? '';
        addressController.text = data['address'] ?? '';
        ageController.text = data['age'] ?? '';
        countryController.text = data['country'] ?? '';
        postalCodeController.text = data['postalCode'] ?? '';
        emailController.text = user.email ?? '';
        profileImageUrl = data['profileImageUrl'] ?? '';
        setState(() {});
      }
    }
  }

  Future<void> updateProfile() async {
    if (!_validateInputs()) return;  // Call validation method before updating profile

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': fullNameController.text,
        'username': usernameController.text,
        'email': emailController.text,
        'telephone': telephoneController.text,
        'address': addressController.text,
        'age': ageController.text,
        'country': countryController.text,
        'postalCode': postalCodeController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  bool _validateInputs() {
    // Validate Phone Number
    if (!RegExp(r'^\d{10}$').hasMatch(telephoneController.text)) {
      _showValidationError('Invalid phone number. It should be 10 digits long.');
      return false;
    }

    // Validate Age
    int? age = int.tryParse(ageController.text);
    if (age == null || age < 1 || age > 120) {
      _showValidationError('Invalid age. It should be a number between 1 and 120.');
      return false;
    }

    // Validate Postal Code (for this example, we'll assume postal code should be alphanumeric)
    if (!RegExp(r'^[a-zA-Z0-9]{3,10}$').hasMatch(postalCodeController.text)) {
      _showValidationError('Invalid postal code. It should be 3-10 alphanumeric characters.');
      return false;
    }

    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> deleteUserProfile() async {
    try {
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).delete();
        await user!.delete();
        await FirebaseAuth.instance.signOut();
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting profile: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, true); // Go back to the previous screen
          },
        ),
      ),
      backgroundColor: Colors.black87, // Background color for the entire page
      body: Center( // Centering the content
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,// Center children vertically
              children: [
                const SizedBox(height: 20),
                user?.photoURL != null
                    ? CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(user!.photoURL!),
                      )
                    : const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey, // Change to grey for better visibility
                        child: Icon(Icons.person, size: 50, color: Colors.white),
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
                    await updateProfile();  // Validate and update profile on button press
                    Navigator.of(context).pop(); // Navigate back to the previous page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    textStyle: const TextStyle(fontSize: 20),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Update Profile',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    bool? confirmDelete = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete Profile'),
                          content: const Text('Are you sure you want to delete your profile? This action cannot be undone.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
                          ],
                        );
                      },
                    );
                    if (confirmDelete == true) {
                      await deleteUserProfile();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    textStyle: const TextStyle(fontSize: 20),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Delete Profile',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return Semantics(
      label: '$controller: $labelText',
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.blueGrey[800],
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              labelText,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.yellowAccent, fontSize: 24), // Change text color for visibility
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter $labelText',
                hintStyle: const TextStyle(color: Colors.white54), // Hint text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
