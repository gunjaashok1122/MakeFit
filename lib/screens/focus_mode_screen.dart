import 'dart:async';
import 'dart:math';
import 'package:flutter/material';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/fitness_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';
import 'worklist_screen.dart';

class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({Key? key}) : super(key: key);

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  Timer? _timer;
  int _timeRemaining = 0;
  int _totalDuration = 0;
  bool _isRunning = false;
  int _selectedIndex = -1;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_totalDuration <= 0) return;
    _timer?.cancel();
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
        });
        _completeWorkout();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _timeRemaining = _totalDuration;
    });
  }

  void _skipTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _timeRemaining = 0;
    });
    _completeWorkout();
  }

  void _completeWorkout() {
    final fitnessProvider = Provider.of<FitnessProvider>(context, listen: false);
    fitnessProvider.incrementFocusSessionsCleared();

    if (_selectedIndex >= 0 && _selectedIndex < fitnessProvider.savedTasks.length) {
      final item = fitnessProvider.savedTasks[_selectedIndex];
      final name = item['name'] as String? ?? 'Workout';

      final completedDays = Map<String, dynamic>.from(item['completedDays'] ?? {});
      final todayIdx = (DateTime.now().weekday % 7) - 1; // Mon: 0, Tue: 1, ..., Sun: 6
      final actualIdx = todayIdx < 0 ? 6 : todayIdx;

      final updatedCompletedDays = Map<String, bool>.from(completedDays);
      updatedCompletedDays[actualIdx.toString()] = true;
      fitnessProvider.updateSavedTaskCompletedDays(_selectedIndex, updatedCompletedDays);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Focus session completed! "$name" marked as done 🏆')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Focus session completed! Custom session cleared 🏆')),
      );
    }

    _resetTimer();
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showCustomTimeDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardNavy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Custom Duration',
            style: TextStyle(color: AppTheme.textWhite, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppTheme.textWhite),
            decoration: InputDecoration(
              hintText: 'Enter duration (minutes)',
              hintStyle: const TextStyle(color: AppTheme.textGrey),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.textGrey.withOpacity(0.3))),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.neonPurple)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
            ),
            TextButton(
              onPressed: () {
                final mins = int.tryParse(controller.text);
                if (mins != null && mins > 0) {
                  _timer?.cancel();
                  setState(() {
                    _selectedIndex = -1;
                    _totalDuration = mins * 60;
                    _timeRemaining = _totalDuration;
                    _isRunning = false;
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid positive number')),
                  );
                }
              },
              child: const Text('OK', style: TextStyle(color: AppTheme.neonPurple, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showAddPresetDialog() {
    final nameController = TextEditingController();
    final timeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardNavy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Add Preset Focus',
            style: TextStyle(color: AppTheme.textWhite, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(color: AppTheme.textWhite),
                decoration: InputDecoration(
                  hintText: 'Preset name (e.g. Reading)',
                  hintStyle: const TextStyle(color: AppTheme.textGrey),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.textGrey.withOpacity(0.3))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.neonPurple)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textWhite),
                decoration: InputDecoration(
                  hintText: 'Duration (minutes)',
                  hintStyle: const TextStyle(color: AppTheme.textGrey),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.textGrey.withOpacity(0.3))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.neonPurple)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                final mins = int.tryParse(timeController.text.trim());
                if (name.isNotEmpty && mins != null && mins > 0) {
                  final fitnessProvider = Provider.of<FitnessProvider>(context, listen: false);
                  fitnessProvider.addSavedTask(name, mins.toString());
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Preset "$name" added! 📝')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill out all fields with valid values')),
                  );
                }
              },
              child: const Text('Save', style: TextStyle(color: AppTheme.neonPurple, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDurationButton(String label, VoidCallback onTap, bool isSelected) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppTheme.neonPurple.withOpacity(0.12)
                  : AppTheme.textWhite.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppTheme.neonPurple : AppTheme.textWhite.withOpacity(0.08),
                width: 1.2,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fitnessProvider = Provider.of<FitnessProvider>(context);
    final savedTasks = fitnessProvider.savedTasks;

    // Check index bounds
    if (_selectedIndex >= savedTasks.length) {
      _selectedIndex = -1;
    }

    if (_selectedIndex >= 0) {
      final activeItem = savedTasks[_selectedIndex];
      final targetDurationSecs = (double.tryParse(activeItem['time']?.toString() ?? '0') ?? 0.0).toInt() * 60;
      if (!_isRunning && _totalDuration != targetDurationSecs) {
        _totalDuration = targetDurationSecs;
        _timeRemaining = targetDurationSecs;
      }
    } else {
      if (!_isRunning && _totalDuration == 0) {
        _totalDuration = 30 * 60; // Default to 30 mins
        _timeRemaining = 30 * 60;
      }
    }

    final int currentMins = _totalDuration ~/ 60;
    final bool is15 = currentMins == 15;
    final bool is30 = currentMins == 30;
    final bool is45 = currentMins == 45;
    final bool is60 = currentMins == 60;
    final bool isCustom = !is15 && !is30 && !is45 && !is60;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Center(
                  child: Text(
                    'Focus Mode',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textWhite,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),

                      // Presets selector row
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'REGULAR FOCUS',
                                style: TextStyle(
                                  color: AppTheme.textGrey,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              GestureDetector(
                                onTap: _showAddPresetDialog,
                                child: const Text(
                                  '+ add preset',
                                  style: TextStyle(
                                    color: AppTheme.neonPurple,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (savedTasks.isEmpty)
                            Text(
                              'No presets saved. Tap + to add.',
                              style: TextStyle(
                                color: AppTheme.textGrey.withOpacity(0.5),
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          else
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: List.generate(savedTasks.length, (idx) {
                                final task = savedTasks[idx];
                                final bool isSelected = _selectedIndex == idx;
                                return GestureDetector(
                                  onTap: () {
                                    _timer?.cancel();
                                    setState(() {
                                      _selectedIndex = idx;
                                      _isRunning = false;
                                      final targetDurationSecs = (double.tryParse(task['time']?.toString() ?? '0') ?? 0.0).toInt() * 60;
                                      _totalDuration = targetDurationSecs;
                                      _timeRemaining = targetDurationSecs;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? AppTheme.neonPurple.withOpacity(0.12)
                                          : AppTheme.textWhite.withOpacity(0.04),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected ? AppTheme.neonPurple : AppTheme.textWhite.withOpacity(0.08),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          task['name'] ?? '',
                                          style: const TextStyle(
                                            color: AppTheme.textWhite,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '(${task['time']}M)',
                                          style: const TextStyle(
                                            color: AppTheme.neonPurple,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: () {
                                            _timer?.cancel();
                                            fitnessProvider.deleteSavedTask(idx);
                                            setState(() {
                                              if (_selectedIndex == idx) {
                                                _selectedIndex = -1;
                                                _totalDuration = 30 * 60;
                                                _timeRemaining = _totalDuration;
                                              } else if (_selectedIndex > idx) {
                                                _selectedIndex--;
                                              }
                                              _isRunning = false;
                                            });
                                          },
                                          child: const Icon(
                                            Icons.close_rounded,
                                            color: AppTheme.textGrey,
                                            size: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                        ],
                      ),

                      const SizedBox(height: 36),

                      // Timer ring
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 180,
                              height: 180,
                              child: CustomPaint(
                                painter: _TimerRingPainter(
                                  progress: _totalDuration > 0
                                      ? _timeRemaining / _totalDuration
                                      : 0,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatTime(_timeRemaining),
                                  style: const TextStyle(
                                    color: AppTheme.textWhite,
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Outfit',
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'remaining',
                                  style: TextStyle(
                                    color: AppTheme.textGrey,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Select Duration Selector
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'SELECT DURATION',
                                style: TextStyle(
                                  color: AppTheme.textGrey,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                isCustom ? 'CUSTOM MINUTES' : '$currentMins MINUTES',
                                style: const TextStyle(
                                  color: AppTheme.neonPurple,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildDurationButton('Custom', _showCustomTimeDialog, isCustom),
                              _buildDurationButton('15M', () {
                                _timer?.cancel();
                                setState(() {
                                  _selectedIndex = -1;
                                  _totalDuration = 15 * 60;
                                  _timeRemaining = _totalDuration;
                                  _isRunning = false;
                                });
                              }, is15),
                              _buildDurationButton('30M', () {
                                _timer?.cancel();
                                setState(() {
                                  _selectedIndex = -1;
                                  _totalDuration = 30 * 60;
                                  _timeRemaining = _totalDuration;
                                  _isRunning = false;
                                });
                              }, is30),
                              _buildDurationButton('45M', () {
                                _timer?.cancel();
                                setState(() {
                                  _selectedIndex = -1;
                                  _totalDuration = 45 * 60;
                                  _timeRemaining = _totalDuration;
                                  _isRunning = false;
                                });
                              }, is45),
                              _buildDurationButton('60M', () {
                                _timer?.cancel();
                                setState(() {
                                  _selectedIndex = -1;
                                  _totalDuration = 60 * 60;
                                  _timeRemaining = _totalDuration;
                                  _isRunning = false;
                                });
                              }, is60),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      Center(
                        child: Text(
                          _selectedIndex >= 0 && _selectedIndex < savedTasks.length
                              ? (savedTasks[_selectedIndex]['name'] ?? 'Workout')
                              : 'Custom Focus Session',
                          style: const TextStyle(
                            color: AppTheme.textWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          _selectedIndex >= 0 && _selectedIndex < savedTasks.length
                              ? 'Time: ${savedTasks[_selectedIndex]['time']} min'
                              : 'Time: $currentMins min',
                          style: const TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 13,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Controls Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Reset
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.textWhite.withOpacity(0.06),
                            ),
                            child: IconButton(
                              iconSize: 22,
                              padding: const EdgeInsets.all(10),
                              icon: const Icon(Icons.refresh_rounded, color: AppTheme.textWhite),
                              onPressed: _resetTimer,
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Play/Pause
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.neonPurple.withOpacity(0.35),
                                  blurRadius: 14,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: IconButton(
                              iconSize: 28,
                              icon: Icon(
                                _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: AppTheme.textWhite,
                              ),
                              onPressed: _isRunning ? _pauseTimer : _startTimer,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Today's Sessions Cleared card
                      GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                  child: const Icon(
                                    Icons.military_tech_rounded,
                                    color: AppTheme.neonPurple,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Today\'s Sessions Cleared',
                                  style: TextStyle(
                                    color: AppTheme.textWhite,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${fitnessProvider.focusSessionsCleared}',
                              style: const TextStyle(
                                color: AppTheme.neonPurple,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;

  _TimerRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;

    // Track
    final trackPaint = Paint()
      ..color = AppTheme.textWhite.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    canvas.drawCircle(center, radius, trackPaint);

    // Active glow
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final activePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round
        ..shader = const LinearGradient(
          colors: [AppTheme.neonPurple, AppTheme.neonPink],
        ).createShader(rect);

      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10.0
        ..strokeCap = StrokeCap.round
        ..shader = const LinearGradient(
          colors: [AppTheme.neonPurple, AppTheme.neonPink],
        ).createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, glowPaint);
      canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, activePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
