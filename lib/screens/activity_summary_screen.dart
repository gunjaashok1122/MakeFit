import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/fitness_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/fitness_line_chart.dart';
import '../models/activity_model.dart';
import '../models/workout_model.dart';
import 'workout_details_screen.dart';
import 'add_workout_screen.dart';

class ActivitySummaryScreen extends StatefulWidget {
  const ActivitySummaryScreen({Key? key}) : super(key: key);

  @override
  State<ActivitySummaryScreen> createState() => _ActivitySummaryScreenState();
}

class _ActivitySummaryScreenState extends State<ActivitySummaryScreen> {
  String _filter = 'Weekly'; // Daily, Weekly, Monthly

  @override
  Widget build(BuildContext context) {
    final fitnessProvider = Provider.of<FitnessProvider>(context);

    // Calculate Y spots for line charts (last 7 days steps & calories)
    final now = DateTime.now();
    List<double> stepsSpots = [];
    List<double> caloriesSpots = [];
    List<String> xLabels = [];

    // Filter length determination
    int daysCount = _filter == 'Daily' ? 3 : (_filter == 'Monthly' ? 12 : 7);
    int interval = _filter == 'Monthly' ? 2 : 1;

    for (int i = daysCount - 1; i >= 0; i -= interval) {
      final day = now.subtract(Duration(days: i));
      
      // Calculate daily steps from activity logs
      final dayLogs = fitnessProvider.activities.where(
        (a) => a.date.year == day.year && a.date.month == day.month && a.date.day == day.day,
      );
      double daySteps = 0;
      double dayCals = 0;

      for (var l in dayLogs) {
        daySteps += l.steps;
        dayCals += l.calories;
      }

      // Add workout calories
      final dayWorkouts = fitnessProvider.workouts.where(
        (w) => w.date.year == day.year && w.date.month == day.month && w.date.day == day.day,
      );
      for (var w in dayWorkouts) {
        dayCals += w.calories;
      }

      stepsSpots.add(daySteps);
      caloriesSpots.add(dayCals);
      
      // Label formatting
      if (_filter == 'Monthly') {
        xLabels.add('${day.day}/${day.month}');
      } else {
        xLabels.add(_getWeekdayAbbreviation(day.weekday));
      }
    }

    // Default fallbacks if empty
    if (stepsSpots.isEmpty) {
      stepsSpots = [4000, 7500, 5200, 8500, 7200, 10000, 6800];
      caloriesSpots = [250, 450, 310, 520, 380, 600, 400];
      xLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    }

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
                // Top header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textWhite, size: 20),
                      onPressed: () {
                        // In dashboard navigation, back button might just go to first tab
                      },
                    ),
                    const Text(
                      'Activity Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textWhite,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_rounded, color: AppTheme.neonPurple, size: 28),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const AddWorkoutScreen()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Filter Selector Tabs
                Row(
                  children: ['Daily', 'Weekly', 'Monthly'].map((f) {
                    final bool isSelected = _filter == f;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _filter = f;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.neonPurple : AppTheme.cardNavy,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? Colors.transparent : AppTheme.cardNavyLight,
                                width: 1.2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                f,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppTheme.textWhite : AppTheme.textGrey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Steps Line Chart Card
                const Text(
                  'Steps',
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
                          const Text('Steps Log', style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                          Text(
                            'Avg: ${(stepsSpots.reduce((a, b) => a + b) / stepsSpots.length).round()}',
                            style: const TextStyle(color: AppTheme.neonBlue, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FitnessLineChart(
                        spots: stepsSpots,
                        xLabels: xLabels,
                        lineColor: AppTheme.neonBlue,
                        gradientColors: const [Color(0xFF0077B6), AppTheme.neonBlue],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Calories Line Chart Card
                const Text(
                  'Calories Burned',
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
                          const Text('Energy Expenditure', style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                          Text(
                            'Total: ${caloriesSpots.reduce((a, b) => a + b).toInt()} kcal',
                            style: const TextStyle(color: AppTheme.neonPink, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FitnessLineChart(
                        spots: caloriesSpots,
                        xLabels: xLabels,
                        lineColor: AppTheme.neonPink,
                        gradientColors: const [Color(0xFF900C3F), AppTheme.neonPink],
                        tooltipSuffix: ' kcal',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Workout Sessions Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Workout Sessions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textWhite, fontFamily: 'Outfit'),
                    ),
                    Text(
                      '${fitnessProvider.workouts.length} Sessions',
                      style: const TextStyle(fontSize: 14, color: AppTheme.textGrey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Workout Sessions List
                if (fitnessProvider.workouts.isEmpty)
                  const GlassCard(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'No workouts logged. Let\'s get active!',
                          style: TextStyle(color: AppTheme.textGrey),
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: fitnessProvider.workouts.length,
                    itemBuilder: (context, index) {
                      final workout = fitnessProvider.workouts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GlassCard(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => WorkoutDetailsScreen(workoutId: workout.id),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.neonPurple.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getWorkoutCategoryIcon(workout.category),
                                  color: AppTheme.neonPurple,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      workout.type,
                                      style: const TextStyle(
                                        color: AppTheme.textWhite,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${workout.duration} min | ${workout.date.day}/${workout.date.month}/${workout.date.year}',
                                      style: const TextStyle(
                                        color: AppTheme.textGrey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${workout.calories}',
                                    style: const TextStyle(
                                      color: AppTheme.neonPink,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text('kcal', style: TextStyle(color: AppTheme.textGrey, fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getWeekdayAbbreviation(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  IconData _getWorkoutCategoryIcon(String category) {
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
