import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/fitness_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/fitness_line_chart.dart';
import '../widgets/neon_button.dart';
import '../models/sleep_model.dart';

class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({Key? key}) : super(key: key);

  @override
  State<SleepTrackerScreen> createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  double _duration = 7.5; // default hours
  String _selectedQuality = 'Good';

  final List<String> _qualities = ['Poor', 'Fair', 'Good', 'Excellent'];

  void _saveSleepLog() {
    final fitnessProvider = Provider.of<FitnessProvider>(context, listen: false);
    fitnessProvider.addSleepLog(_duration, _selectedQuality);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sleep log saved successfully!'), backgroundColor: AppTheme.neonPurple),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fitnessProvider = Provider.of<FitnessProvider>(context);

    // Filter sleep logs for line chart
    List<double> sleepSpots = [];
    List<String> sleepLabels = [];
    final reversedSleep = List.from(fitnessProvider.sleepLogs.reversed);

    for (var s in reversedSleep) {
      sleepSpots.add(s.duration);
      sleepLabels.add('${s.date.day}/${s.date.month}');
    }

    if (sleepSpots.isEmpty) {
      sleepSpots = [7.0, 6.5, 7.8, 8.0, 6.0, 7.2, 7.5];
      sleepLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textWhite, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'Sleep Tracker',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textWhite,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.home_outlined, color: AppTheme.textWhite, size: 22),
                      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sleep input form
                const Text(
                  'Log Last Night\'s Sleep',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite, fontFamily: 'Outfit'),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Duration selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Hours Slept', style: TextStyle(color: AppTheme.textGrey, fontSize: 14)),
                          Text(
                            '${_duration.toStringAsFixed(1)} hrs',
                            style: const TextStyle(color: AppTheme.neonBlue, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Outfit'),
                          ),
                        ],
                      ),
                      Slider(
                        value: _duration,
                        min: 4.0,
                        max: 12.0,
                        divisions: 16,
                        activeColor: AppTheme.neonBlue,
                        inactiveColor: AppTheme.cardNavyLight,
                        onChanged: (val) {
                          setState(() {
                            _duration = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Quality selector
                      const Text('Sleep Quality', style: TextStyle(color: AppTheme.textGrey, fontSize: 14)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _qualities.map((q) {
                          final bool isSelected = _selectedQuality == q;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedQuality = q),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppTheme.neonPurple : AppTheme.cardNavy,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected ? Colors.transparent : const Color(0x1BFFFFFF),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      q,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                      NeonButton(
                        onTap: _saveSleepLog,
                        child: const Text('Save Sleep Log', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Sleep analytics chart
                const Text(
                  'Weekly Sleep Analysis',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite, fontFamily: 'Outfit'),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  child: FitnessLineChart(
                    spots: sleepSpots,
                    xLabels: sleepLabels,
                    lineColor: AppTheme.neonBlue,
                    gradientColors: const [Color(0xFF0077B6), AppTheme.neonBlue],
                    minY: 4,
                    maxY: 12,
                    tooltipSuffix: ' hrs',
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
}
