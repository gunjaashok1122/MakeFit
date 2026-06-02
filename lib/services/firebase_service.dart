import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout_model.dart';
import '../models/activity_model.dart';
import '../models/water_model.dart';
import '../models/body_stats_model.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._init();
  bool _isFirebaseAvailable = false;

  FirebaseService._init() {
    _checkFirebaseAvailability();
  }

  void _checkFirebaseAvailability() {
    try {
      // Check if Firebase is initialized and accessible
      final auth = FirebaseAuth.instance;
      _isFirebaseAvailable = true;
      print('Firebase services connected successfully.');
    } catch (e) {
      print('Firebase not configured. Operating in Offline/Local Mode: $e');
      _isFirebaseAvailable = false;
    }
  }

  bool get isFirebaseAvailable => _isFirebaseAvailable;

  // --- Auth Integration ---
  Future<UserCredential?> signUpWithEmail(String name, String email, String password) async {
    if (!_isFirebaseAvailable) return null;
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
      }
      return credential;
    } catch (e) {
      print('Firebase Auth Sign Up failed: $e');
      return null;
    }
  }

  Future<UserCredential?> loginWithEmail(String email, String password) async {
    if (!_isFirebaseAvailable) return null;
    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Firebase Auth Sign In failed: $e');
      return null;
    }
  }

  Future<void> logOut() async {
    if (!_isFirebaseAvailable) return;
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Firebase Auth Sign Out failed: $e');
    }
  }

  // --- Cloud Sync Integrations (Firestore) ---
  Future<void> syncWorkoutToCloud(WorkoutModel workout, String userId) async {
    if (!_isFirebaseAvailable) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .doc(workout.id)
          .set(workout.toMap());
      print('Workout ${workout.id} synchronized to Firestore.');
    } catch (e) {
      print('Failed to sync workout to cloud: $e');
    }
  }

  Future<void> syncActivityToCloud(ActivityModel activity, String userId) async {
    if (!_isFirebaseAvailable) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('activities')
          .doc(activity.id)
          .set(activity.toMap());
    } catch (e) {
      print('Failed to sync activity to cloud: $e');
    }
  }

  Future<void> syncWaterToCloud(WaterModel water, String userId) async {
    if (!_isFirebaseAvailable) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('water_logs')
          .doc(water.id)
          .set(water.toMap());
    } catch (e) {
      print('Failed to sync water to cloud: $e');
    }
  }

  Future<void> syncBodyStatsToCloud(BodyStatsModel stats, String userId) async {
    if (!_isFirebaseAvailable) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('body_stats')
          .doc(stats.id)
          .set(stats.toMap());
    } catch (e) {
      print('Failed to sync body stats to cloud: $e');
    }
  }

  Future<List<Map<String, dynamic>>> pullWorkoutsFromCloud(String userId) async {
    if (!_isFirebaseAvailable) return [];
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Failed to pull workouts from cloud: $e');
      return [];
    }
  }

  // --- GENERIC CROSS-DEVICE SYNC METHODS ---
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> syncRecordToCloud(String collectionName, String recordId, Map<String, dynamic> data) async {
    final userId = currentUserId;
    if (!_isFirebaseAvailable || userId == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection(collectionName)
          .doc(recordId)
          .set(data);
      print('Synced $collectionName/$recordId to Firestore.');
    } catch (e) {
      print('Failed to sync $collectionName to cloud: $e');
    }
  }

  Future<void> deleteRecordFromCloud(String collectionName, String recordId) async {
    final userId = currentUserId;
    if (!_isFirebaseAvailable || userId == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection(collectionName)
          .doc(recordId)
          .delete();
      print('Deleted $collectionName/$recordId from Firestore.');
    } catch (e) {
      print('Failed to delete $collectionName from cloud: $e');
    }
  }

  Future<List<Map<String, dynamic>>> pullCollectionFromCloud(String collectionName) async {
    final userId = currentUserId;
    if (!_isFirebaseAvailable || userId == null) return [];
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection(collectionName)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Failed to pull $collectionName from cloud: $e');
      return [];
    }
  }

  Future<void> syncUserSettingsToCloud({
    required String dob,
    required List<Map<String, dynamic>> savedTasks,
    required int focusSessionsCleared,
    required List<Map<String, dynamic>> focusHistory,
  }) async {
    final userId = currentUserId;
    if (!_isFirebaseAvailable || userId == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('config')
          .set({
            'dob': dob,
            'saved_tasks': jsonEncode(savedTasks),
            'focus_sessions_cleared': focusSessionsCleared,
            'focus_history': jsonEncode(focusHistory),
          });
      print('Synced user settings to cloud.');
    } catch (e) {
      print('Failed to sync user settings: $e');
    }
  }

  Future<Map<String, dynamic>?> pullUserSettingsFromCloud() async {
    final userId = currentUserId;
    if (!_isFirebaseAvailable || userId == null) return null;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('config')
          .get();
      return doc.data();
    } catch (e) {
      print('Failed to pull user settings from cloud: $e');
      return null;
    }
  }
}
