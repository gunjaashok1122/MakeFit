import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/theme_provider.dart';
import '../providers/fitness_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _localReminders = true;
  bool _aiSuggestions = true;
  String _unitStandard = 'Metric (kg, cm)';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
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
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textWhite, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'App Settings',
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

                // Theme Settings Card
                _buildSectionHeader('Appearance'),
                const SizedBox(height: 8),
                GlassCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.dark_mode_rounded, color: AppTheme.neonPurple, size: 22),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dark Premium Theme', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                              SizedBox(height: 2),
                              Text('Use neon glow style dark scheme', style: TextStyle(color: AppTheme.textGrey, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: themeProvider.isDarkMode,
                        activeColor: AppTheme.neonPurple,
                        onChanged: (val) {
                          themeProvider.toggleTheme(val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Notification reminders Settings Card
                _buildSectionHeader('Alerts & Reminders'),
                const SizedBox(height: 8),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildToggleItem(
                        icon: Icons.notifications_active_rounded,
                        color: AppTheme.neonPink,
                        title: 'Daily Reminders',
                        subtitle: 'Reminders to log workouts daily',
                        value: _localReminders,
                        onChanged: (val) => setState(() => _localReminders = val),
                      ),
                      Divider(color: AppTheme.cardNavyLight.withOpacity(0.3), height: 1, indent: 48),
                      _buildToggleItem(
                        icon: Icons.chat_bubble_outline_rounded,
                        color: AppTheme.neonBlue,
                        title: 'AI Smart Suggestions',
                        subtitle: 'Recommendations based on metrics',
                        value: _aiSuggestions,
                        onChanged: (val) => setState(() => _aiSuggestions = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Unit calculations
                _buildSectionHeader('Data Units'),
                const SizedBox(height: 8),
                GlassCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.straighten_rounded, color: AppTheme.neonPurple, size: 22),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Measurement Unit', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                              SizedBox(height: 2),
                              Text('System scaling index limits', style: TextStyle(color: AppTheme.textGrey, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                      DropdownButton<String>(
                        dropdownColor: AppTheme.cardNavy,
                        value: _unitStandard,
                        underline: const SizedBox(),
                        style: TextStyle(color: AppTheme.neonPurple, fontWeight: FontWeight.bold, fontSize: 13),
                        items: ['Metric (kg, cm)', 'Imperial (lbs, in)'].map((String val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _unitStandard = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Delete cache / Database reset
                const Text(
                  'Data Maintenance',
                  style: TextStyle(color: AppTheme.neonPink, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
                const SizedBox(height: 8),
                NeonButton(
                  isSecondary: true,
                  onTap: () {
                    // Alert reset confirmation
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppTheme.cardNavy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('Reset Application Database', style: TextStyle(color: AppTheme.textWhite)),
                        content: const Text('This will wipe all logged statistics and restore seed parameters. Are you sure you want to proceed?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonPink),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await fitnessProvider.initData();
                              
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Database reset complete.')),
                                );
                              }
                            },
                            child: const Text('Reset', style: TextStyle(color: AppTheme.textWhite)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    'Clear All Logs & Cache',
                    style: TextStyle(
                      color: AppTheme.neonPink,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textGrey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppTheme.textGrey, fontSize: 11)),
                ],
              ),
            ],
          ),
          Switch(
            value: value,
            activeColor: color,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
