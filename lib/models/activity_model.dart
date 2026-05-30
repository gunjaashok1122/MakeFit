class ActivityModel {
  final String id;
  final String type;
  final int steps;
  final int calories;
  final int duration; // in minutes
  final DateTime date;

  ActivityModel({
    required this.id,
    required this.type,
    required this.steps,
    required this.calories,
    required this.duration,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'steps': steps,
      'calories': calories,
      'duration': duration,
      'date': date.toIso8601String(),
    };
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      steps: map['steps'] ?? 0,
      calories: map['calories'] ?? 0,
      duration: map['duration'] ?? 0,
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }
}
