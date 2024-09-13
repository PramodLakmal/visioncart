import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:visioncart/Login%20SignUp/Screen/admin_login.dart';
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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: kIsWeb ? const AdminLogin() : const LoginScreen(),
    );
  }
}
