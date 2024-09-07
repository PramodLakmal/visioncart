import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile.dart'; // Import the edit profile page
import 'login.dart'; // Import the edit profile page

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current user from Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 50),  // Add space above the profile picture
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
            // User Name
            Text(
              user?.displayName ?? "No Name",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // User Email
            Text(
              user?.email ?? "No Email",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            // Edit Profile Button
            ElevatedButton(
              onPressed: () {
                // Navigate to the edit profile page
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
              child: const Text('Edit Profile'),
            ),
            const SizedBox(height: 20),
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
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                foregroundColor: Colors.white,
              ),
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
