import 'dart:convert';
import 'package:flutter/material';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_model.dart';
import '../models/activity_model.dart';
import '../models/water_model.dart';
import '../models/body_stats_model.dart';
import '../models/sleep_model.dart';
import '../models/mood_model.dart';
import '../models/goal_model.dart';
import '../models/badge_model.dart';
import '../models/challenge_model.dart';
import '../services/database_service.dart';
import '../services/ai_service.dart';
import '../services/notification_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class FitnessProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  final Uuid _uuid = const Uuid();

  // State collections
  List<WorkoutModel> _workouts = [];
  List<ActivityModel> _activities = [];
  List<WaterModel> _waterLogs = [];
  List<BodyStatsModel> _bodyStats = [];
  DateTime _dob = DateTime(2001, 1, 15);

  DateTime get dob => _dob;

  int get age {
    final today = DateTime.now();
    int age = today.year - _dob.year;
    if (today.month < _dob.month || (today.month == _dob.month && today.day < _dob.day)) {
      age--;
    }
    return age;
  }
  List<SleepModel> _sleepLogs = [];
  List<MoodModel> _moodLogs = [];
  List<GoalModel> _goals = [];
  List<BadgeModel> _badges = [];
  List<ChallengeModel> _challenges = [];
  List<Map<String, dynamic>> _savedTasks = [];
  int _focusSessionsCleared = 0;
  List<Map<String, dynamic>> _focusHistory = [];

  int _streakCount = 3; // Starts with a 3-day streak from seed
  Map<String, dynamic> _aiSuggestions = {};
  bool _isConnected = true;
  bool _isLoading = false;

  // Getters
  List<WorkoutModel> get workouts => _workouts;
  List<ActivityModel> get activities => _activities;
  List<WaterModel> get waterLogs => _waterLogs;
  List<BodyStatsModel> get bodyStats => _bodyStats;
  List<SleepModel> get sleepLogs => _sleepLogs;
  List<MoodModel> get moodLogs => _moodLogs;
  List<GoalModel> get goals => _goals;
  List<BadgeModel> get badges => _badges;
  List<ChallengeModel> get challenges => _challenges;
  List<Map<String, dynamic>> get savedTasks => _savedTasks;
  int get focusSessionsCleared => _focusSessionsCleared;
  List<Map<String, dynamic>> get focusHistory => _focusHistory;

  int get streakCount => _streakCount;
  Map<String, dynamic> get aiSuggestions => _aiSuggestions;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;

  FitnessProvider() {
    initData();
    _listenToConnectivity();
  }

  Future<void> initData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadDob();
      await _loadSavedTasks();
      await _loadFocusSessionsCleared();
      await _loadFocusHistory();
      await _loadAllData();
      _generateAISuggestions();
    } catch (e) {
      print('Error loading initial fitness data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadAllData() async {
    // 1. Fetch workouts
    final workoutData = await _db.query('workouts', orderBy: 'date DESC');
    _workouts = workoutData.map((e) => WorkoutModel.fromMap(e)).toList();

    // 2. Fetch activities
    final activityData = await _db.query('activity_logs', orderBy: 'date DESC');
    _activities = activityData.map((e) => ActivityModel.fromMap(e)).toList();

    // 3. Fetch water logs
    final waterData = await _db.query('water_logs', orderBy: 'date DESC');
    _waterLogs = waterData.map((e) => WaterModel.fromMap(e)).toList();

    // 4. Fetch body stats
    final statsData = await _db.query('body_stats', orderBy: 'date DESC');
    _bodyStats = statsData.map((e) => BodyStatsModel.fromMap(e)).toList();

    // 5. Fetch sleep logs
    final sleepData = await _db.query('sleep_logs', orderBy: 'date DESC');
    _sleepLogs = sleepData.map((e) => SleepModel.fromMap(e)).toList();

    // 6. Fetch mood logs
    final moodData = await _db.query('mood_logs', orderBy: 'date DESC');
    _moodLogs = moodData.map((e) => MoodModel.fromMap(e)).toList();

    // 7. Fetch goals
    final goalData = await _db.query('goals');
    _goals = goalData.map((e) => GoalModel.fromMap(e)).toList();

    // 8. Fetch badges
    final badgeData = await _db.query('badges');
    _badges = badgeData.map((e) => BadgeModel.fromMap(e)).toList();

    // 9. Fetch challenges
    final challengeData = await _db.query('challenges');
    _challenges = challengeData.map((e) => ChallengeModel.fromMap(e)).toList();

    // Calculate current goals based on daily logs
    _calculateCurrentGoals();
    _calculateStreaks();
  }

  void _calculateCurrentGoals() {
    final now = DateTime.now();

    // Reset today's counts
    double todaySteps = 0;
    double todayCalories = 0;
    double todayWater = 0;

    // Filter logs for today
    for (var act in _activities) {
      if (_isSameDay(act.date, now)) {
        todaySteps += act.steps;
        todayCalories += act.calories;
      }
    }

    for (var wrk in _workouts) {
      if (_isSameDay(wrk.date, now)) {
        todayCalories += wrk.calories;
      }
    }

    for (var wat in _waterLogs) {
      if (_isSameDay(wat.date, now)) {
        todayWater += wat.amount;
      }
    }

    // Update goal structures
    for (var goal in _goals) {
      if (goal.type == 'Steps') {
        goal.current = todaySteps;
      } else if (goal.type == 'Calories') {
        goal.current = todayCalories;
      } else if (goal.type == 'Water') {
        goal.current = todayWater;
      } else if (goal.type == 'Weight') {
        if (_bodyStats.isNotEmpty) {
          goal.current = _bodyStats.first.weight;
        }
      }
    }
  }

  void _calculateStreaks() {
    if (_workouts.isEmpty) {
      _streakCount = 0;
      return;
    }
    // Count days consecutively where a workout or active step log exists
    // For simplicity, we seed a streak of 3, and increment if today is logged
    final now = DateTime.now();
    bool hasTodayActivity = _workouts.any((w) => _isSameDay(w.date, now)) || 
                            _activities.any((a) => _isSameDay(a.date, now) && a.steps > 5000);
    
    if (hasTodayActivity) {
      _streakCount = 4; // incremented streak
    } else {
      _streakCount = 3;
    }
  }

  void _generateAISuggestions() {
    if (_bodyStats.isEmpty) return;
    final latestStats = _bodyStats.first;
    _aiSuggestions = AIService.instance.generateWorkoutPlan(
      weight: latestStats.weight,
      height: latestStats.height,
      bodyFat: latestStats.bodyFat,
      fitnessLevel: 'Intermediate',
    );
  }

  // --- CRUD ACTIONS & MUTATIONS ---

  Future<void> addWorkout(WorkoutModel workout) async {
    await _db.insert('workouts', workout.toMap());
    _workouts.insert(0, workout);
    
    // Add workout calories to daily totals
    _calculateCurrentGoals();
    _checkAchievements();
    _calculateStreaks();
    notifyListeners();

    // Trigger local reminder notifications
    NotificationService.instance.showNotification(
      id: workout.hashCode,
      title: 'Workout Logged! 🔥',
      body: 'You crushed a ${workout.type} session and burned ${workout.calories} kcal!',
    );
  }

  Future<void> deleteWorkout(String id) async {
    await _db.delete('workouts', where: 'id = ?', whereArgs: [id]);
    _workouts.removeWhere((w) => w.id == id);
    _calculateCurrentGoals();
    notifyListeners();
  }

  Future<void> logActivity(ActivityModel activity) async {
    await _db.insert('activity_logs', activity.toMap());
    _activities.insert(0, activity);

    // Update goals
    _calculateCurrentGoals();
    _checkAchievements();
    notifyListeners();
  }

  Future<void> addWater(int amount) async {
    final now = DateTime.now();
    final log = WaterModel(id: _uuid.v4(), amount: amount, date: now);
    await _db.insert('water_logs', log.toMap());
    _waterLogs.insert(0, log);

    // Recalculate water goal
    _calculateCurrentGoals();
    _checkAchievements();
    
    // Check if hydration challenges are updated
    _updateChallengeProgress('Water', amount.toDouble());

    notifyListeners();
  }

  Future<void> removeWater(String id) async {
    final index = _waterLogs.indexWhere((w) => w.id == id);
    if (index != -1) {
      final amount = _waterLogs[index].amount;
      await _db.delete('water_logs', where: 'id = ?', whereArgs: [id]);
      _waterLogs.removeAt(index);
      _calculateCurrentGoals();
      _updateChallengeProgress('Water', -amount.toDouble());
      notifyListeners();
    }
  }

  Future<void> updateBodyStats(double weight, double height, double fat, double muscle) async {
    final now = DateTime.now();
    final bmi = BodyStatsModel.calculateBMI(weight, height);
    final stats = BodyStatsModel(
      id: _uuid.v4(),
      weight: weight,
      height: height,
      bmi: bmi,
      bodyFat: fat,
      muscleMass: muscle,
      date: now,
    );

    await _db.insert('body_stats', stats.toMap());
    _bodyStats.insert(0, stats);

    // Update targets
    _calculateCurrentGoals();
    _generateAISuggestions();
    notifyListeners();
  }

  Future<void> addSleepLog(double duration, String quality) async {
    final now = DateTime.now();
    final log = SleepModel(id: _uuid.v4(), duration: duration, quality: quality, date: now);
    await _db.insert('sleep_logs', log.toMap());
    _sleepLogs.insert(0, log);
    notifyListeners();
  }

  Future<void> addMoodLog(String mood) async {
    final now = DateTime.now();
    final log = MoodModel(id: _uuid.v4(), mood: mood, date: now);
    await _db.insert('mood_logs', log.toMap());
    _moodLogs.insert(0, log);
    notifyListeners();
  }

  Future<void> updateGoalTarget(String type, double target) async {
    final index = _goals.indexWhere((g) => g.type == type);
    if (index != -1) {
      final goal = _goals[index];
      final updatedGoal = GoalModel(
        id: goal.id,
        type: goal.type,
        target: target,
        current: goal.current,
        date: goal.date,
      );
      await _db.update('goals', updatedGoal.toMap(), where: 'id = ?', whereArgs: [goal.id]);
      _goals[index] = updatedGoal;
      notifyListeners();
    }
  }

  Future<void> joinChallenge(String id) async {
    final index = _challenges.indexWhere((c) => c.id == id);
    if (index != -1) {
      final challenge = _challenges[index];
      final updated = ChallengeModel(
        id: challenge.id,
        title: challenge.title,
        description: challenge.description,
        type: challenge.type,
        targetValue: challenge.targetValue,
        currentValue: challenge.currentValue,
        daysRemaining: challenge.daysRemaining,
        isJoined: !challenge.isJoined,
        isCompleted: challenge.isCompleted,
      );
      await _db.update('challenges', updated.toMap(), where: 'id = ?', whereArgs: [id]);
      _challenges[index] = updated;
      notifyListeners();
    }
  }

  void _updateChallengeProgress(String type, double addedValue) async {
    for (int i = 0; i < _challenges.length; i++) {
      final c = _challenges[i];
      if (c.isJoined && c.type == type && !c.isCompleted) {
        double newVal = (c.currentValue + addedValue).clamp(0.0, c.targetValue);
        bool isDone = newVal >= c.targetValue;
        final updated = ChallengeModel(
          id: c.id,
          title: c.title,
          description: c.description,
          type: c.type,
          targetValue: c.targetValue,
          currentValue: newVal,
          daysRemaining: c.daysRemaining,
          isJoined: c.isJoined,
          isCompleted: isDone,
        );
        await _db.update('challenges', updated.toMap(), where: 'id = ?', whereArgs: [c.id]);
        _challenges[i] = updated;

        if (isDone) {
          NotificationService.instance.showNotification(
            id: c.hashCode,
            title: 'Challenge Completed! 🏆',
            body: 'You completed the "${c.title}" challenge!',
          );
        }
      }
    }
  }

  Future<void> syncCloudData() async {
    _isLoading = true;
    notifyListeners();

    // Simulate Cloud sync delay
    await Future.delayed(const Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();
  }

  // --- ACHIEVEMENT BADGES CHECKING ENGINE ---
  void _checkAchievements() async {
    final now = DateTime.now();

    for (int i = 0; i < _badges.length; i++) {
      final badge = _badges[i];
      if (badge.isUnlocked) continue;

      bool shouldUnlock = false;

      if (badge.id == 'badge1') {
        // "Early Bird" - Workout logged before 7 AM
        shouldUnlock = _workouts.any((w) => w.date.hour < 7);
      } else if (badge.id == 'badge2') {
        // "Hydration Hero" - Daily water target met
        final waterGoal = _goals.firstWhere((g) => g.type == 'Water');
        shouldUnlock = waterGoal.current >= waterGoal.target;
      } else if (badge.id == 'badge3') {
        // "10k Club" - Any step log > 10,000 steps
        shouldUnlock = _activities.any((a) => a.steps >= 10000);
      } else if (badge.id == 'badge4') {
        // "Centurion Workout" - Workout duration >= 100 or kcal >= 600
        shouldUnlock = _workouts.any((w) => w.duration >= 100 || w.calories >= 600);
      } else if (badge.id == 'badge5') {
        // "Fitness Streak Tracker" - Streak Count >= 7 days
        shouldUnlock = _streakCount >= 7;
      }

      if (shouldUnlock) {
        final unlocked = BadgeModel(
          id: badge.id,
          title: badge.title,
          description: badge.description,
          iconKey: badge.iconKey,
          isUnlocked: true,
          unlockedDate: now,
        );

        await _db.update('badges', unlocked.toMap(), where: 'id = ?', whereArgs: [badge.id]);
        _badges[i] = unlocked;

        NotificationService.instance.showNotification(
          id: badge.id.hashCode,
          title: 'Badge Unlocked! 🏅',
          body: 'Congratulations! You unlocked the "${badge.title}" badge.',
        );
      }
    }
  }

  // --- HELPER UTILS ---
  Future<void> _loadDob() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dobStr = prefs.getString('user_dob');
      if (dobStr != null) {
        _dob = DateTime.parse(dobStr);
      }
    } catch (e) {
      print('Error loading DOB: $e');
    }
  }

  Future<void> updateDob(DateTime newDob) async {
    _dob = newDob;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_dob', newDob.toIso8601String());
    } catch (e) {
      print('Error saving DOB: $e');
    }
    notifyListeners();
  }

  Future<void> _loadSavedTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksStr = prefs.getString('saved_tasks');
      if (tasksStr != null) {
        final List<dynamic> decoded = jsonDecode(tasksStr);
        _savedTasks = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      print('Error loading saved tasks: $e');
    }
  }

  Future<void> _saveSavedTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_tasks', jsonEncode(_savedTasks));
    } catch (e) {
      print('Error saving saved tasks: $e');
    }
  }

  Future<void> saveWorklist(List<Map<String, String>> activeItems) async {
    for (var item in activeItems) {
      _savedTasks.add({
        'name': item['name'],
        'time': item['time'],
        'completedDays': <String, bool>{},
        'expanded': true,
      });
    }
    await _saveSavedTasks();
    notifyListeners();
  }

  Future<void> deleteSavedTask(int index) async {
    if (index >= 0 && index < _savedTasks.length) {
      _savedTasks.removeAt(index);
      await _saveSavedTasks();
      notifyListeners();
    }
  }

  Future<void> updateSavedTaskCompletedDays(int index, Map<String, bool> completedDays) async {
    if (index >= 0 && index < _savedTasks.length) {
      _savedTasks[index]['completedDays'] = completedDays;
      await _saveSavedTasks();
      notifyListeners();
    }
  }

  Future<void> updateSavedTaskNameAndTime(int index, String name, String time) async {
    if (index >= 0 && index < _savedTasks.length) {
      _savedTasks[index]['name'] = name;
      _savedTasks[index]['time'] = time;
      await _saveSavedTasks();
      notifyListeners();
    }
  }

  Future<void> addSavedTask(String name, String time) async {
    _savedTasks.add({
      'name': name,
      'time': time,
      'completedDays': <String, bool>{},
      'expanded': false,
    });
    await _saveSavedTasks();
    notifyListeners();
  }

  Future<void> _loadFocusSessionsCleared() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _focusSessionsCleared = prefs.getInt('focus_sessions_cleared') ?? 0;
    } catch (e) {
      print('Error loading focus sessions cleared: $e');
    }
  }

  Future<void> _saveFocusSessionsCleared() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('focus_sessions_cleared', _focusSessionsCleared);
    } catch (e) {
      print('Error saving focus sessions cleared: $e');
    }
  }

  Future<void> incrementFocusSessionsCleared({String? name, int? mins}) async {
    _focusSessionsCleared++;
    await _saveFocusSessionsCleared();
    // Record history entry
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    _focusHistory.insert(0, {
      'name': name, // null = custom session
      'mins': mins ?? 0,
      'time': timeStr,
    });
    await _saveFocusHistory();
    notifyListeners();
  }

  Future<void> _loadFocusHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('focus_history');
      if (raw != null) {
        final List<dynamic> decoded = jsonDecode(raw);
        _focusHistory = decoded.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Error loading focus history: $e');
    }
  }

  Future<void> _saveFocusHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('focus_history', jsonEncode(_focusHistory));
    } catch (e) {
      print('Error saving focus history: $e');
    }
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  void _listenToConnectivity() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _isConnected = result != ConnectivityResult.none;
      notifyListeners();
    });
  }
}
