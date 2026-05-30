import 'package:flutter/material';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/fitness_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/fitness_line_chart.dart';
import '../widgets/neon_button.dart';
import '../models/workout_model.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  final String workoutId;

  const WorkoutDetailsScreen({Key? key, required this.workoutId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fitnessProvider = Provider.of<FitnessProvider>(context);
    
    // Find workout
    final workout = fitnessProvider.workouts.firstWhere(
      (w) => w.id == workoutId,
      orElse: () => WorkoutModel(
        id: '',
        type: 'Running Session',
        category: 'Running',
        duration: 45,
        calories: 450,
        date: DateTime.now(),
        heartRateHistory: [110, 115, 128, 135, 142, 138, 125, 130, 118],
        notes: 'Felt great. Strong pace.',
      ),
    );

    // Peak and average heart rate computations
    int peakHr = workout.heartRateHistory.isNotEmpty
        ? workout.heartRateHistory.reduce((a, b) => a > b ? a : b)
        : 142;
    int avgHr = workout.heartRateHistory.isNotEmpty
        ? (workout.heartRateHistory.reduce((a, b) => a + b) / workout.heartRateHistory.length).round()
        : 128;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textWhite, size: 20),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Text(
                            'Workout Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textWhite,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          const SizedBox(width: 48), // spacer balance
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Workout Banner card
                      GlassCard(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.neonPurple.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getCategoryIcon(workout.category),
                                color: AppTheme.neonPurple,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    workout.type,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textWhite,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${workout.date.day}/${workout.date.month}/${workout.date.year} | ${workout.date.hour}:${workout.date.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Duration & Calories metrics grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              label: 'Duration',
                              value: '${workout.duration} min',
                              icon: Icons.timer_outlined,
                              color: AppTheme.neonBlue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildMetricCard(
                              label: 'Energy Burned',
                              value: '${workout.calories} kcal',
                              icon: Icons.local_fire_department_rounded,
                              color: AppTheme.neonPink,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildMetricCard(
                              label: 'Avg Heart Rate',
                              value: '$avgHr bpm',
                              icon: Icons.favorite_border_rounded,
                              color: AppTheme.neonPurple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Heart Rate Progression Chart
                      const Text(
                        'Heart Rate (bpm)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite, fontFamily: 'Outfit'),
                      ),
                      const SizedBox(height: 12),
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Workout Intensity', style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                                Text(
                                  'Peak: $peakHr bpm',
                                  style: const TextStyle(color: AppTheme.neonPink, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            FitnessLineChart(
                              spots: workout.heartRateHistory.map((e) => e.toDouble()).toList(),
                              xLabels: List.generate(workout.heartRateHistory.length, (index) => '${index * 5}m'),
                              lineColor: AppTheme.neonPink,
                              gradientColors: const [Color(0xFF900C3F), AppTheme.neonPink],
                              minY: 60,
                              maxY: 180,
                              tooltipSuffix: ' bpm',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Workout Notes section
                      const Text(
                        'Session Notes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite, fontFamily: 'Outfit'),
                      ),
                      const SizedBox(height: 12),
                      GlassCard(
                        child: Text(
                          workout.notes.isNotEmpty
                              ? workout.notes
                              : 'No notes logged for this workout session.',
                          style: const TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Delete button actions
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: NeonButton(
                  isSecondary: true,
                  onTap: () {
                    // Trigger delete
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppTheme.cardNavy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('Delete Workout', style: TextStyle(color: AppTheme.textWhite)),
                        content: const Text('Are you sure you want to delete this workout log? This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonPink),
                            onPressed: () {
                              Provider.of<FitnessProvider>(context, listen: false).deleteWorkout(workout.id);
                              Navigator.of(context).pop(); // pop dialog
                              Navigator.of(context).pop(); // pop screen
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Workout deleted.')),
                              );
                            },
                            child: const Text('Delete', style: TextStyle(color: AppTheme.textWhite)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    'Delete Workout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neonPink,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.textGrey, fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textWhite,
              fontFamily: 'Outfit',
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Running':
        return Icons.directions_run_rounded;
      case 'Cycling':
        return Icons.directions_bike_rounded;
      case 'Yoga':
        return Icons.spa_rounded;
      case 'Gym':
        return Icons.fitness_center_rounded;
      default:
        return Icons.accessibility_new_rounded;
    }
  }
}
