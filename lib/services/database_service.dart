import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'firebase_service.dart';
import '../models/workout_model.dart';
import '../models/activity_model.dart';
import '../models/water_model.dart';
import '../models/body_stats_model.dart';
import '../models/sleep_model.dart';
import '../models/mood_model.dart';
import '../models/goal_model.dart';
import '../models/badge_model.dart';
import '../models/challenge_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  bool _useInMemoryFallback = false;

  // In-memory tables for Web/Desktop fallback testing
  final Map<String, List<Map<String, dynamic>>> _memoryDb = {
    'workouts': [],
    'activity_logs': [],
    'water_logs': [],
    'body_stats': [],
    'sleep_logs': [],
    'mood_logs': [],
    'goals': [],
    'badges': [],
    'challenges': [],
  };

  DatabaseService._init() {
    _checkFallback();
  }

  void _checkFallback() {
    // Detect if running on unsupported platform or if we should use fallback
    // In Flutter, sqflite doesn't work on Windows/Web out of the box without sqflite_common_ffi
    // We will automatically toggle the memory fallback if we detect platform errors
    if (kIsWeb) {
      _useInMemoryFallback = true;
      _seedMemoryDatabase();
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (_useInMemoryFallback) {
      throw DatabaseException('Using In-Memory Fallback');
    }

    try {
      _database = await _initDB('makefit.db');
      return _database!;
    } catch (e) {
      print('Database init failed, falling back to In-Memory DB: $e');
      _useInMemoryFallback = true;
      _seedMemoryDatabase();
      throw e;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE workouts (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        duration INTEGER NOT NULL,
        calories INTEGER NOT NULL,
        date TEXT NOT NULL,
        heart_rate_history TEXT,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE activity_logs (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        steps INTEGER NOT NULL,
        calories INTEGER NOT NULL,
        duration INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE water_logs (
        id TEXT PRIMARY KEY,
        amount INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE body_stats (
        id TEXT PRIMARY KEY,
        weight REAL NOT NULL,
        height REAL NOT NULL,
        bmi REAL NOT NULL,
        body_fat REAL NOT NULL,
        muscle_mass REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sleep_logs (
        id TEXT PRIMARY KEY,
        duration REAL NOT NULL,
        quality TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE mood_logs (
        id TEXT PRIMARY KEY,
        mood TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        target REAL NOT NULL,
        current REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE badges (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        icon_key TEXT NOT NULL,
        is_unlocked INTEGER NOT NULL,
        unlocked_date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE challenges (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        target_value REAL NOT NULL,
        current_value REAL NOT NULL,
        days_remaining INTEGER NOT NULL,
        is_joined INTEGER NOT NULL,
        is_completed INTEGER NOT NULL
      )
    ''');

    await _seedDB(db);
  }

  Future _seedDB(Database db) async {
    // Seeds database
    final now = DateTime.now();
    final uuid = Uuid();

    // Workouts seeds
    final seedWorkouts = [
      WorkoutModel(
        id: uuid.v4(),
        type: 'Running',
        category: 'Running',
        duration: 45,
        calories: 450,
        date: now.subtract(Duration(days: 1)),
        heartRateHistory: [110, 115, 128, 135, 142, 138, 125, 130, 118],
        notes: 'Felt great. Good running pace.',
      ),
      WorkoutModel(
        id: uuid.v4(),
        type: 'Gym Training',
        category: 'Gym',
        duration: 60,
        calories: 380,
        date: now.subtract(Duration(days: 3)),
        heartRateHistory: [95, 105, 120, 118, 130, 110, 125, 100],
        notes: 'Push day routine.',
      ),
      WorkoutModel(
        id: uuid.v4(),
        type: 'Yoga session',
        category: 'Yoga',
        duration: 30,
        calories: 120,
        date: now.subtract(Duration(days: 5)),
        heartRateHistory: [75, 80, 85, 82, 88, 80, 78],
        notes: 'Flexibility and breathing practice.',
      ),
    ];

    for (var w in seedWorkouts) {
      await db.insert('workouts', w.toMap());
    }

    // Activity seeds
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      // Steps: ~6000 to 11000
      final steps = 6500 + (i * 750) % 5000;
      final cals = (steps * 0.04).round();
      final mins = (steps * 0.008).round();
      final act = ActivityModel(
        id: uuid.v4(),
        type: 'Walking',
        steps: steps,
        calories: cals,
        duration: mins,
        date: date,
      );
      await db.insert('activity_logs', act.toMap());
    }

    // Water logs seeds
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      for (int j = 0; j < 4; j++) {
        await db.insert('water_logs', {
          'id': uuid.v4(),
          'amount': 250 + (j * 250) % 500,
          'date': date.subtract(Duration(hours: j * 2)).toIso8601String(),
        });
      }
    }

    // Body Stats seeds
    for (int i = 5; i >= 0; i--) {
      final date = now.subtract(Duration(days: i * 7));
      final weight = 74.5 - (5 - i) * 0.4; // Progress downward weight
      final height = 175.0;
      final bmi = BodyStatsModel.calculateBMI(weight, height);
      final stats = BodyStatsModel(
        id: uuid.v4(),
        weight: weight,
        height: height,
        bmi: bmi,
        bodyFat: 19.5 - (5 - i) * 0.2,
        muscleMass: 55.8 + (5 - i) * 0.1,
        date: date,
      );
      await db.insert('body_stats', stats.toMap());
    }

    // Sleep seeds
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      await db.insert('sleep_logs', {
        'id': uuid.v4(),
        'duration': 6.5 + (i * 0.3) % 2.5,
        'quality': i % 3 == 0 ? 'Excellent' : (i % 2 == 0 ? 'Good' : 'Fair'),
        'date': date.toIso8601String(),
      });
    }

    // Mood seeds
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final moods = ['Energetic', 'Calm', 'Tired', 'Stressed', 'Happy'];
      await db.insert('mood_logs', {
        'id': uuid.v4(),
        'mood': moods[i % moods.length],
        'date': date.toIso8601String(),
      });
    }

    // Goals seeds
    final seedGoals = [
      GoalModel(id: uuid.v4(), type: 'Steps', target: 10000, current: 7245, date: now),
      GoalModel(id: uuid.v4(), type: 'Calories', target: 900, current: 680, date: now),
      GoalModel(id: uuid.v4(), type: 'Water', target: 3000, current: 2100, date: now),
      GoalModel(id: uuid.v4(), type: 'Weight', target: 70.0, current: 72.5, date: now),
    ];
    for (var g in seedGoals) {
      await db.insert('goals', g.toMap());
    }

    // Badges seeds
    final seedBadges = [
      BadgeModel(id: 'badge1', title: 'Early Bird', description: 'Log a workout before 7 AM', iconKey: 'early_bird', isUnlocked: true, unlockedDate: now.subtract(Duration(days: 3))),
      BadgeModel(id: 'badge2', title: 'Hydration Hero', description: 'Meet your daily water goal 5 days in a row', iconKey: 'water_hero', isUnlocked: false),
      BadgeModel(id: 'badge3', title: '10k Club', description: 'Walk more than 10,000 steps in one day', iconKey: 'steps_10k', isUnlocked: true, unlockedDate: now.subtract(Duration(days: 2))),
      BadgeModel(id: 'badge4', title: 'Centurion Workout', description: 'Log a workout of 100+ minutes or 600+ kcal', iconKey: 'centurion', isUnlocked: false),
      BadgeModel(id: 'badge5', title: 'Fitness Streak Tracker', description: 'Maintain a 7-day fitness workout streak', iconKey: 'streak_7', isUnlocked: false),
    ];
    for (var b in seedBadges) {
      await db.insert('badges', b.toMap());
    }

    // Challenges seeds
    final seedChallenges = [
      ChallengeModel(
        id: 'challenge1',
        title: '7-Day Hydration Sprint',
        description: 'Drink at least 2.5L of water every day for 7 days.',
        type: 'Water',
        targetValue: 7.0,
        currentValue: 4.0,
        daysRemaining: 3,
        isJoined: true,
        isCompleted: false,
      ),
      ChallengeModel(
        id: 'challenge2',
        title: '100k Steps Monthly Sprint',
        description: 'Complete 100,000 steps this month.',
        type: 'Steps',
        targetValue: 100000.0,
        currentValue: 65400.0,
        daysRemaining: 12,
        isJoined: true,
        isCompleted: false,
      ),
      ChallengeModel(
        id: 'challenge3',
        title: 'Gym Warrior Week',
        description: 'Log 5 gym/strength workouts of at least 45 minutes this week.',
        type: 'Workout',
        targetValue: 5.0,
        currentValue: 0.0,
        daysRemaining: 5,
        isJoined: false,
        isCompleted: false,
      ),
    ];
    for (var c in seedChallenges) {
      await db.insert('challenges', c.toMap());
    }
  }

  void _seedMemoryDatabase() {
    final now = DateTime.now();
    final uuid = Uuid();

    // Seed workouts
    _memoryDb['workouts'] = [
      WorkoutModel(
        id: uuid.v4(),
        type: 'Running',
        category: 'Running',
        duration: 45,
        calories: 450,
        date: now.subtract(Duration(days: 1)),
        heartRateHistory: [110, 115, 128, 135, 142, 138, 125, 130, 118],
        notes: 'Felt great. Good running pace.',
      ).toMap(),
      WorkoutModel(
        id: uuid.v4(),
        type: 'Gym Training',
        category: 'Gym',
        duration: 60,
        calories: 380,
        date: now.subtract(Duration(days: 3)),
        heartRateHistory: [95, 105, 120, 118, 130, 110, 125, 100],
        notes: 'Push day routine.',
      ).toMap(),
      WorkoutModel(
        id: uuid.v4(),
        type: 'Yoga session',
        category: 'Yoga',
        duration: 30,
        calories: 120,
        date: now.subtract(Duration(days: 5)),
        heartRateHistory: [75, 80, 85, 82, 88, 80, 78],
        notes: 'Flexibility and breathing practice.',
      ).toMap(),
    ];

    // Seed activities
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final steps = 6500 + (i * 750) % 5000;
      final cals = (steps * 0.04).round();
      final mins = (steps * 0.008).round();
      _memoryDb['activity_logs']!.add(ActivityModel(
        id: uuid.v4(),
        type: 'Walking',
        steps: steps,
        calories: cals,
        duration: mins,
        date: date,
      ).toMap());
    }

    // Seed water logs
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      for (int j = 0; j < 4; j++) {
        _memoryDb['water_logs']!.add({
          'id': uuid.v4(),
          'amount': 250 + (j * 250) % 500,
          'date': date.subtract(Duration(hours: j * 2)).toIso8601String(),
        });
      }
    }

    // Seed body stats
    for (int i = 5; i >= 0; i--) {
      final date = now.subtract(Duration(days: i * 7));
      final weight = 74.5 - (5 - i) * 0.4;
      final height = 175.0;
      final bmi = BodyStatsModel.calculateBMI(weight, height);
      _memoryDb['body_stats']!.add(BodyStatsModel(
        id: uuid.v4(),
        weight: weight,
        height: height,
        bmi: bmi,
        bodyFat: 19.5 - (5 - i) * 0.2,
        muscleMass: 55.8 + (5 - i) * 0.1,
        date: date,
      ).toMap());
    }

    // Seed sleep
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      _memoryDb['sleep_logs']!.add({
        'id': uuid.v4(),
        'duration': 6.5 + (i * 0.3) % 2.5,
        'quality': i % 3 == 0 ? 'Excellent' : (i % 2 == 0 ? 'Good' : 'Fair'),
        'date': date.toIso8601String(),
      });
    }

    // Seed mood
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final moods = ['Energetic', 'Calm', 'Tired', 'Stressed', 'Happy'];
      _memoryDb['mood_logs']!.add({
        'id': uuid.v4(),
        'mood': moods[i % moods.length],
        'date': date.toIso8601String(),
      });
    }

    // Seed goals
    _memoryDb['goals'] = [
      GoalModel(id: uuid.v4(), type: 'Steps', target: 10000, current: 7245, date: now).toMap(),
      GoalModel(id: uuid.v4(), type: 'Calories', target: 900, current: 680, date: now).toMap(),
      GoalModel(id: uuid.v4(), type: 'Water', target: 3000, current: 2100, date: now).toMap(),
      GoalModel(id: uuid.v4(), type: 'Weight', target: 70.0, current: 72.5, date: now).toMap(),
    ];

    // Seed badges
    _memoryDb['badges'] = [
      BadgeModel(id: 'badge1', title: 'Early Bird', description: 'Log a workout before 7 AM', iconKey: 'early_bird', isUnlocked: true, unlockedDate: now.subtract(Duration(days: 3))).toMap(),
      BadgeModel(id: 'badge2', title: 'Hydration Hero', description: 'Meet your daily water goal 5 days in a row', iconKey: 'water_hero', isUnlocked: false).toMap(),
      BadgeModel(id: 'badge3', title: '10k Club', description: 'Walk more than 10,000 steps in one day', iconKey: 'steps_10k', isUnlocked: true, unlockedDate: now.subtract(Duration(days: 2))).toMap(),
      BadgeModel(id: 'badge4', title: 'Centurion Workout', description: 'Log a workout of 100+ minutes or 600+ kcal', iconKey: 'centurion', isUnlocked: false).toMap(),
      BadgeModel(id: 'badge5', title: 'Fitness Streak Tracker', description: 'Maintain a 7-day fitness workout streak', iconKey: 'streak_7', isUnlocked: false).toMap(),
    ];

    // Seed challenges
    _memoryDb['challenges'] = [
      ChallengeModel(
        id: 'challenge1',
        title: '7-Day Hydration Sprint',
        description: 'Drink at least 2.5L of water every day for 7 days.',
        type: 'Water',
        targetValue: 7.0,
        currentValue: 4.0,
        daysRemaining: 3,
        isJoined: true,
        isCompleted: false,
      ).toMap(),
      ChallengeModel(
        id: 'challenge2',
        title: '100k Steps Monthly Sprint',
        description: 'Complete 100,000 steps this month.',
        type: 'Steps',
        targetValue: 100000.0,
        currentValue: 65400.0,
        daysRemaining: 12,
        isJoined: true,
        isCompleted: false,
      ).toMap(),
      ChallengeModel(
        id: 'challenge3',
        title: 'Gym Warrior Week',
        description: 'Log 5 gym/strength workouts of at least 45 minutes this week.',
        type: 'Workout',
        targetValue: 5.0,
        currentValue: 0.0,
        daysRemaining: 5,
        isJoined: false,
        isCompleted: false,
      ).toMap(),
    ];
  }

  // --- CRUD OPERATIONS ---
  
  // Custom query router
  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<dynamic>? whereArgs, String? orderBy}) async {
    if (!_useInMemoryFallback) {
      try {
        final db = await database;
        return await db.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy);
      } catch (e) {
        print('Query failed, falling back to In-Memory DB: $e');
        _useInMemoryFallback = true;
        _seedMemoryDatabase();
      }
    }
    
    List<Map<String, dynamic>> list = List.from(_memoryDb[table] ?? []);
    // Apply where filters if in-memory
    if (where != null && whereArgs != null) {
      // Simple manual mock implementations for common queries
      if (where.contains('id = ?')) {
        list = list.where((item) => item['id'] == whereArgs[0]).toList();
      } else if (where.contains('type = ?')) {
        list = list.where((item) => item['type'] == whereArgs[0]).toList();
      }
    }
    return list;
  }

  Future<int> insert(String table, Map<String, dynamic> values, {bool syncToCloud = true}) async {
    int result = 0;
    if (!_useInMemoryFallback) {
      try {
        final db = await database;
        result = await db.insert(table, values, conflictAlgorithm: ConflictAlgorithm.replace);
      } catch (e) {
        print('Insert failed, falling back to In-Memory DB: $e');
        _useInMemoryFallback = true;
        _seedMemoryDatabase();
        _memoryDb[table]!.add(values);
        result = 1;
      }
    } else {
      _memoryDb[table]!.add(values);
      result = 1;
    }
    
    if (syncToCloud && result > 0) {
      _syncInsert(table, values);
    }
    return result;
  }

  Future<int> update(String table, Map<String, dynamic> values, {String? where, List<dynamic>? whereArgs, bool syncToCloud = true}) async {
    int result = 0;
    if (!_useInMemoryFallback) {
      try {
        final db = await database;
        result = await db.update(table, values, where: where, whereArgs: whereArgs);
      } catch (e) {
        print('Update failed, falling back to In-Memory DB: $e');
        _useInMemoryFallback = true;
        _seedMemoryDatabase();
        result = _updateMemory(table, values, where: where, whereArgs: whereArgs);
      }
    } else {
      result = _updateMemory(table, values, where: where, whereArgs: whereArgs);
    }
    
    if (syncToCloud && result > 0) {
      _syncUpdate(table, values, where, whereArgs);
    }
    return result;
  }

  int _updateMemory(String table, Map<String, dynamic> values, {String? where, List<dynamic>? whereArgs}) {
    if (where != null && where.contains('id = ?') && whereArgs != null && whereArgs.isNotEmpty) {
      final id = whereArgs[0];
      final index = _memoryDb[table]!.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        final updated = Map<String, dynamic>.from(_memoryDb[table]![index]);
        updated.addAll(values);
        _memoryDb[table]![index] = updated;
        return 1;
      }
    } else if (where != null && where.contains('type = ?') && whereArgs != null && whereArgs.isNotEmpty) {
      final type = whereArgs[0];
      int count = 0;
      for (int i = 0; i < _memoryDb[table]!.length; i++) {
        if (_memoryDb[table]![i]['type'] == type) {
          final updated = Map<String, dynamic>.from(_memoryDb[table]![i]);
          updated.addAll(values);
          _memoryDb[table]![i] = updated;
          count++;
        }
      }
      return count;
    }
    return 0;
  }

  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs, bool syncToCloud = true}) async {
    int result = 0;
    if (!_useInMemoryFallback) {
      try {
        final db = await database;
        result = await db.delete(table, where: where, whereArgs: whereArgs);
      } catch (e) {
        print('Delete failed, falling back to In-Memory DB: $e');
        _useInMemoryFallback = true;
        _seedMemoryDatabase();
        result = _deleteMemory(table, where, whereArgs);
      }
    } else {
      result = _deleteMemory(table, where, whereArgs);
    }
    
    if (syncToCloud && result > 0) {
      _syncDelete(table, where, whereArgs);
    }
    return result;
  }

  int _deleteMemory(String table, String? where, List<dynamic>? whereArgs) {
    if (where != null && where.contains('id = ?') && whereArgs != null && whereArgs.isNotEmpty) {
      final id = whereArgs[0];
      final lengthBefore = _memoryDb[table]!.length;
      _memoryDb[table]!.removeWhere((item) => item['id'] == id);
      return lengthBefore - _memoryDb[table]!.length;
    }
    return 0;
  }

  // --- CLOUD SYNC HELPERS ---

  void _syncInsert(String table, Map<String, dynamic> values) {
    final recordId = values['id']?.toString();
    if (recordId != null) {
      FirebaseService.instance.syncRecordToCloud(table, recordId, values);
    }
  }

  void _syncUpdate(String table, Map<String, dynamic> values, String? where, List<dynamic>? whereArgs) async {
    if (where != null && where.contains('id = ?') && whereArgs != null && whereArgs.isNotEmpty) {
      final recordId = whereArgs[0].toString();
      final rows = await query(table, where: 'id = ?', whereArgs: [recordId]);
      if (rows.isNotEmpty) {
        FirebaseService.instance.syncRecordToCloud(table, recordId, rows.first);
      }
    }
  }

  void _syncDelete(String table, String? where, List<dynamic>? whereArgs) {
    if (where != null && where.contains('id = ?') && whereArgs != null && whereArgs.isNotEmpty) {
      final recordId = whereArgs[0].toString();
      FirebaseService.instance.deleteRecordFromCloud(table, recordId);
    }
  }

  Future<void> pullAndSyncAllFromCloud(String userId) async {
    final tables = [
      'workouts',
      'activity_logs',
      'water_logs',
      'body_stats',
      'sleep_logs',
      'mood_logs',
      'goals',
      'badges',
      'challenges'
    ];

    for (final table in tables) {
      try {
        final records = await FirebaseService.instance.pullCollectionFromCloud(table);
        if (records.isEmpty) continue;

        print('Pulled ${records.length} records for $table from cloud.');

        // Overwrite or insert locally without triggering sync back
        if (!_useInMemoryFallback) {
          final db = await database;
          await db.transaction((txn) async {
            for (final record in records) {
              await txn.insert(
                table,
                record,
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          });
        } else {
          // In-memory fallback
          for (final record in records) {
            final id = record['id'];
            if (id != null) {
              final index = _memoryDb[table]!.indexWhere((item) => item['id'] == id);
              if (index != -1) {
                _memoryDb[table]![index] = record;
              } else {
                _memoryDb[table]!.add(record);
              }
            }
          }
        }
      } catch (e) {
        print('Error syncing table $table from cloud: $e');
      }
    }
  }

  Future<void> clearAllData() async {
    final tables = [
      'workouts',
      'activity_logs',
      'water_logs',
      'body_stats',
      'sleep_logs',
      'mood_logs',
      'goals',
      'badges',
      'challenges'
    ];
    if (!_useInMemoryFallback) {
      try {
        final db = await database;
        await db.transaction((txn) async {
          for (final table in tables) {
            await txn.delete(table);
          }
        });
      } catch (e) {
        print('Failed to clear SQLite DB: $e');
      }
    }
    
    // Clear memory database
    for (final table in tables) {
      _memoryDb[table]?.clear();
    }
  }

  Future<void> reseedDatabase() async {
    await clearAllData();
    if (!_useInMemoryFallback) {
      try {
        final db = await database;
        await _seedDB(db);
      } catch (e) {
        print('Failed to reseed database: $e');
      }
    } else {
      _seedMemoryDatabase();
    }
  }
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);
  @override
  String toString() => message;
}
