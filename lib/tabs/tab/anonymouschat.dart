// Anonymous  chat

// ignore_for_file: unused_field

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

class AnonymousChatPage extends StatefulWidget {
  const AnonymousChatPage({super.key});

  @override
  State<AnonymousChatPage> createState() => _AnonymousChatPageState();
}

class _AnonymousChatPageState extends State<AnonymousChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;

  List<Map<String, dynamic>> messages = [
    {
      "text": "Hello, I'm here to talk with you. How are you feeling?",
      "isMe": false,
    },
  ];

  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    String userMessage = _controller.text.trim();
    setState(() {
      messages.add({"text": _controller.text.trim(), "isMe": true});
    });

    // final model1 = FirebaseAI.googleAI();
    // final modified_model = model1.generativeModel(
    //   model: 'gemini-3-flash-preview',
    // );

    final model = FirebaseVertexAI.instance.generativeModel(
      model: '	gemini-3.5-flash-preview',
    );
    // final prompt = _promptController.text.isEmpty
    //     ? 'You are a helpful assistant.'
    //     : _promptController.text;

    try {
      final response = await model.generateContent([
        Content.text('$prompt\n\nUser: $userMessage\n\nAssistant:'),
      ]);

      setState(() {
        if (response.text != null) {
          messages.add({"text": response, "isMe": false});
        }
        _isLoading = false;
        _controller.clear();
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
        messages.add({"text": 'Error generating response: $e', "isMe": false});
      });
      _scrollToBottom();
    }

    _controller.clear();

    // Simulate reply from anonymous person B
    // Future.delayed(const Duration(seconds: 2), () {
    //   String botReply = generateReply(userMessage);
    //   setState(() {
    //     messages.add({"text": botReply, "isMe": false});
    //   });
    // });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Anonymous Chat"),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isMe = messages[index]["isMe"];
                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      messages[index]["text"],
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.black12,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
