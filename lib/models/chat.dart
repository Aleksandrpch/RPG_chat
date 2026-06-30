import 'package:flutter/foundation.dart';
class Chat {
  final String id;
  final String characterId;
  final String worldId;
  final String? title;
  final DateTime lastActivity;

  Chat({
    required this.id,
    required this.characterId,
    required this.worldId,
    this.title,
    required this.lastActivity,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'character_id': characterId,
    'world_id': worldId,
    'title': title,
    'last_activity': lastActivity.toIso8601String(),
  };

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
    id: json['id'] as String,
    characterId: json['character_id'] as String,
    worldId: json['world_id'] as String,
    title: json['title'] as String?,
    lastActivity: DateTime.parse(json['last_activity'] as String),
  );
}