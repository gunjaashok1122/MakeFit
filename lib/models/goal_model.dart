class GoalModel {
  final String id;
  final String type; // Steps, Calories, Water, Weight
  final double target;
  double current;
  final DateTime date;

  GoalModel({
    required this.id,
    required this.type,
    required this.target,
    this.current = 0.0,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'target': target,
      'current': current,
      'date': date.toIso8601String(),
    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      target: (map['target'] ?? 0.0).toDouble(),
      current: (map['current'] ?? 0.0).toDouble(),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }
}
