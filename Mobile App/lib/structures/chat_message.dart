part of 'structs.dart';

class ChatMessage {
  final String message;
  final bool isUser;
  final String? imageUrl;
  final DateTime timestamp;
  final String? senderName;

  ChatMessage({
    required this.message,
    required this.isUser,
    this.imageUrl,
    DateTime? timestamp,
    this.senderName,
  }) : timestamp = timestamp ?? DateTime.now();
}