class Skill {
  final String name;
  final String description;
  final DateTime earnedAt;

  Skill({
    required this.name,
     required this.description,
     required this.earnedAt,
     });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
     'earned_at': earnedAt.toIso8601String(),
  };

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
    name: json['name'] as String,
    description: json['description'] as String,
    earnedAt: DateTime.parse(json['earned_at'] as String),
  );
}