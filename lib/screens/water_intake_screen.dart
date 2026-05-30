import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/fitness_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/neon_button.dart';
import '../services/notification_service.dart';
import '../models/goal_model.dart';
import '../models/water_model.dart';

class WaterIntakeScreen extends StatefulWidget {
  const WaterIntakeScreen({Key? key}) : super(key: key);

  @override
  State<WaterIntakeScreen> createState() => _WaterIntakeScreenState();
}

class _WaterIntakeScreenState extends State<WaterIntakeScreen> {
  bool _remindersEnabled = true;

  @override
  Widget build(BuildContext context) {
    final fitnessProvider = Provider.of<FitnessProvider>(context);

    // Get goal
    final waterGoal = fitnessProvider.goals.firstWhere(
      (g) => g.type == 'Water',
      orElse: () => GoalModel(id: '', type: 'Water', target: 3000, current: 2100, date: DateTime.now()),
    );

    final double percentage = (waterGoal.current / waterGoal.target).clamp(0.0, 1.0);

    // Filter today's water logs
    final now = DateTime.now();
    final todayLogs = fitnessProvider.waterLogs.where(
      (w) => w.date.year == now.year && w.date.month == now.month && w.date.day == now.day,
    ).toList();

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
                            'Water Intake',
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

                      // Hydration Ring Card
                      GlassCard(
                        child: Column(
                          children: [
                            ProgressRing(
                              percentage: percentage,
                              valueText: '${(waterGoal.current / 1000).toStringAsFixed(1)} L',
                              labelText: 'of ${(waterGoal.target / 1000).toStringAsFixed(1)} L',
                              size: 160,
                              strokeWidth: 12,
                              activeGradient: const LinearGradient(
                                colors: [Color(0xFF0077B6), AppTheme.neonBlue],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Quick control steppers
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildQuickAddButton(context, 250, 'Cup'),
                                const SizedBox(width: 16),
                                _buildQuickAddButton(context, 500, 'Bottle'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Reminder toggle card
                      GlassCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.neonBlue.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.notifications_active_outlined, color: AppTheme.neonBlue, size: 20),
                                ),
                                const SizedBox(width: 12),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Hydration Reminders', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                                    SizedBox(height: 2),
                                    Text('Receive reminder notifications daily', style: TextStyle(color: AppTheme.textGrey, fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                            Switch(
                              value: _remindersEnabled,
                              activeColor: AppTheme.neonBlue,
                              onChanged: (val) {
                                setState(() {
                                  _remindersEnabled = val;
                                });
                                if (val) {
                                  NotificationService.instance.scheduleHydrationReminder();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // History check list
                      const Text(
                        'Recent Logs',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textWhite, fontFamily: 'Outfit'),
                      ),
                      const SizedBox(height: 12),

                      if (todayLogs.isEmpty)
                        const GlassCard(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(
                              child: Text(
                                'No water logged today yet. Keep hydrated!',
                                style: TextStyle(color: AppTheme.textGrey),
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: todayLogs.length,
                          itemBuilder: (context, index) {
                            final log = todayLogs[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: GlassCard(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.local_drink_rounded, color: AppTheme.neonBlue, size: 20),
                                        const SizedBox(width: 12),
                                        Text(
                                          '${log.amount} ml',
                                          style: const TextStyle(
                                            color: AppTheme.textWhite,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '${log.date.hour}:${log.date.minute.toString().padLeft(2, '0')}',
                                          style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.neonPink, size: 20),
                                      onPressed: () {
                                        fitnessProvider.removeWater(log.id);
                                      },
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

              // Bottom add custom button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: NeonButton(
                  onTap: () {
                    // Quick add 250ml
                    fitnessProvider.addWater(250);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added 250ml water.')),
                    );
                  },
                  child: const Text(
                    'Add Water',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textWhite,
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

  Widget _buildQuickAddButton(BuildContext context, int amount, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Provider.of<FitnessProvider>(context, listen: false).addWater(amount);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added $amount ml water.')),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.cardNavy,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.cardNavyLight, width: 1.2),
          ),
          child: Column(
            children: [
              const Icon(Icons.add_rounded, color: AppTheme.neonBlue, size: 20),
              const SizedBox(height: 8),
              Text(
                '+$amount ml',
                style: const TextStyle(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(color: AppTheme.textGrey, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
