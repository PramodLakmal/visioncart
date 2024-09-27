import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:visioncart/Login%20SignUp/Widget/button.dart';
import 'package:visioncart/Login%20With%20Google/google_auth.dart';
import 'package:visioncart/Password%20Forgot/forgot_password.dart';
import 'package:visioncart/Phone%20Auth/phone_login.dart';
import '../Services/authentication.dart';
import '../Widget/snackbar.dart';
import '../Widget/text_field.dart';
import 'admin_dashboard.dart';
import 'home_screen.dart';
import 'signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

// email and passowrd auth part
  void loginUser() async {
    setState(() {
      isLoading = true;
    });
    // signup user using our authmethod
    String res = await AuthMethod().loginUser(
        email: emailController.text, password: passwordController.text);

    if (res == "admin") {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => const AdminDashboard(),  // Admin screen
    ),
  );
} else if (res == "user") {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => const HomeScreen(),  // User screen
    ),
  );
} else {
  showSnackBar(context, res);  // Show any error messages
}
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: SafeArea(
          child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: height / 2.7,
              child: Image.network('https://firebasestorage.googleapis.com/v0/b/visioncart-5e1b8.appspot.com/o/Login%20and%20SignUp%2FUntitled%20design%20(12).jpg?alt=media&token=52037aa3-ffe9-4e95-ac8d-1fc22ff6f344'),
            ),
            TextFieldInput(
                icon: Icons.person,
                textEditingController: emailController,
                hintText: 'Enter your email',
                textInputType: TextInputType.text),
            TextFieldInput(
              icon: Icons.lock,
              textEditingController: passwordController,
              hintText: 'Enter your password',
              textInputType: TextInputType.text,
              isPass: true,
            ),
            //  we call our forgot password below the login in button
            const ForgotPassword(),
            MyButtons(onTap: loginUser, text: "Log In"),

            Row(
              children: [
                Expanded(
                  child: Container(height: 1, color: Colors.black26),
                ),
                const Text("  or  "),
                Expanded(
                  child: Container(height: 1, color: Colors.black26),
                )
              ],
            ),
            // for google login
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  side: const BorderSide(color: Colors.white, width: 2),
                  elevation: 5, // Adds shadow effect
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12), // Optional: Rounded corners
                  ),
                ),
                onPressed: () async {
                String result = await FirebaseServices().signInWithGoogle();
                
                if (result == "success") {
                  // Check if the user is an admin or normal user
                  User? currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    DocumentSnapshot snapshot = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .get();
                    
                    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
                    if (data != null && data['isAdmin'] == true) {
                      // Navigate to admin dashboard
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminDashboard()),
                      );
                    } else {
                      // Navigate to user home screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    }
                    }
                  } else {
                    // Show error message
                    showSnackBar(context, result);
                  }
                },


                child: Center(
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Centers the icon and text
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Image.network(
                          "https://firebasestorage.googleapis.com/v0/b/visioncart-5e1b8.appspot.com/o/Login%20and%20SignUp%2Fpngwing.com.png?alt=media&token=109f22c6-d0ed-4265-a5d3-c5c04ecf7b14",
                          height: 35,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Continue with Google",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // for phone authentication
            const PhoneAuthentication(),
            // Don't have an account? got to signup screen
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: Colors.white, fontSize: 16)),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "SignUp",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  Container socialIcon(image) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 15,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Image.network(
        image,
        height: 40,
      ),
    );
  }
}