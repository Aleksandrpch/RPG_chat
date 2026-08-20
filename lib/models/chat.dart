import 'package:flutter/foundation.dart';
class Chat {
  final String id;
  final String characterId;
  final String skeletonId;
  final String? title;
  final DateTime lastPlayed;

  Chat({
    required this.id,
    required this.characterId,
    required this.skeletonId,
    this.title,
    required this.lastPlayed,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'character_id': characterId,
    'skeleton_id': skeletonId,
    'title': title,
    'last_played': lastPlayed.toIso8601String(),
  };

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
    id: json['id'] as String,
    characterId: json['character_id'] as String,
    skeletonId: json['skeleton_id'] as String,
    title: json['title'] as String?,
    lastPlayed: DateTime.parse(json['last_played'] as String),
  );
}