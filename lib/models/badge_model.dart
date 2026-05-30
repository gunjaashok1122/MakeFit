class BadgeModel {
  final String id;
  final String title;
  final String description;
  final String iconKey; // maps to local custom icons or material icons
  final bool isUnlocked;
  final DateTime? unlockedDate;

  BadgeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconKey,
    this.isUnlocked = false,
    this.unlockedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon_key': iconKey,
      'is_unlocked': isUnlocked ? 1 : 0,
      'unlocked_date': unlockedDate?.toIso8601String(),
    };
  }

  factory BadgeModel.fromMap(Map<String, dynamic> map) {
    return BadgeModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      iconKey: map['icon_key'] ?? '',
      isUnlocked: (map['is_unlocked'] ?? 0) == 1,
      unlockedDate: map['unlocked_date'] != null 
          ? DateTime.parse(map['unlocked_date']) 
          : null,
    );
  }
}
