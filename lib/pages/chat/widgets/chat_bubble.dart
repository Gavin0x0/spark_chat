import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.role, required this.content});

  final String role;
  final String content;

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case 'user':
        return _buildUserBubble();
      case 'assistant':
        return _buildAssistantBubble();
      default:
        return Container();
    }
  }

  Widget _buildUserBubble() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(top: 10, right: 10, left: 20),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        constraints: BoxConstraints(
          maxWidth: Get.width * 0.8,
        ),
        child: Text(
          content,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAssistantBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 10, left: 10, right: 20),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        constraints: BoxConstraints(
          maxWidth: Get.width * 0.8,
        ),
        child: Text(
          content,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
