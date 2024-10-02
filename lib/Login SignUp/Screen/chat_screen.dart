import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../Services/voiceflow_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

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
  final ScrollController _scrollController = ScrollController();

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
    String combinedMessage = '';
    for (var message in response) {
      if (message['type'] == 'speak') {
        setState(() {
          messages.add('Bot: ${message['payload']['message']}');
        });
        combinedMessage += '${message['payload']['message']} ';
      }
    }

    if (combinedMessage.isNotEmpty) {
      await _flutterTts.speak(combinedMessage.trim());
      _scrollToBottom();
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

        Future.delayed(const Duration(seconds: 5), () {
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
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Voice Interaction',
          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[900],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[900]!, Colors.black],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final isBot = messages[index].startsWith('Bot');
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 12.0),
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: isBot ? Colors.blue[800] : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        messages[index],
                        style: TextStyle(
                          fontSize: 24,  // Increased font size
                          color: isBot ? Colors.white : Colors.black,  // High contrast colors
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _startListening,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 32,  // Increased icon size
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _isListening ? 'Listening...' : 'Press to Speak',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),  // Increased font size
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}