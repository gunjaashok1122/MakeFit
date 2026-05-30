class BodyStatsModel {
  final String id;
  final double weight; // in kg
  final double height; // in cm
  final double bmi;
  final double bodyFat; // percentage
  final double muscleMass; // in kg
  final DateTime date;

  BodyStatsModel({
    required this.id,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.bodyFat,
    required this.muscleMass,
    required this.date,
  });

  static double calculateBMI(double weightKg, double heightCm) {
    if (heightCm <= 0) return 0.0;
    double heightMeters = heightCm / 100.0;
    return weightKg / (heightMeters * heightMeters);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'height': height,
      'bmi': bmi,
      'body_fat': bodyFat,
      'muscle_mass': muscleMass,
      'date': date.toIso8601String(),
    };
  }

  factory BodyStatsModel.fromMap(Map<String, dynamic> map) {
    return BodyStatsModel(
      id: map['id'] ?? '',
      weight: (map['weight'] ?? 0.0).toDouble(),
      height: (map['height'] ?? 0.0).toDouble(),
      bmi: (map['bmi'] ?? 0.0).toDouble(),
      bodyFat: (map['body_fat'] ?? 0.0).toDouble(),
      muscleMass: (map['muscle_mass'] ?? 0.0).toDouble(),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }
}
