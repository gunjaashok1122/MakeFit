import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/fitness_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/fitness_bar_chart.dart';
import '../models/goal_model.dart';
import '../models/activity_model.dart';
import 'worklist_screen.dart';
import 'log_activity_screen.dart';
import 'water_intake_screen.dart';
import 'body_stats_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final fitnessProvider = Provider.of<FitnessProvider>(context);

    // Fetch step goal
    final stepGoal = fitnessProvider.goals.firstWhere(
      (g) => g.type == 'Steps',
      orElse: () => GoalModel(id: '', type: 'Steps', target: 10000, current: 0, date: DateTime.now()),
    );
    final calorieGoal = fitnessProvider.goals.firstWhere(
      (g) => g.type == 'Calories',
      orElse: () => GoalModel(id: '', type: 'Calories', target: 900, current: 0, date: DateTime.now()),
    );
    final waterGoal = fitnessProvider.goals.firstWhere(
      (g) => g.type == 'Water',
      orElse: () => GoalModel(id: '', type: 'Water', target: 3000, current: 0, date: DateTime.now()),
    );

    // Calculate percentage
    final double stepPercentage = (stepGoal.current / stepGoal.target).clamp(0.0, 1.0);
    final int stepDisplayPercent = (stepPercentage * 100).toInt();

    // Map weekly steps for bar chart
    List<double> barValues = [0, 0, 0, 0, 0, 0, 0];
    List<String> barLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayLog = fitnessProvider.activities.firstWhere(
        (a) => a.date.year == day.year && a.date.month == day.month && a.date.day == day.day,
        orElse: () => ActivityModel(id: '', type: '', steps: 0, calories: 0, duration: 0, date: day),
      );
      // Let's plot active duration or steps divided by 100 to fit on scale
      barValues[i] = dayLog.steps.toDouble();
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
                // Top header greeting
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${authProvider.userName}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textWhite,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Keep going, you\'re doing great!',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                    // Settings & Notification actions
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.cardNavyLight.withOpacity(0.5),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.settings_outlined, color: AppTheme.textWhite, size: 20),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const SettingsScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.cardNavyLight.withOpacity(0.5),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.textWhite),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No new alerts. Stay active!'),
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (!fitnessProvider.isConnected)
                              Positioned(
                                right: 4,
                                top: 4,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.neonPink,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Main Rings & Stats Card
                GlassCard(
                  child: Row(
                    children: [
                      // Today's Progress Ring
                      ProgressRing(
                        percentage: stepPercentage,
                        valueText: '$stepDisplayPercent%',
                        labelText: "Today's Goal",
                        size: 130,
                        strokeWidth: 10,
                      ),
                      const SizedBox(width: 24),
                      // Stats info side list
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSideStatRow(
                              icon: Icons.local_fire_department_rounded,
                              iconColor: AppTheme.neonPink,
                              title: 'Calories',
                              value: '${calorieGoal.current.toInt()} / ${calorieGoal.target.toInt()} kcal',
                            ),
                            const SizedBox(height: 16),
                            _buildSideStatRow(
                              icon: Icons.directions_walk_rounded,
                              iconColor: AppTheme.neonBlue,
                              title: 'Steps',
                              value: '${stepGoal.current.toInt()} / ${stepGoal.target.toInt()}',
                            ),
                            const SizedBox(height: 16),
                            _buildSideStatRow(
                              icon: Icons.timer_outlined,
                              iconColor: AppTheme.neonPurple,
                              title: 'Workouts',
                              value: '${(calorieGoal.current * 0.06).round()} / 60 min',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Actions Title
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textWhite,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Actions grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQuickActionButton(
                      context: context,
                      icon: Icons.assignment_rounded,
                      color: AppTheme.neonPurple,
                      label: 'Worklist',
                      screen: const WorklistScreen(),
                    ),
                    _buildQuickActionButton(
                      context: context,
                      icon: Icons.directions_run_rounded,
                      color: AppTheme.neonPink,
                      label: 'Log Activity',
                      screen: const LogActivityScreen(),
                    ),
                    _buildQuickActionButton(
                      context: context,
                      icon: Icons.local_drink_rounded,
                      color: AppTheme.neonBlue,
                      label: 'Water',
                      screen: const WaterIntakeScreen(),
                    ),
                    _buildQuickActionButton(
                      context: context,
                      icon: Icons.monitor_weight_outlined,
                      color: AppTheme.neonPurple,
                      label: 'Body Status',
                      screen: const BodyStatsScreen(),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Activity Overview
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Activity Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textWhite,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    Text(
                      'This Week',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.neonPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Weekly Bar Chart
                GlassCard(
                  child: FitnessBarChart(
                    values: barValues,
                    xLabels: barLabels,
                    maxVal: 15000,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSideStatRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: AppTheme.textGrey, fontSize: 11, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String label,
    required Widget screen,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 12),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => screen),
            );
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
