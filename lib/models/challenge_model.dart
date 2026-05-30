class ChallengeModel {
  final String id;
  final String title;
  final String description;
  final String type; // Water, Steps, Workout
  final double targetValue;
  final double currentValue;
  final int daysRemaining;
  final bool isJoined;
  final bool isCompleted;

  ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.daysRemaining,
    this.isJoined = false,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'target_value': targetValue,
      'current_value': currentValue,
      'days_remaining': daysRemaining,
      'is_joined': isJoined ? 1 : 0,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory ChallengeModel.fromMap(Map<String, dynamic> map) {
    return ChallengeModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? '',
      targetValue: (map['target_value'] ?? 0.0).toDouble(),
      currentValue: (map['current_value'] ?? 0.0).toDouble(),
      daysRemaining: map['days_remaining'] ?? 0,
      isJoined: (map['is_joined'] ?? 0) == 1,
      isCompleted: (map['is_completed'] ?? 0) == 1,
    );
  }
}
