import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/fitness_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';

class WorklistScreen extends StatefulWidget {
  const WorklistScreen({Key? key}) : super(key: key);

  @override
  State<WorklistScreen> createState() => _WorklistScreenState();
}

class _WorklistScreenState extends State<WorklistScreen> {
  final List<Map<String, TextEditingController>> _tasks = [];
  


  int? _editingIndex;
  final TextEditingController _editNameController = TextEditingController();
  final TextEditingController _editTimeController = TextEditingController();

  void _startEditing(int index, String name, String time) {
    setState(() {
      _editingIndex = index;
      _editNameController.text = name;
      _editTimeController.text = time;
    });
  }

  void _saveEditing(int index) {
    final name = _editNameController.text.trim();
    final time = _editTimeController.text.trim();
    if (name.isEmpty && time.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in a workout name or time.')),
      );
      return;
    }
    final fitnessProvider = Provider.of<FitnessProvider>(context, listen: false);
    fitnessProvider.updateSavedTaskNameAndTime(index, name, time);
    setState(() {
      _editingIndex = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _addNewTask(name: '', time: '');
  }

  void _addNewTask({String name = '', String time = ''}) {
    setState(() {
      _tasks.add({
        'name': TextEditingController(text: name),
        'time': TextEditingController(text: time),
      });
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks[index]['name']!.dispose();
      _tasks[index]['time']!.dispose();
      _tasks.removeAt(index);
      if (_tasks.isEmpty) {
        _addNewTask();
      }
    });
  }

  void _saveWorklist() {
    final fitnessProvider = Provider.of<FitnessProvider>(context, listen: false);
    List<Map<String, String>> newItems = [];
    for (var task in _tasks) {
      final name = task['name']!.text.trim();
      final time = task['time']!.text.trim();
      if (name.isNotEmpty || time.isNotEmpty) {
        newItems.add({
          'name': name,
          'time': time,
        });
      }
    }
    
    if (newItems.isNotEmpty) {
      fitnessProvider.saveWorklist(newItems);
      
      setState(() {
        for (var task in _tasks) {
          task['name']!.dispose();
          task['time']!.dispose();
        }
        _tasks.clear();
        _addNewTask(name: '', time: '');
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Worklist items saved to list! 📝')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in a workout name or time.')),
      );
    }
  }

  List<Map<String, dynamic>> _getWeekDates() {
    final today = DateTime.now();
    final int currentDay = today.weekday; // 1: Mon, ..., 7: Sun
    final DateTime monday = today.subtract(Duration(days: currentDay - 1));
    
    final List<String> daysShort = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final List<Map<String, dynamic>> week = [];
    
    for (int i = 0; i < 7; i++) {
      final dayDate = monday.add(Duration(days: i));
      final dayMidnight = DateTime(dayDate.year, dayDate.month, dayDate.day);
      final todayMidnight = DateTime(today.year, today.month, today.day);
      
      final bool isFuture = dayMidnight.isAfter(todayMidnight);
      
      week.add({
        'label': daysShort[i],
        'dateNum': dayDate.day,
        'isFuture': isFuture,
      });
    }
    return week;
  }

  @override
  void dispose() {
    for (var task in _tasks) {
      task['name']!.dispose();
      task['time']!.dispose();
    }
    _editNameController.dispose();
    _editTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fitnessProvider = Provider.of<FitnessProvider>(context);
    final savedTasks = fitnessProvider.savedTasks;
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
                      'Worklist',
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
              ),

