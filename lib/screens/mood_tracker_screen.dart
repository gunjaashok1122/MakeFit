import 'package:flutter/material';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/fitness_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';
import '../models/mood_model.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({Key? key}) : super(key: key);

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  String _selectedMood = 'Calm';

  final List<Map<String, dynamic>> _moods = [
    {'name': 'Energetic', 'icon': Icons.bolt_rounded, 'color': Colors.orange},
    {'name': 'Calm', 'icon': Icons.spa_rounded, 'color': AppTheme.neonBlue},
    {'name': 'Tired', 'icon': Icons.bedtime_rounded, 'color': AppTheme.neonPurple},
    {'name': 'Stressed', 'icon': Icons.psychology_rounded, 'color': AppTheme.neonPink},
    {'name': 'Happy', 'icon': Icons.sentiment_very_satisfied_rounded, 'color': Colors.green},
    {'name': 'Sad', 'icon': Icons.sentiment_very_dissatisfied_rounded, 'color': Colors.blueGrey},
  ];

  void _saveMoodLog() {
    final fitnessProvider = Provider.of<FitnessProvider>(context, listen: false);
    fitnessProvider.addMoodLog(_selectedMood);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mood saved successfully!'),
        backgroundColor: AppTheme.deepPurple,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fitnessProvider = Provider.of<FitnessProvider>(context);

    // Filter logs for today
    final now = DateTime.now();
    final todayMoods = fitnessProvider.moodLogs.where(
      (m) => m.date.year == now.year && m.date.month == now.month && m.date.day == now.day,
    ).toList();

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
                      'Mood Tracker',
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

                // Log Mood Card
                const Text(
                  'How are you feeling today?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite, fontFamily: 'Outfit'),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  child: Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: _moods.length,
                        itemBuilder: (context, index) {
                          final m = _moods[index];
                          final bool isSelected = _selectedMood == m['name'];
                          return GestureDetector(
                            onTap: () => setState(() => _selectedMood = m['name']),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? m['color'].withOpacity(0.2) 
                                    : AppTheme.cardNavy,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? m['color'] : const Color(0x1BFFFFFF),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    m['icon'],
                                    color: isSelected ? m['color'] : AppTheme.textGrey,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    m['name'],
                                    style: TextStyle(
                                      color: isSelected ? AppTheme.textWhite : AppTheme.textGrey,
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      NeonButton(
                        onTap: _saveMoodLog,
                        child: const Text('Save Mood Log', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Health analytics correlation advice
                const Text(
                  'Mood & Workout Correlation',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite, fontFamily: 'Outfit'),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.neonPurple.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.insights_rounded, color: AppTheme.neonPurple, size: 24),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Your logs show that exercising for 30+ minutes when feeling "Stressed" or "Tired" helps boost your energy levels and shifts mood back to "Calm" or "Happy". Try a light Yoga session today!',
                          style: TextStyle(color: AppTheme.textGrey, fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Today's history
                const Text(
                  'Today\'s Mood History',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite, fontFamily: 'Outfit'),
                ),
                const SizedBox(height: 12),
                if (todayMoods.isEmpty)
                  const GlassCard(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(
                        child: Text('No mood logs logged today yet.', style: TextStyle(color: AppTheme.textGrey)),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: todayMoods.length,
                    itemBuilder: (context, index) {
                      final m = todayMoods[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.circle, color: AppTheme.neonPurple, size: 10),
                              const SizedBox(width: 12),
                              Text(
                                'Felt ${m.mood}',
                                style: const TextStyle(color: AppTheme.textWhite, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Text(
                                '${m.date.hour}:${m.date.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
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
}
