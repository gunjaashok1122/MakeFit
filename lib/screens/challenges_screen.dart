import 'package:flutter/material';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/fitness_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({Key? key}) : super(key: key);

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
                      'Fitness Challenges',
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
              ),

              // Challenges List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20.0),
                  itemCount: fitnessProvider.challenges.length,
                  itemBuilder: (context, index) {
                    final challenge = fitnessProvider.challenges[index];
                    final double progress = (challenge.currentValue / challenge.targetValue).clamp(0.0, 1.0);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GlassCard(
                        borderColor: challenge.isCompleted 
                            ? Colors.green.withOpacity(0.3)
                            : (challenge.isJoined ? AppTheme.neonPurple.withOpacity(0.3) : const Color(0x1BFFFFFF)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        challenge.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textWhite,
                                          fontFamily: 'Outfit',
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${challenge.daysRemaining} days remaining',
                                        style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                if (challenge.isCompleted)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Completed',
                                      style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  )
                                else ...[
                                  TextButton(
                                    onPressed: () {
                                      fitnessProvider.joinChallenge(challenge.id);
                                    },
                                    child: Text(
                                      challenge.isJoined ? 'Leave' : 'Join',
                                      style: TextStyle(
                                        color: challenge.isJoined ? AppTheme.neonPink : AppTheme.neonPurple,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              challenge.description,
                              style: const TextStyle(color: AppTheme.textGrey, fontSize: 13, height: 1.4),
                            ),
                            if (challenge.isJoined) ...[
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Progress: ${challenge.currentValue.toInt()} / ${challenge.targetValue.toInt()} ${_getChallengeSuffix(challenge.type)}',
                                    style: const TextStyle(color: AppTheme.textWhite, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${(progress * 100).toInt()}%',
                                    style: TextStyle(color: AppTheme.neonPurple, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 6,
                                  backgroundColor: AppTheme.cardNavyLight,
                                  color: challenge.isCompleted ? Colors.green : AppTheme.neonPurple,
                                ),
                              ),
                            ],
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

  String _getChallengeSuffix(String type) {
    switch (type) {
      case 'Water':
        return 'ml';
      case 'Steps':
        return 'steps';
      case 'Workout':
        return 'workouts';
      default:
        return '';
    }
  }
}
