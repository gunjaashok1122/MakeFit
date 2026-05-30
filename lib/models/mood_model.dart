class MoodModel {
  final String id;
  final String mood; // Energetic, Calm, Tired, Stressed, Happy, Sad
  final DateTime date;

  MoodModel({
    required this.id,
    required this.mood,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mood': mood,
      'date': date.toIso8601String(),
    };
  }

  factory MoodModel.fromMap(Map<String, dynamic> map) {
    return MoodModel(
      id: map['id'] ?? '',
      mood: map['mood'] ?? 'Calm',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }
}
