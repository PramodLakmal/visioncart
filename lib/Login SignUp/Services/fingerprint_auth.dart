import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class FingerprintAuth {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> authenticate() async {
    bool authenticated = false;
    try {
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (canCheckBiometrics) {
        authenticated = await _localAuth.authenticate(
          localizedReason: 'Use your fingerprint to sign in',
          options: const AuthenticationOptions(biometricOnly: true),
        );
      }
    } on PlatformException catch (e) {
      print(e);
    }
    return authenticated;
  }
}
