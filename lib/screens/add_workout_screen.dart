import 'package:flutter/material';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/fitness_provider.dart';
import '../models/workout_model.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({Key? key}) : super(key: key);

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'Running';
  int _duration = 30; // default minutes
  int _calories = 250; // default kcal
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Running', 'icon': Icons.directions_run_rounded},
    {'name': 'Cycling', 'icon': Icons.directions_bike_rounded},
    {'name': 'Yoga', 'icon': Icons.spa_rounded},
    {'name': 'Gym', 'icon': Icons.fitness_center_rounded},
    {'name': 'Other', 'icon': Icons.accessibility_new_rounded},
  ];

  @override
  void dispose() {
    _typeController.dispose();
    _notesController.dispose();
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

  void _saveWorkout() {
    if (!_formKey.currentState!.validate()) return;

    final fitnessProvider = Provider.of<FitnessProvider>(context, listen: false);

    // Generate random heart rate readings for simulation details screen
    final List<int> hrList = List.generate(
      8,
      (index) => 90 + (index * 12) % 60,
    );

    final newWorkout = WorkoutModel(
      id: '', // Will be assigned automatically in DB or provider
      type: _typeController.text.trim().isNotEmpty
          ? _typeController.text.trim()
          : _selectedCategory,
      category: _selectedCategory,
      duration: _duration,
      calories: _calories,
      date: _selectedDate,
      heartRateHistory: hrList,
      notes: _notesController.text.trim(),
    );

    fitnessProvider.addWorkout(newWorkout);
    Navigator.of(context).pop();
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
                        'Add Workout',
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

                  // Workout Type Input field
                  const Text(
                    'Workout Type',
                    style: TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    borderRadius: 12,
                    child: TextFormField(
                      controller: _typeController,
                      style: const TextStyle(color: AppTheme.textWhite),
                      decoration: const InputDecoration(
                        hintText: 'Enter workout name (e.g. Morning Cardio)',
                        hintStyle: TextStyle(color: AppTheme.textMuted),
                        prefixIcon: Icon(Icons.edit_note_rounded, color: AppTheme.textGrey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Category selector icons
                  const Text(
                    'Category',
                    style: TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _categories.map((cat) {
                      final bool isSelected = _selectedCategory == cat['name'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat['name'];
                          });
                        },
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? AppTheme.neonPurple.withOpacity(0.2) 
                                    : AppTheme.cardNavy,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppTheme.neonPurple : const Color(0x1BFFFFFF),
                                  width: 1.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.neonPurple.withOpacity(0.25),
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                        )
                                      ]
                                    : [],
                              ),
                              child: Icon(
                                cat['icon'],
                                color: isSelected ? AppTheme.neonPurple : AppTheme.textGrey,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat['name'],
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

                  // Duration Input (Increment/Decrement counters)
                  const Text(
                    'Duration (minutes)',
                    style: TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline_rounded, color: AppTheme.neonPink, size: 28),
                          onPressed: () {
                            if (_duration > 5) {
                              setState(() {
                                _duration -= 5;
                                _calories = (_duration * 8.3).round(); // Auto compute average kcal
                              });
                            }
                          },
                        ),
                        Text(
                          '$_duration min',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textWhite,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.neonBlue, size: 28),
                          onPressed: () {
                            setState(() {
                              _duration += 5;
                              _calories = (_duration * 8.3).round();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Calories Input (Increment/Decrement)
                  const Text(
                    'Calories Burned (kcal)',
                    style: TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline_rounded, color: AppTheme.neonPink, size: 28),
                          onPressed: () {
                            if (_calories > 10) {
                              setState(() {
                                _calories -= 10;
                              });
                            }
                          },
                        ),
                        Text(
                          '$_calories kcal',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textWhite,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.neonBlue, size: 28),
                          onPressed: () {
                            setState(() {
                              _calories += 10;
                            });
                          },
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
                            const Icon(Icons.calendar_today_rounded, color: AppTheme.neonPurple, size: 20),
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
                    onTap: _saveWorkout,
                    child: const Text(
                      'Save Workout',
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
