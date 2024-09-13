import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // SignUp User

  Future<String> signupUser({
    required String email,
    required String password,
    required String name,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          name.isNotEmpty) {
        // register user in auth with email and password
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // add user to your  firestore database
        print(cred.user!.uid);
        await _firestore.collection("users").doc(cred.user!.uid).set({
          'name': name,
          'uid': cred.user!.uid,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'isAdmin': false,  // Default role is user
          'isUser': true,    // Assign user role
        });

        res = "success";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  // logIn user with role check
Future<String> loginUser({
  required String email,
  required String password,
}) async {
  String res = "Some error Occurred";
  try {
    if (email.isNotEmpty || password.isNotEmpty) {
      // Log in user with email and password
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user data from Firestore
      DocumentSnapshot userSnapshot = await _firestore.collection("users").doc(cred.user!.uid).get();

      // Check if the user is admin
      bool isAdmin = userSnapshot['isAdmin'] ?? false;

      if (isAdmin) {
        // Redirect to admin dashboard
        res = "admin";
      } else {
        // Redirect to regular user home screen
        res = "user";
      }
    } else {
      res = "Please enter all the fields";
    }
  } catch (err) {
    return err.toString();
  }
  return res;
}

  // for signout
  signOut() async {
    await _auth.signOut();
  }
}