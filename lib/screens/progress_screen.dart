import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/fitness_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/fitness_line_chart.dart';
import '../widgets/progress_ring.dart';
import '../models/body_stats_model.dart';


class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String _activeFilter = 'Month'; // Week, Month

  @override
  Widget build(BuildContext context) {
    final fitnessProvider = Provider.of<FitnessProvider>(context);

    // Filter weights list for chart
    List<double> weightSpots = [];
    List<String> weightLabels = [];

    final reversedStats = List.from(fitnessProvider.bodyStats.reversed);
    for (var s in reversedStats) {
      weightSpots.add(s.weight);
      weightLabels.add('${s.date.day}/${s.date.month}');
    }

    // Default weight chart fallbacks
    if (weightSpots.isEmpty) {
      weightSpots = [74.5, 74.1, 73.6, 73.2, 72.8, 72.5];
      weightLabels = ['1 May', '8 May', '15 May', '22 May', '29 May', 'Today'];
    }

    // Calculate workouts completed
    int workoutsCount = fitnessProvider.workouts.length;
    double workoutCompletionFactor = (workoutsCount / 12.0).clamp(0.0, 1.0); // target 12 workouts a month



    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textWhite, size: 20),
                      onPressed: () {
                        // Left back spacer
                      },
                    ),
                    const Text(
                      'Progress Analytics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textWhite,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_month_rounded, color: AppTheme.neonPurple, size: 22),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Month / Week filters
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildFilterToggle('Week'),
                    const SizedBox(width: 8),
                    _buildFilterToggle('Month'),
                  ],
                ),
                const SizedBox(height: 20),

                // Overall progress circle stats card
                GlassCard(
                  child: Row(
                    children: [
                      ProgressRing(
                        percentage: workoutCompletionFactor,
                        valueText: '${(workoutCompletionFactor * 100).toInt()}%',
                        labelText: 'Workouts',
                        size: 110,
                        strokeWidth: 9,
                        activeGradient: AppTheme.accentGradient,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Overall Progress',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textWhite,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Great job! You\'re on track with your fitness goals this month.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textGrey,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '$workoutsCount / 12 workouts completed',
                              style: const TextStyle(
                                color: AppTheme.neonPink,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Weight progression line chart
                const Text(
                  'Weight Progress (kg)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite, fontFamily: 'Outfit'),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  child: FitnessLineChart(
                    spots: weightSpots,
                    xLabels: weightLabels,
                    lineColor: AppTheme.neonPurple,
                    gradientColors: const [AppTheme.deepPurple, AppTheme.neonPurple],
                    minY: 65,
                    maxY: 80,
                    tooltipSuffix: ' kg',
                  ),
                ),
                const SizedBox(height: 24),

                // Saved list task completion charts
                ...fitnessProvider.savedTasks.map((item) {
                  final name = item['name'] as String? ?? 'Workout';
                  final timeVal = double.tryParse(item['time']?.toString() ?? '0') ?? 0.0;
                  final completedDays = Map<String, dynamic>.from(item['completedDays'] ?? {});
                  
                  final List<double> taskSpots = [];
                  for (int i = 0; i < 7; i++) {
                    final bool isDone = completedDays[i.toString()] == true;
                    taskSpots.add(isDone ? timeVal : 0.0);
                  }
                  
                  final taskLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '$name Progress (min)',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite, fontFamily: 'Outfit'),
                      ),
                      const SizedBox(height: 12),
                      GlassCard(
                        child: FitnessLineChart(
                          spots: taskSpots,
                          xLabels: taskLabels,
                          lineColor: AppTheme.neonPink,
                          gradientColors: const [AppTheme.neonPink, Colors.pinkAccent],
                          minY: 0,
                          maxY: timeVal > 0 ? timeVal * 1.25 : 30.0,
                          tooltipSuffix: ' min',
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                }).toList(),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterToggle(String filter) {
    final bool isSelected = _activeFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = filter;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.neonPurple.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.neonPurple : AppTheme.cardNavyLight,
            width: 1.2,
          ),
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: isSelected ? AppTheme.textWhite : AppTheme.textGrey,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
