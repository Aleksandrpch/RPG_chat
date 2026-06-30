import 'package:flutter/foundation.dart';
class Character {
  final String id;
  final String name;
  final String backstory;
  final String? avatarUrl;
  final String? visualStyle;
  final List<Map<String, String>> skills;         
  final List<Map<String, String>> achievements; 
  final String visualDescription;

  Character({
    required this.id,
    required this.name,
    required this.backstory,
    this.avatarUrl,
    required this.visualStyle,
    required this.visualDescription,
    required this.skills,
    required this.achievements,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'backstory': backstory,
    'avatar_url': avatarUrl,
    'visual_style': visualStyle,
    'visual_description': visualDescription,
    'skills': skills,
    'achievements': achievements,
  };

  factory Character.fromJson(Map<String, dynamic> json) => Character(
    id: json['id'] as String, 
    name: json['name'] as String,
    backstory: json['backstory'] as String,
    avatarUrl: json['avatar_url'] as String?,
    visualStyle: json['visual_style'] as String?,
    visualDescription: json['visual_description'] as String? ?? '',
    skills: (json['skills'] as List?)?.map((e) => Map<String, String>.from(e)).toList() ?? [],
    achievements: (json['achievements'] as List?)?.map((e) => Map<String, String>.from(e)).toList() ?? [],
  );
}