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

  bool get isFirebaseAvailable {
    if (!_isFirebaseAvailable) {
      _checkFirebaseAvailability();
    }
    return _isFirebaseAvailable;
  }

  // --- Auth Integration ---
  Future<UserCredential?> signUpWithEmail(String name, String email, String password) async {
    if (!isFirebaseAvailable) return null;
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      String msg = 'Sign up failed.';
      if (e.code == 'email-already-in-use') {
        msg = 'An account already exists with this email.';
      } else if (e.code == 'invalid-email') {
        msg = 'The email address is invalid.';
      } else if (e.code == 'weak-password') {
        msg = 'The password is too weak.';
      } else if (e.message != null) {
        msg = e.message!;
      }
      throw Exception(msg);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  Future<UserCredential?> loginWithEmail(String email, String password) async {
    if (!isFirebaseAvailable) return null;
    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      String msg = 'Login failed.';
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        msg = 'Incorrect email or password.';
      } else if (e.code == 'invalid-email') {
        msg = 'The email address is invalid.';
      } else if (e.code == 'user-disabled') {
        msg = 'This user account has been disabled.';
      } else if (e.message != null) {
        msg = e.message!;
      }
      throw Exception(msg);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    if (!isFirebaseAvailable) return null;
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      return await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Google Sign In failed.');
    } catch (e) {
      throw Exception('Google Sign In failed: $e');
    }
  }

  Future<void> syncUserProfileToCloud(String userId, String name, String email, String fitnessLevel) async {
    if (!isFirebaseAvailable) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('config')
          .set({
            'name': name,
            'email': email,
            'fitness_level': fitnessLevel,
            'updated_at': DateTime.now().toIso8601String(),
          });
      print('User profile synced to cloud.');
    } catch (e) {
      print('Failed to sync user profile to cloud: $e');
    }
  }

  Future<Map<String, dynamic>?> pullUserProfileFromCloud(String userId) async {
    if (!isFirebaseAvailable) return null;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('config')
          .get();
      return doc.data();
    } catch (e) {
      print('Failed to pull user profile from cloud: $e');
      return null;
    }
  }

  Future<void> logOut() async {
    if (!isFirebaseAvailable) return;
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Firebase Auth Sign Out failed: $e');
    }
  }

  // --- Cloud Sync Integrations (Firestore) ---
  Future<void> syncWorkoutToCloud(WorkoutModel workout, String userId) async {
    if (!isFirebaseAvailable) return;
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
    if (!isFirebaseAvailable) return;
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
    if (!isFirebaseAvailable) return;
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
    if (!isFirebaseAvailable) return;
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
    if (!isFirebaseAvailable) return [];
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
    if (!isFirebaseAvailable || userId == null) return;
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
    if (!isFirebaseAvailable || userId == null) return;
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
    if (!isFirebaseAvailable || userId == null) return [];
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
    if (!isFirebaseAvailable || userId == null) return;
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
    if (!isFirebaseAvailable || userId == null) return null;
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
