class Character {
  final String id;
  final String name;
  final String classType;
  final String backstory;
  final String? avatarUrl;
  final DateTime createdAt;
  DateTime? lastPlayed;

  Character({
    required this.id,
    required this.name,
    required this.classType,
    required this.backstory,
    this.avatarUrl,
    required this.createdAt,
    this.lastPlayed,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'class_type': classType,
    'backstory': backstory,
    'avatar_url': avatarUrl,
    'created_at': createdAt.toIso8601String(),
    'last_played': lastPlayed?.toIso8601String(),
  };

  factory Character.fromJson(Map<String, dynamic> json) => Character(
    id: json['id'] as String,
    name: json['name'] as String,
    classType: json['class_type'] as String,
    backstory: json['backstory'] as String,
    avatarUrl: json['avatar_url'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    lastPlayed: json['last_played'] != null 
        ? DateTime.parse(json['last_played'] as String) 
        : null,
  );
}