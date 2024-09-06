import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:visioncart/Login%20SignUp/Screen/login.dart';
import 'register_page.dart'; // Import the registration form

void main() async{
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
