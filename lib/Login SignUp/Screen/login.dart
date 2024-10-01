import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visioncart/Login%20SignUp/Widget/button.dart';
import 'package:visioncart/Login%20With%20Google/google_auth.dart';
import 'package:visioncart/Password%20Forgot/forgot_password.dart';
import '../Services/authentication.dart';
import '../Services/fingerprint_auth.dart';
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

// Instantiate the FingerprintAuth class

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  // Email and password authentication part
  void loginUser() async {
  setState(() {
    isLoading = true;
  });
  // Sign up user using our auth method
  String res = await AuthMethod().loginUser(
      email: emailController.text, password: passwordController.text);

  if (res == "admin" || res == "user") {
    // Store user credentials for future fingerprint login
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', emailController.text);
    await prefs.setString('password', passwordController.text);
    
    if (res == "admin") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AdminDashboard(), // Admin screen
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(), // User screen
        ),
      );
    }
  } else {
    showSnackBar(context, res); // Show any error messages
  }
}

  // Fingerprint login method
  void handleFingerprintLogin() async {
  final LocalAuthentication auth = LocalAuthentication();

  try {
    bool authenticated = await auth.authenticate(
      localizedReason: 'Scan your fingerprint to log in',
      options: const AuthenticationOptions(biometricOnly: true),
    );

    if (authenticated) {
      // Retrieve stored email and password
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('email');
      String? password = prefs.getString('password');

      if (email != null && password != null) {
        // Log the user in using saved credentials
        String res = await AuthMethod().loginUser(email: email, password: password);

        if (res == "admin") {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const AdminDashboard(), // Admin screen
            ),
          );
        } else if (res == "user") {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(), // User screen
            ),
          );
        } else {
          showSnackBar(context, res); // Show any error messages
        }
      } else {
        showSnackBar(context, 'No login details found. Please log in manually.');
      }
    }
  } catch (e) {
    showSnackBar(context, 'Fingerprint authentication failed.');
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
                child: Image.network(
                  'https://firebasestorage.googleapis.com/v0/b/visioncart-5e1b8.appspot.com/o/Login%20and%20SignUp%2FVisionCart%20Logo.png?alt=media&token=45f2e245-c250-4336-a782-cad91d6b2618',
                ),
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
              const ForgotPassword(),
              MyButtons(onTap: loginUser, text: "Log In"),

              Row(
                children: [
                  Expanded(
                    child: Container(height: 1, color: Colors.white),
                  ),
                  const Text("  or  ", style: TextStyle(color: Colors.white)),
                  Expanded(
                    child: Container(height: 1, color: Colors.white),
                  )
                ],
              ),

              // Google login button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    side: const BorderSide(color: Colors.white, width: 2),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    String result = await FirebaseServices().signInWithGoogle();

                    if (result == "success") {
                      User? currentUser = FirebaseAuth.instance.currentUser;
                      if (currentUser != null) {
                        DocumentSnapshot snapshot = await FirebaseFirestore
                            .instance
                            .collection('users')
                            .doc(currentUser.uid)
                            .get();

                        Map<String, dynamic>? data =
                            snapshot.data() as Map<String, dynamic>?;
                        if (data != null && data['isAdmin'] == true) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AdminDashboard()),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomeScreen()),
                          );
                        }
                      }
                    } else {
                      showSnackBar(context, result);
                    }
                  },
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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

              // Fingerprint sign-in button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    side: const BorderSide(color: Colors.white, width: 2),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: handleFingerprintLogin,
                  child: const Text(
                    "Sign in with Fingerprint",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Can Add Phone login button

              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
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
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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