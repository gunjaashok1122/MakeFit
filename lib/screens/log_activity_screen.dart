import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/fitness_provider.dart';
import '../models/activity_model.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';

class LogActivityScreen extends StatefulWidget {
  const LogActivityScreen({Key? key}) : super(key: key);

  @override
  State<LogActivityScreen> createState() => _LogActivityScreenState();
}

class _LogActivityScreenState extends State<LogActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stepsController = TextEditingController(text: '8000');
  
  String _selectedActivity = 'Walking';
  int _duration = 45; // in mins
  int _calories = 320; // kcal
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, dynamic>> _activitiesList = [
    {'name': 'Walking', 'icon': Icons.directions_walk_rounded},
    {'name': 'Running', 'icon': Icons.directions_run_rounded},
    {'name': 'Cycling', 'icon': Icons.directions_bike_rounded},
    {'name': 'Hiking', 'icon': Icons.terrain_rounded},
  ];

  @override
  void dispose() {
    _stepsController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
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
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _saveActivity() {
    if (!_formKey.currentState!.validate()) return;

    final fitnessProvider = Provider.of<FitnessProvider>(context, listen: false);
    final int steps = int.tryParse(_stepsController.text) ?? 0;

    final log = ActivityModel(
      id: '',
      type: _selectedActivity,
      steps: steps,
      calories: _calories,
      duration: _duration,
      date: _selectedDate,
    );

    fitnessProvider.logActivity(log);
    
    // Alert confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Activity logged successfully!'),
        backgroundColor: AppTheme.deepPurple,
      ),
    );

    Navigator.of(context).pop();
  }

  void _recalculateCalories() {
    int steps = int.tryParse(_stepsController.text) ?? 0;
    setState(() {
      _calories = (steps * 0.04).round();
      _duration = (steps * 0.006).round();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
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
                        'Log Activity',
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

                  // Activity Selection
                  const Text(
                    'Activity Type',
                    style: TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _activitiesList.map((act) {
                      final bool isSelected = _selectedActivity == act['name'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedActivity = act['name'];
                          });
                        },
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? AppTheme.neonPink.withOpacity(0.2) 
                                    : AppTheme.cardNavy,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppTheme.neonPink : const Color(0x1BFFFFFF),
                                  width: 1.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.neonPink.withOpacity(0.25),
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                        )
                                      ]
                                    : [],
                              ),
                              child: Icon(
                                act['icon'],
                                color: isSelected ? AppTheme.neonPink : AppTheme.textGrey,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              act['name'],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? AppTheme.textWhite : AppTheme.textGrey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Steps Input
                  const Text(
                    'Steps',
                    style: TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline_rounded, color: AppTheme.neonPink),
                          onPressed: () {
                            int val = int.tryParse(_stepsController.text) ?? 0;
                            if (val >= 500) {
                              _stepsController.text = (val - 500).toString();
                              _recalculateCalories();
                            }
                          },
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _stepsController,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textWhite,
                              fontFamily: 'Outfit',
                            ),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            onChanged: (_) => _recalculateCalories(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.neonBlue),
                          onPressed: () {
                            int val = int.tryParse(_stepsController.text) ?? 0;
                            _stepsController.text = (val + 500).toString();
                            _recalculateCalories();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Calories calculation show
                  const Text(
                    'Calories Burned (kcal)',
                    style: TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Estimated Energy Expenditure',
                          style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                        ),
                        Text(
                          '$_calories kcal',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.neonPink,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Date Picker Card
                  const Text(
                    'Date',
                    style: TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  GlassCard(
                    onTap: _presentDatePicker,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, color: AppTheme.neonPink, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: const TextStyle(
                                color: AppTheme.textWhite,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.edit_calendar_rounded, color: AppTheme.textGrey, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  NeonButton(
                    onTap: _saveActivity,
                    child: const Text(
                      'Save Activity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textWhite,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
