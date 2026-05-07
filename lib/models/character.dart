class Character {
  final String id;
  final String name;
  final String backstory;
  final String? avatarUrl;
  final DateTime createdAt;
  final String visualDescription;

  Character({
    required this.id,
    required this.name,
    required this.backstory,
    this.avatarUrl,
    required this.visualStyle,
    required this.visualDescription,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'backstory': backstory,
    'avatar_url': avatarUrl,
    'last_played': lastPlayed?.toIso8601String(),
    'visual_style': visualStyle,
    'visual_description': visualDescription,
  };

  factory Character.fromJson(Map<String, dynamic> json) => Character(
    id: json['id'] as String, 
    name: json['name'] as String,
    backstory: json['backstory'] as String,
    avatarUrl: json['avatar_url'] as String?,
    visualStyle: json['visual_style'] as String?,
    visualDescription: json['visual_description'] as String? ?? '',
  );
}