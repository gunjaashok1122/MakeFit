import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/fitness_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';
import '../models/body_stats_model.dart';

class BodyStatsScreen extends StatefulWidget {
  const BodyStatsScreen({Key? key}) : super(key: key);

  @override
  State<BodyStatsScreen> createState() => _BodyStatsScreenState();
}

class _BodyStatsScreenState extends State<BodyStatsScreen> {
  int _activeTab = 0; // 0: Overview, 1: History

  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _fatController = TextEditingController();
  final _muscleController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _fatController.dispose();
    _muscleController.dispose();
    super.dispose();
  }

  void _showUpdateDialog(BuildContext context, double currentW, double currentH, double currentF, double currentM) {
    _weightController.text = currentW.toString();
    _heightController.text = currentH.toString();
    _fatController.text = currentF.toString();
    _muscleController.text = currentM.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardNavy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Update Body Stats',
            style: TextStyle(color: AppTheme.textWhite, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField('Weight (kg)', _weightController),
                const SizedBox(height: 12),
                _buildDialogField('Height (cm)', _heightController),
                const SizedBox(height: 12),
                _buildDialogField('Body Fat (%)', _fatController),
                const SizedBox(height: 12),
                _buildDialogField('Muscle Mass (kg)', _muscleController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonPurple,
                foregroundColor: AppTheme.textWhite,
              ),
              onPressed: () {
                final double w = double.tryParse(_weightController.text) ?? currentW;
                final double h = double.tryParse(_heightController.text) ?? currentH;
                final double f = double.tryParse(_fatController.text) ?? currentF;
                final double m = double.tryParse(_muscleController.text) ?? currentM;
                
                Provider.of<FitnessProvider>(context, listen: false)
                    .updateBodyStats(w, h, f, m);

                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Stats updated successfully!')),
                );
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textWhite, fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.cardNavyLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: AppTheme.textWhite),
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final fitnessProvider = Provider.of<FitnessProvider>(context);
    
    // Set fallback stats if SQLite database has not completed seeds yet
    final latestStats = fitnessProvider.bodyStats.isNotEmpty
        ? fitnessProvider.bodyStats.first
        : BodyStatsModel(
            id: '',
            weight: 72.5,
            height: 175.0,
            bmi: 23.7,
            bodyFat: 18.5,
            muscleMass: 56.3,
            date: DateTime.now(),
          );

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
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textWhite, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'Body Stats',
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

              // Tab headers
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _activeTab == 0 ? AppTheme.neonPurple : Colors.transparent,
                                width: 2.0,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Overview',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: _activeTab == 0 ? FontWeight.bold : FontWeight.normal,
                                color: _activeTab == 0 ? AppTheme.textWhite : AppTheme.textGrey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _activeTab == 1 ? AppTheme.neonPurple : Colors.transparent,
                                width: 2.0,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'History',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: _activeTab == 1 ? FontWeight.bold : FontWeight.normal,
                                color: _activeTab == 1 ? AppTheme.textWhite : AppTheme.textGrey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: _activeTab == 0
                      ? _buildOverviewTab(context, latestStats)
                      : _buildHistoryTab(fitnessProvider.bodyStats),
                ),
              ),

              // Float floating action neon button to trigger updates
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: NeonButton(
                  onTap: () => _showUpdateDialog(
                    context,
                    latestStats.weight,
                    latestStats.height,
                    latestStats.bodyFat,
                    latestStats.muscleMass,
                  ),
                  child: const Text(
                    'Update Stats',
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

  Widget _buildOverviewTab(BuildContext context, BodyStatsModel stats) {
    final fitnessProvider = Provider.of<FitnessProvider>(context);
    final int userAge = fitnessProvider.age;

    double limitUnder = 18.5;
    double limitFit = 25.0;
    double limitOver = 30.0;

    if (userAge < 18) {
      limitUnder = 17.0;
      limitFit = 23.5;
      limitOver = 28.0;
    } else if (userAge > 60) {
      limitUnder = 20.0;
      limitFit = 27.0;
      limitOver = 32.0;
    }

    // Determine BMI color zone
    Color bmiColor = Colors.green;
    String bmiText = 'Fit';
    if (stats.bmi < limitUnder) {
      bmiColor = AppTheme.neonBlue;
      bmiText = 'Underweight';
    } else if (stats.bmi >= limitUnder && stats.bmi < limitFit) {
      bmiColor = Colors.green;
      bmiText = 'Fit';
    } else if (stats.bmi >= limitFit && stats.bmi < limitOver) {
      bmiColor = Colors.orange;
      bmiText = 'Overweight';
    } else {
      bmiColor = AppTheme.neonPink;
      bmiText = 'Obese';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Age Card with Calendar Symbol & picker
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: fitnessProvider.dob,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppTheme.neonPurple,
                      onPrimary: AppTheme.textWhite,
                      surface: AppTheme.cardNavy,
                      onSurface: AppTheme.textWhite,
                    ),
                    dialogBackgroundColor: AppTheme.cardNavy,
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null && picked != fitnessProvider.dob) {
              await fitnessProvider.updateDob(picked);
            }
          },
          child: GlassCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.neonPurple.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.calendar_month_rounded, color: AppTheme.neonPurple, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Age / Date of Birth',
                          style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$userAge years (${fitnessProvider.dob.day}/${fitnessProvider.dob.month}/${fitnessProvider.dob.year})',
                          style: const TextStyle(
                            color: AppTheme.textWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Icon(Icons.edit_calendar_rounded, color: AppTheme.neonPurple, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Grid of Stats
        Row(
          children: [
            Expanded(
              child: _buildStatItemCard(
                icon: Icons.monitor_weight_rounded,
                color: AppTheme.neonPurple,
                title: 'Weight',
                value: '${stats.weight} kg',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatItemCard(
                icon: Icons.height_rounded,
                color: AppTheme.neonBlue,
                title: 'Height',
                value: '${stats.height.toInt()} cm',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatItemCard(
                icon: Icons.pie_chart_rounded,
                color: AppTheme.neonPink,
                title: 'Body Fat',
                value: '${stats.bodyFat}%',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatItemCard(
                icon: Icons.fitness_center_rounded,
                color: AppTheme.neonPurple,
                title: 'Muscle Mass',
                value: '${stats.muscleMass} kg',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // BMI gauge indicator card
        const Text(
          'Body Mass Index (BMI)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite, fontFamily: 'Outfit'),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                stats.bmi.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textWhite,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: bmiColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  bmiText,
                  style: TextStyle(
                    color: bmiColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Gauge slider
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.neonBlue,
                      Colors.green,
                      Colors.orange,
                      AppTheme.neonPink,
                    ],
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Pointer indicator
                    Positioned(
                      left: _calculateBmiPointerPosition(stats.bmi),
                      top: -6,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppTheme.textWhite,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.cardNavy, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.neonPurple.withOpacity(0.5),
                              blurRadius: 8,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('15.0', style: TextStyle(color: AppTheme.textGrey, fontSize: 10)),
                  Text(limitUnder.toStringAsFixed(1), style: const TextStyle(color: AppTheme.textGrey, fontSize: 10)),
                  Text(limitFit.toStringAsFixed(1), style: const TextStyle(color: AppTheme.textGrey, fontSize: 10)),
                  Text(limitOver.toStringAsFixed(1), style: const TextStyle(color: AppTheme.textGrey, fontSize: 10)),
                  const Text('40.0', style: TextStyle(color: AppTheme.textGrey, fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  double _calculateBmiPointerPosition(double bmi) {
    // Normal bounds of gauge are 15 to 35
    double factor = (bmi - 15) / (35 - 15);
    return factor.clamp(0.0, 0.92) * 280; // scale based on general card widths
  }

  Widget _buildStatItemCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(List<BodyStatsModel> statsList) {
    if (statsList.isEmpty) {
      return const Center(
        child: Text(
          'No history logged yet.',
          style: TextStyle(color: AppTheme.textGrey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: statsList.length,
      itemBuilder: (context, index) {
        final log = statsList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GlassCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${log.date.day}/${log.date.month}/${log.date.year}',
                      style: const TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'BMI: ${log.bmi.toStringAsFixed(1)} | Body Fat: ${log.bodyFat}%',
                      style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
                    ),
                  ],
                ),
                Text(
                  '${log.weight} kg',
                  style: const TextStyle(
                    color: AppTheme.neonPurple,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
