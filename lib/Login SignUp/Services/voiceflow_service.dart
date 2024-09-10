//voiceflow_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class VoiceflowService {
  final String baseUrl = 'https://general-runtime.voiceflow.com/state/user/userID/interact?logs=off';
  final String apiKey = 'api_key';

  Future<List<dynamic>> launch() async {
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

  Future<List<dynamic>> sendText(String text) async {
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
