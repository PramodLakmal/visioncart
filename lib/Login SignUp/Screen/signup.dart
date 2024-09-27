import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:visioncart/Login SignUp/Widget/button.dart';
import '../Services/authentication.dart';
import '../Widget/snackbar.dart';
import '../Widget/text_field.dart';
import 'login.dart';

String? validateEmail(String value) {
  if (value.isEmpty) {
    return 'Email cannot be empty';
  }
  // A simple regex to check if the email format is correct
  String pattern = r'^[^@]+@[^@]+\.[^@]+';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(value)) {
    return 'Enter a valid email';
  }
  return null;
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
  }

  void signupUser() async {
  // Input validation
  if (nameController.text.isEmpty) {
    showSnackBar(context, 'Name cannot be empty');
    return;
  }
  if (validateEmail(emailController.text) != null) {
    showSnackBar(context, validateEmail(emailController.text)!);
    return;
  }
  if (passwordController.text.length < 6) {
    showSnackBar(context, 'Password must be at least 6 characters');
    return;
  }

  setState(() {
    isLoading = true;
  });

  String res = await AuthMethod().signupUser(
      email: emailController.text,
      password: passwordController.text,
      name: nameController.text);
  
  if (res == "success") {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    // Update user profile
    if (user != null) {
      await user.updateProfile(displayName: nameController.text);
      await user.reload(); // Reload user to update profile information
    }

    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  } else {
    setState(() {
      isLoading = false;
    });
    showSnackBar(context, res);
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
              height: height / 2.8,
              child: Image.asset('assets/images/signup.jpeg'),
            ),
            TextFieldInput(
                icon: Icons.person,
                textEditingController: nameController,
                hintText: 'Enter your name',
                textInputType: TextInputType.text),
            TextFieldInput(
                icon: Icons.email,
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
            MyButtons(
                onTap: signupUser,
                text: isLoading ? "Loading..." : "Sign Up",
              ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?", style: TextStyle(color: Colors.white, fontSize: 16)),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    " Login",
                    style: TextStyle(fontWeight: FontWeight.bold , color: Colors.white, fontSize: 18),
                  ),
                )
              ],
            )
          ],
        ),
      )),
    );
  }
}
