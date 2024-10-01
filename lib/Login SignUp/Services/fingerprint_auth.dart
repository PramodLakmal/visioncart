import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FingerprintAuth {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to log in',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true); // Store user as authenticated
      }
    } catch (e) {
      print('Error during authentication: $e');
    }
    return authenticated;
  }

  Future<bool> isUserAuthenticated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isAuthenticated') ?? false;
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', false);
  }

  static authenticateWithBiometrics() {}
}
