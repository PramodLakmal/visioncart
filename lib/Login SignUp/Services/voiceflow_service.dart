import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

class VoiceflowService {
  final String apiKey = 'api_key'; // Replace with API key

  // Get the current Firebase user ID
  Future<String?> _getUserId() async {
    User? user = FirebaseAuth.instance.currentUser; // Get current user
    return user?.uid; // Return the UID or null if user is not logged in
  }

  // Update baseUrl to dynamically include the user ID
  Future<String> getBaseUrl() async {
    String? userId = await _getUserId();
    if (userId != null) {
      return 'https://general-runtime.voiceflow.com/state/user/$userId/interact?logs=off';
    } else {
      throw Exception('User not authenticated');
    }
  }

  // Launch method to initiate the Voiceflow session
  Future<List<dynamic>> launch() async {
    String baseUrl = await getBaseUrl(); // Get the dynamic URL with the user ID
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'accept': 'application/json',
        'content-type': 'application/json',
        'Authorization': apiKey,
      },
      body: jsonEncode({
        'action': {'type': 'launch'},
        'config': {
          'tts': false,
          'stripSSML': true,
          'stopAll': true,
          'excludeTypes': ['block', 'debug', 'flow']
        },
        'state': {
          'variables': {}
        }
      }),
    );
    return jsonDecode(response.body);
  }

  // Send text method to handle user inputs
  Future<List<dynamic>> sendText(String text) async {
    String baseUrl = await getBaseUrl(); // Get the dynamic URL with the user ID
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'accept': 'application/json',
        'content-type': 'application/json',
        'Authorization': apiKey,
      },
      body: jsonEncode({
        'action': {'type': 'text', 'payload': text},
        'config': {
          'tts': false,
          'stripSSML': true,
          'stopAll': true,
          'excludeTypes': ['block', 'debug', 'flow']
        },
        'state': {
          'variables': {}
        }
      }),
    );
    return jsonDecode(response.body);
  }
}