              // Scrollable content area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Editable Task Inputs
                      ...List.generate(_tasks.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: GlassCard(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: _tasks[index]['name'],
                                        style: const TextStyle(color: AppTheme.textWhite, fontSize: 15, fontWeight: FontWeight.bold),
                                        decoration: const InputDecoration(
                                          hintText: 'Work out name (push Ups, walk,etc..)',
                                          hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                                        ),
                                      ),
                                      const Divider(color: Color(0x1BFFFFFF), height: 12),
                                      TextField(
                                        controller: _tasks[index]['time'],
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
                                        decoration: const InputDecoration(
                                          hintText: 'Time (min)',
                                          hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.neonPink, size: 22),
                                  onPressed: () => _deleteTask(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 8),

                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.neonPurple, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _addNewTask(),
                        child: const Text(
                          '+ Add New Task',
                          style: TextStyle(color: AppTheme.neonPurple, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),

                      NeonButton(
                        onTap: _saveWorklist,
                        child: const Text(
                          'Save Worklist',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textWhite,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Saved List',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textWhite,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (savedTasks.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: Text(
                              'No saved workouts yet.',
                              style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                            ),
                          ),
                        )
                      else
                        ...List.generate(savedTasks.length, (index) {
                          final item = savedTasks[index];
                          final completedDays = Map<String, dynamic>.from(item['completedDays'] ?? {});
                          final bool isExpanded = item['expanded'] as bool? ?? false;
                          final completedCount = completedDays.values.where((v) => v == true).length;
                          final bool isEditing = _editingIndex == index;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: GlassCard(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: isEditing
                                        ? null
                                        : () {
                                            setState(() {
                                              item['expanded'] = !isExpanded;
                                            });
                                          },
                                    child: Container(
                                      color: Colors.transparent,
                                      child: isEditing
                                          ? Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.neonPurple.withOpacity(0.12),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(Icons.edit_rounded, color: AppTheme.neonPurple, size: 18),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      TextField(
                                                        controller: _editNameController,
                                                        style: const TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.bold),
                                                        decoration: const InputDecoration(
                                                          hintText: 'Work out name (push Ups, walk,etc..)',
                                                          hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                                                          border: InputBorder.none,
                                                          isDense: true,
                                                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                                                        ),
                                                      ),
                                                      const Divider(color: Color(0x1BFFFFFF), height: 8),
                                                      TextField(
                                                        controller: _editTimeController,
                                                        keyboardType: TextInputType.number,
                                                        style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                                                        decoration: const InputDecoration(
                                                          hintText: 'Time (min)',
                                                          hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                                          border: InputBorder.none,
                                                          isDense: true,
                                                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.check_rounded, color: AppTheme.neonPurple, size: 20),
                                                  onPressed: () => _saveEditing(index),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.close_rounded, color: AppTheme.neonPink, size: 18),
                                                  onPressed: () {
                                                    fitnessProvider.deleteSavedTask(index);
                                                    setState(() {
                                                      if (_editingIndex == index) {
                                                        _editingIndex = null;
                                                      }
                                                    });
                                                  },
                                                ),
                                              ],
                                            )
                                          : Row(
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
                                                      child: const Icon(Icons.assignment_rounded, color: AppTheme.neonPurple, size: 18),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          item['name']!,
                                                          style: const TextStyle(
                                                            color: AppTheme.textWhite,
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          'Time: ${item['time']} min • Expand 📅',
                                                          style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      '$completedCount/7 done',
                                                      style: const TextStyle(color: AppTheme.textGrey, fontSize: 11),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.edit_rounded, color: AppTheme.textGrey, size: 18),
                                                      onPressed: () => _startEditing(index, item['name']!, item['time']!),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.close_rounded, color: AppTheme.neonPink, size: 18),
                                                      onPressed: () {
                                                        fitnessProvider.deleteSavedTask(index);
                                                        setState(() {
                                                          if (_editingIndex == index) {
                                                            _editingIndex = null;
                                                          } else if (_editingIndex != null && _editingIndex! > index) {
                                                            _editingIndex = _editingIndex! - 1;
                                                          }
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                  
                                  if (isExpanded) ...[
                                    const Divider(color: Color(0x1BFFFFFF), height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: List.generate(7, (dayIdx) {
                                        final weekDays = _getWeekDates();
                                        final day = weekDays[dayIdx];
                                        final bool isCompleted = completedDays[dayIdx.toString()] == true;
                                        final bool isFuture = day['isFuture'];
                                        
                                        return Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              if (isFuture) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Cannot mark upcoming days as done! 🔒')),
                                                );
                                                return;
                                              }
                                              final updatedCompletedDays = Map<String, bool>.from(completedDays);
                                              updatedCompletedDays[dayIdx.toString()] = !isCompleted;
                                              fitnessProvider.updateSavedTaskCompletedDays(index, updatedCompletedDays);
                                            },
                                            child: Column(
                                              children: [
                                                Text(
                                                  day['label'],
                                                  style: const TextStyle(color: AppTheme.textGrey, fontSize: 9),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${day['dateNum']}',
                                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 8),
                                                ),
                                                const SizedBox(height: 4),
                                                Container(
                                                  width: 24,
                                                  height: 24,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: isCompleted ? AppTheme.neonPurple : Colors.transparent,
                                                    border: Border.all(
                                                      color: isFuture 
                                                          ? AppTheme.textMuted.withOpacity(0.3)
                                                          : (isCompleted ? Colors.transparent : AppTheme.textGrey),
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: isFuture
                                                        ? const Icon(Icons.lock_outline_rounded, color: AppTheme.textMuted, size: 10)
                                                        : (isCompleted
                                                            ? const Icon(Icons.check_rounded, color: AppTheme.textWhite, size: 12)
                                                            : null),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),
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
