// Импорт основных классов Flutter
import 'package:flutter/foundation.dart';

// Класс, представляющий сообщение в чате
class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? modelId;
  final int? tokens;
  final double? cost;
  final String chat_id;  
  
  ChatMessage({
    required this.content,
    required this.isUser,
    DateTime? timestamp,
    this.modelId,
    this.tokens,
    this.cost,
    required this.chat_id,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'content': content,
    'is_user': isUser ? 1 : 0,           // ← исправлено
    'timestamp': timestamp.toIso8601String(),
    'model_id': modelId,                  // ← исправлено
    'tokens': tokens,
    'cost': cost,
    'chat_id': chat_id,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    try {
      return ChatMessage(
        content: json['content'] as String,
        isUser: (json['is_user'] as int) == 1,  // ← исправлено
        timestamp: DateTime.parse(json['timestamp'] as String),
        modelId: json['model_id'] as String?,   // ← исправлено
        tokens: json['tokens'] as int?,
        cost: (json['cost'] as num?)?.toDouble(),
        chat_id: json['chat_id'] as String,
      );
    } catch (e) {
      debugPrint('Error decoding message: $e');
      rethrow;
    }
  }

  // Геттер для получения очищенного текста сообщения
  String get cleanContent {
    try {
      // Удаление лишних пробелов в начале и конце текста
      return content.trim();
    } catch (e) {
      // Логирование ошибок при очистке текста
      debugPrint('Error cleaning message content: $e');
      // Возвращение исходного текста в случае ошибки
      return content;
    }
  }
}
