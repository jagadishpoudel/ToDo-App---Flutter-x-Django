class MySkills {
  final String id;
  final String name;
  final String skill;

  MySkills({
    required this.id,
    required this.name,
    required this.skill,
  });

  factory MySkills.fromJson(Map<String, dynamic> json) {
    return MySkills(
      id: json['id'],
      name: json['name'],
      skill: json['skill'],
    );
  }
}