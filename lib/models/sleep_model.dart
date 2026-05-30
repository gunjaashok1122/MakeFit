class SleepModel {
  final String id;
  final double duration; // hours
  final String quality; // Poor, Fair, Good, Excellent
  final DateTime date;

  SleepModel({
    required this.id,
    required this.duration,
    required this.quality,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'duration': duration,
      'quality': quality,
      'date': date.toIso8601String(),
    };
  }

  factory SleepModel.fromMap(Map<String, dynamic> map) {
    return SleepModel(
      id: map['id'] ?? '',
      duration: (map['duration'] ?? 0.0).toDouble(),
      quality: map['quality'] ?? 'Good',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }
}
