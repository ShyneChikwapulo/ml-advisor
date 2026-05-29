import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser})
      : timestamp = DateTime.now();
}

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _loading = false;

  List<ChatMessage> get messages => _messages;
  bool get loading => _loading;

  Future<void> sendMessage(String text) async {
    _messages.add(ChatMessage(text: text, isUser: true));
    _loading = true;
    notifyListeners();

    try {
      final response = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'message': text}),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _messages.add(ChatMessage(
          text: data['response'] ?? 'No response received.',
          isUser: false,
        ));
      } else {
        _messages.add(ChatMessage(
          text: 'Error: Could not get response. Make sure Ollama is running.',
          isUser: false,
        ));
      }
    } catch (e) {
      _messages.add(ChatMessage(
        text: 'Error: Failed to connect. Please try again.',
        isUser: false,
      ));
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
