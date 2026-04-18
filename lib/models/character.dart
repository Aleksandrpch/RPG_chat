class Character {
  final String id;
    final String worldId;
  final String name;
  final String classType;
  final String backstory;
  final String? avatarUrl;
  final DateTime createdAt;
  final String visualDescription;
  final bool useLoreBasedStory;
  final List<Map<String, String>> skills;
  final List<Map<String, String>> achievements;
  DateTime? lastPlayed;

  Character({
    required this.id,
    required this.name,
    required this.worldId, 
    required this.classType,
    required this.backstory,
    this.avatarUrl,
    required this.createdAt,
    required this.visualDescription,
    this.lastPlayed,
    required this.useLoreBasedStory,
    required this.skills,
    required this.achievements,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'world_id': worldId,
    'name': name,
    'class_type': classType,
    'backstory': backstory,
    'avatar_url': avatarUrl,
    'created_at': createdAt.toIso8601String(),
    'last_played': lastPlayed?.toIso8601String(),
    'visual_description': visualDescription,
    'use_lore_based_story': useLoreBasedStory,
    'skills': skills,
    'achievements': achievements,
  };

  factory Character.fromJson(Map<String, dynamic> json) => Character(
    id: json['id'] as String,
    worldId: json['world_id'] as String, 
    name: json['name'] as String,
    classType: json['class_type'] as String,
    backstory: json['backstory'] as String,
    avatarUrl: json['avatar_url'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    visualDescription: json['visual_description'] as String? ?? '',
    useLoreBasedStory: json['use_lore_based_story'] as bool? ?? false,
    lastPlayed: json['last_played'] != null 
        ? DateTime.parse(json['last_played'] as String) 
        : null,
    skills: (json['skills'] as List?)?.map((e) => Map<String, String>.from(e)).toList() ?? [],
    achievements: (json['achievements'] as List?)?.map((e) => Map<String, String>.from(e)).toList() ?? [],
  );
}