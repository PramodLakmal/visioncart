import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServices {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Sign in with Google
  Future<String> signInWithGoogle() async {
    String res = "Some error occurred";
    try {
      // Trigger the Google authentication flow
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        // Create a new credential using the token
        final AuthCredential authCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        // Sign in with the credential to Firebase
        UserCredential userCredential = await auth.signInWithCredential(authCredential);

        // Get user information
        User? user = userCredential.user;

        // Check if the user is new by looking for their UID in Firestore
        DocumentSnapshot snapshot = await firestore.collection('users').doc(user!.uid).get();

        if (!snapshot.exists) {
          // If the user is signing in for the first time, store their information in Firestore
          await firestore.collection('users').doc(user.uid).set({
            'name': user.displayName ?? "No Name",  // Fallback if no display name
            'email': user.email,
            'uid': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        res = "success";
      } else {
        res = "Google sign-in was aborted.";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        res = "This account exists with a different credential.";
      } else if (e.code == 'invalid-credential') {
        res = "Invalid credentials, please try again.";
      } else {
        res = e.message ?? "An unknown error occurred.";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Sign out from Google and Firebase
  Future<void> googleSignOut() async {
    try {
      await googleSignIn.signOut();
      await auth.signOut();
    } catch (err) {
      print("Error signing out: ${err.toString()}");
    }
  }
}
