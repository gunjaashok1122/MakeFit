import '../models/body_stats_model.dart';
import '../models/workout_model.dart';

class AIService {
  static final AIService instance = AIService._init();

  AIService._init();

  Map<String, dynamic> generateWorkoutPlan({
    required double weight,
    required double height,
    required double bodyFat,
    required String fitnessLevel, // Beginner, Intermediate, Advanced
  }) {
    double bmi = BodyStatsModel.calculateBMI(weight, height);
    String targetFocus;
    List<String> routine;
    String advice;

    if (bmi >= 25.0) {
      targetFocus = 'Weight Loss & Cardiovascular Endurance';
      routine = [
        '30 min High-Intensity Interval Training (HIIT) running',
        '20 min Bodyweight circuit (Squats, Push-ups, Planks)',
        '40 min Steady-state cycling at 120-130 bpm heart rate',
      ];
      advice = 'Focus on maintaining a caloric deficit of 300-500 kcal daily. Keep hydration levels above 3 Liters.';
    } else if (bmi < 18.5) {
      targetFocus = 'Muscle Hypertrophy & Strength Building';
      routine = [
        '45 min Heavy Resistance Training (Squats, Deadlifts, Bench Press)',
        '15 min Low-intensity mobility stretches',
        '30 min Light yoga to boost muscle recovery speed',
      ];
      advice = 'Maintain a caloric surplus of 200-400 kcal. Consume high-quality proteins (1.6g per kg of bodyweight).';
    } else {
      targetFocus = 'Athletic Conditioning & Lean Mass Maintenance';
      routine = [
        '35 min Functional strength circuits',
        '25 min Medium-pace outdoor cycling or swimming',
        '15 min Core tightening and abdominal workouts',
      ];
      advice = 'Balanced macro distribution. Log water regularly and aim for a consistent sleep cycle (7-8 hours).';
    }

    return {
      'targetFocus': targetFocus,
      'routine': routine,
      'advice': advice,
      'dailyCalorieTarget': (10 * weight + 6.25 * height - 5 * 25 + (bmi > 25 ? -300 : 200)).round(), // Harris-Benedict estimate
    };
  }

  String suggestDailyHydration(double weightKg, int activeMinutes) {
    // Basic baseline water calculation: 35ml per kg of bodyweight + active workout corrections
    double waterLiters = (weightKg * 35 + (activeMinutes * 10)) / 1000.0;
    return '${waterLiters.toStringAsFixed(1)} Liters';
  }
}
