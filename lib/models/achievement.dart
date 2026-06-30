import 'package:flutter/foundation.dart';
class Achievement {
  final String name;
  final String description;
  final DateTime earnedAt;

  Achievement({
    required this.name,
    required this.description,
    required this.earnedAt,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'earned_at': earnedAt.toIso8601String(),
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    name: json['name'] as String,
    description: json['description'] as String,
    earnedAt: DateTime.parse(json['earned_at'] as String),
  );
}