import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/fitness_provider.dart';
import '../widgets/glass_card.dart';
import 'auth_screen.dart';
import 'goals_screen.dart';
import 'badges_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final fitnessProvider = Provider.of<FitnessProvider>(context);

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
                const Center(
                  child: Text(
                    'Profile Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textWhite,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // User details block (Avatar, Name, Email, Level)
                GlassCard(
                  child: Column(
                    children: [
                      // Glowing Avatar Ring representation
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.neonPurple.withOpacity(0.35),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: 92,
                            height: 92,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.cardNavy,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person_rounded,
                                size: 52,
                                color: AppTheme.textWhite,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppTheme.neonPink,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit_rounded, color: AppTheme.textWhite, size: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Name
                      Text(
                        authProvider.userName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textWhite,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Email
                      Text(
                        authProvider.userEmail,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textGrey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Streak / Level pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.neonPurple.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.neonPurple.withOpacity(0.2), width: 1.2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt_rounded, color: Colors.orange, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${fitnessProvider.streakCount}-Day Streak | ${authProvider.fitnessLevel}',
                              style: const TextStyle(
                                color: AppTheme.textWhite,
                                fontSize: 12,
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

                // Settings List
                _buildSectionTitle('Activity Settings'),
                const SizedBox(height: 8),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildSettingsItem(
                        icon: Icons.track_changes_rounded,
                        color: AppTheme.neonPink,
                        title: 'My Goals',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const GoalsScreen()),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsItem(
                        icon: Icons.emoji_events_rounded,
                        color: Colors.orange,
                        title: 'Achievements',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const BadgesScreen()),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsItem(
                        icon: Icons.settings_outlined,
                        color: AppTheme.neonPurple,
                        title: 'App Settings',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const SettingsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _buildSectionTitle('Support & Accountability'),
                const SizedBox(height: 8),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildSettingsItem(
                        icon: Icons.help_outline_rounded,
                        color: AppTheme.neonBlue,
                        title: 'Help & Support',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Support ticket raised. Check your registered email.')),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsItem(
                        icon: Icons.logout_rounded,
                        color: AppTheme.neonPink,
                        title: 'Logout',
                        onTap: () {
                          // Confirm
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppTheme.cardNavy,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Text('Logout', style: TextStyle(color: AppTheme.textWhite)),
                              content: const Text('Are you sure you want to sign out?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonPink),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    await authProvider.logout();
                                    if (context.mounted) {
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(builder: (context) => const AuthScreen()),
                                        (route) => false,
                                      );
                                    }
                                  },
                                  child: const Text('Logout', style: TextStyle(color: AppTheme.textWhite)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.textGrey,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textWhite,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textMuted, size: 14),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppTheme.cardNavyLight.withOpacity(0.3),
      height: 1,
      indent: 60,
      endIndent: 16,
    );
  }
}
