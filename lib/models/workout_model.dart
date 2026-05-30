import 'dart:convert';

class WorkoutModel {
  final String id;
  final String type;
  final String category;
  final int duration; // in minutes
  final int calories;
  final DateTime date;
  final List<int> heartRateHistory;
  final String notes;

  WorkoutModel({
    required this.id,
    required this.type,
    required this.category,
    required this.duration,
    required this.calories,
    required this.date,
    this.heartRateHistory = const [],
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'duration': duration,
      'calories': calories,
      'date': date.toIso8601String(),
      'heart_rate_history': jsonEncode(heartRateHistory),
      'notes': notes,
    };
  }

  factory WorkoutModel.fromMap(Map<String, dynamic> map) {
    List<int> hrList = [];
    if (map['heart_rate_history'] != null) {
      try {
        final decoded = jsonDecode(map['heart_rate_history']);
        if (decoded is List) {
          hrList = decoded.map((e) => int.parse(e.toString())).toList();
        }
      } catch (_) {}
    }
    return WorkoutModel(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      category: map['category'] ?? '',
      duration: map['duration'] ?? 0,
      calories: map['calories'] ?? 0,
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      heartRateHistory: hrList,
      notes: map['notes'] ?? '',
    );
  }
}
