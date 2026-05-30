import 'package:flutter/material';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/fitness_provider.dart';
import '../widgets/glass_card.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({Key? key}) : super(key: key);

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
                      'Achievements & Badges',
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

              // Badges grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: fitnessProvider.badges.length,
                  itemBuilder: (context, index) {
                    final badge = fitnessProvider.badges[index];
                    return GlassCard(
                      borderColor: badge.isUnlocked
                          ? AppTheme.neonPurple.withOpacity(0.4)
                          : const Color(0x1BFFFFFF),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Badge Icon
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Opacity(
                                opacity: badge.isUnlocked ? 1.0 : 0.25,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: _getBadgeGlowColor(badge.iconKey).withOpacity(0.12),
                                    shape: BoxShape.circle,
                                    boxShadow: badge.isUnlocked
                                        ? [
                                            BoxShadow(
                                              color: _getBadgeGlowColor(badge.iconKey).withOpacity(0.2),
                                              blurRadius: 15,
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: Icon(
                                    _getBadgeIcon(badge.iconKey),
                                    color: _getBadgeGlowColor(badge.iconKey),
                                    size: 36,
                                  ),
                                ),
                              ),
                              if (!badge.isUnlocked)
                                const Icon(
                                  Icons.lock_rounded,
                                  color: AppTheme.textGrey,
                                  size: 24,
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Title
                          Text(
                            badge.title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: badge.isUnlocked ? AppTheme.textWhite : AppTheme.textGrey,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Description
                          Expanded(
                            child: Text(
                              badge.description,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textGrey,
                              ),
                            ),
                          ),
                          if (badge.isUnlocked && badge.unlockedDate != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Unlocked: ${badge.unlockedDate!.day}/${badge.unlockedDate!.month}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
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

  IconData _getBadgeIcon(String key) {
    switch (key) {
      case 'early_bird':
        return Icons.wb_sunny_rounded;
      case 'water_hero':
        return Icons.local_drink_rounded;
      case 'steps_10k':
        return Icons.directions_walk_rounded;
      case 'centurion':
        return Icons.bolt_rounded;
      case 'streak_7':
        return Icons.whatshot_rounded;
      default:
        return Icons.military_tech_rounded;
    }
  }

  Color _getBadgeGlowColor(String key) {
    switch (key) {
      case 'early_bird':
        return Colors.orange;
      case 'water_hero':
        return AppTheme.neonBlue;
      case 'steps_10k':
        return Colors.green;
      case 'centurion':
        return AppTheme.neonPink;
      case 'streak_7':
        return Colors.orangeAccent;
      default:
        return AppTheme.neonPurple;
    }
  }
}
