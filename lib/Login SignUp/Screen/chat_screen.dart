import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../Services/voiceflow_service.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final VoiceflowService _voiceflowService = VoiceflowService();
  final FlutterTts _flutterTts = FlutterTts();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "";
  List<String> messages = [];
  final ScrollController _scrollController = ScrollController(); // Scroll controller for auto-scroll

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    var response = await _voiceflowService.launch();
    _handleResponse(response);
  }

  Future<void> _handleResponse(List<dynamic> response) async {
    for (var message in response) {
      if (message['type'] == 'speak') {
        setState(() {
          messages.add('Bot: ${message['payload']['message']}');
        });
        await _flutterTts.speak(message['payload']['message']);
        _scrollToBottom(); // Scroll to bottom after adding a message
      }
    }
  }

  Future<void> _startListening() async {
    if (!_isListening) {
      _isListening = true;
      setState(() {});

      bool available = await _speech.initialize();
      if (available) {
        _speech.listen(onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
            if (result.hasConfidenceRating && result.confidence > 0) {
              _sendMessage(_text);
            }
          });
        });

        Future.delayed(Duration(seconds: 5), () {
          _stopListening();
        });
      }
    }
  }

  Future<void> _stopListening() async {
    if (_isListening) {
      _isListening = false;
      setState(() {});
      await _speech.stop();
    }
  }

  Future<void> _sendMessage(String userInput) async {
    if (userInput.isNotEmpty) {
      setState(() {
        messages.add('You: $userInput');
      });
      var response = await _voiceflowService.sendText(userInput);
      await _handleResponse(response);
      _text = "";
      _scrollToBottom(); // Scroll to bottom after sending a message
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Interaction'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController, // Attach the scroll controller
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: messages[index].startsWith('Bot')
                          ? Colors.lightBlue[50]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      messages[index],
                      style: TextStyle(
                        fontSize: 18,
                        color: messages[index].startsWith('Bot')
                            ? Colors.blueAccent
                            : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startListening,
              child: Text(
                _isListening ? 'Listening...' : 'Press to Speak',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
