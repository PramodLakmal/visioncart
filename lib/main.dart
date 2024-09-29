import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:visioncart/Login%20SignUp/Screen/admin_dashboard.dart';
import 'package:visioncart/Login%20SignUp/Screen/admin_login.dart';
import 'package:visioncart/Login%20SignUp/Screen/home_screen.dart';
import 'package:visioncart/Login%20SignUp/Screen/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBVz3MWfiCmclBrYIjBcfZIKTl6uzM-yPU",
          authDomain: "visioncart-5e1b8.firebaseapp.com",
          projectId: "visioncart-5e1b8",
          storageBucket: "visioncart-5e1b8.appspot.com",
          messagingSenderId: "762662243828",
          appId: "1:762662243828:web:fbcc19bc699edd17e7bda1",
          measurementId: "G-Z34LMFDZ28",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }

    // Activate Firebase App Check
    await FirebaseAppCheck.instance.activate();
    
    runApp(const MyApp());
  } catch (e) {
    // Handle initialization errors here
    print('Firebase initialization error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: Future.value(FirebaseAuth.instance.currentUser),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        
        if (kIsWeb) {
          // Web: Check if the user is an admin or not
          if (snapshot.hasData) {
            User? user = snapshot.data;
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const MaterialApp(
                    debugShowCheckedModeBanner: false,
                    home: Scaffold(body: Center(child: CircularProgressIndicator())),
                  );
                }
                
                if (userSnapshot.hasData) {
                  bool isAdmin = userSnapshot.data!['isAdmin'] ?? false;
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    home: isAdmin ? const AdminDashboard() : const LoginScreen(),
                  );
                } else {
                  return const MaterialApp(
                    debugShowCheckedModeBanner: false,
                    home: AdminLogin(),
                  );
                }
              },
            );
          } else {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: AdminLogin(),
            );
          }
        } else {
          // Mobile: Redirect to the user login screen
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: snapshot.hasData ? const HomeScreen() : const LoginScreen(),
          );
        }
      },
    );
  }
}
