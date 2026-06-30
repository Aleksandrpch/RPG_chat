import 'package:flutter/foundation.dart';
class ChatMessage {
  final String content;

  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;

  final DateTime timestamp;

  final String? modelId;
  final int? tokens;
  final double? cost;

  final String chatId;

  ChatMessage({
    required this.content,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    DateTime? timestamp,
    this.modelId,
    this.tokens,
    this.cost,
    required this.chatId,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'content': content,
        'sender_id': senderId,
        'sender_name': senderName,
        'sender_avatar_url': senderAvatarUrl,
        'timestamp': timestamp.toIso8601String(),
        'model_id': modelId,
        'tokens': tokens,
        'cost': cost,
        'chat_id': chatId,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    try {
      return ChatMessage(
        content: json['content'] as String,
        senderId: json['sender_id'] as String,
        senderName: json['sender_name'] as String,
        senderAvatarUrl: json['sender_avatar_url'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
        modelId: json['model_id'] as String?,
        tokens: json['tokens'] as int?,
        cost: (json['cost'] as num?)?.toDouble(),
        chatId: json['chat_id'] as String,
      );
    } catch (e) {
      debugPrint('Error decoding message: $e');
      rethrow;
    }
  }

  String get cleanContent {
    try {
      return content.trim();
    } catch (e) {
      debugPrint('Error cleaning message content: $e');
      return content;
    }
  }

  bool get isPlayer => senderId == 'player';

  bool get isNarrator => senderId == 'narrator';

  bool get isNpc =>
      senderId != 'player' &&
      senderId != 'narrator';
}