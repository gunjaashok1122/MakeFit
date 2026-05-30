import 'package:flutter/material';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/fitness_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';
import '../models/goal_model.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _targetController = TextEditingController();

  void _showAdjustGoalDialog(BuildContext context, String type, double currentTarget) {
    _targetController.text = currentTarget.toInt().toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardNavy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Adjust $type Goal',
            style: const TextStyle(color: AppTheme.textWhite, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Target value (${_getUnitSuffix(type)}):', style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.cardNavyLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _targetController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.textWhite),
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonPurple),
              onPressed: () {
                final double target = double.tryParse(_targetController.text) ?? currentTarget;
                Provider.of<FitnessProvider>(context, listen: false).updateGoalTarget(type, target);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$type target goal updated!')),
                );
              },
              child: const Text('Save', style: TextStyle(color: AppTheme.textWhite)),
            ),
          ],
        );
      },
    );
  }

  String _getUnitSuffix(String type) {
    switch (type) {
      case 'Steps':
        return 'steps';
      case 'Calories':
        return 'kcal';
      case 'Water':
        return 'ml';
      case 'Weight':
        return 'kg';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fitnessProvider = Provider.of<FitnessProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textWhite, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'My Fitness Goals',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textWhite,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Goals List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  itemCount: fitnessProvider.goals.length,
                  itemBuilder: (context, index) {
                    final goal = fitnessProvider.goals[index];
                    final double progressFactor = (goal.current / goal.target).clamp(0.0, 1.0);
                    final int percentage = (progressFactor * 100).toInt();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GlassCard(
                        onTap: () => _showAdjustGoalDialog(context, goal.type, goal.target),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _getGoalColor(goal.type).withOpacity(0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _getGoalIcon(goal.type),
                                        color: _getGoalColor(goal.type),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${goal.type} Goal',
                                      style: const TextStyle(
                                        color: AppTheme.textWhite,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Outfit',
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '$percentage%',
                                      style: TextStyle(
                                        color: _getGoalColor(goal.type),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        fontFamily: 'Outfit',
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.edit_rounded, color: AppTheme.textMuted, size: 14),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progressFactor,
                                minHeight: 8,
                                backgroundColor: AppTheme.cardNavyLight,
                                valueColor: AlwaysStoppedAnimation<Color>(_getGoalColor(goal.type)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Current: ${goal.current.toInt()} ${_getUnitSuffix(goal.type)}',
                                  style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                                ),
                                Text(
                                  'Target: ${goal.target.toInt()} ${_getUnitSuffix(goal.type)}',
                                  style: const TextStyle(color: AppTheme.textGrey, fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getGoalIcon(String type) {
    switch (type) {
      case 'Steps':
        return Icons.directions_walk_rounded;
      case 'Calories':
        return Icons.local_fire_department_rounded;
      case 'Water':
        return Icons.local_drink_rounded;
      case 'Weight':
        return Icons.monitor_weight_rounded;
      default:
        return Icons.flag_rounded;
    }
  }

  Color _getGoalColor(String type) {
    switch (type) {
      case 'Steps':
        return AppTheme.neonBlue;
      case 'Calories':
        return AppTheme.neonPink;
      case 'Water':
        return AppTheme.neonBlue;
      case 'Weight':
        return AppTheme.neonPurple;
      default:
        return AppTheme.neonPurple;
    }
  }
}
