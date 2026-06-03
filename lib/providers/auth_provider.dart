import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _userId;
  String _userName = 'Alex Johnson';
  String _userEmail = 'alex@example.com';
  String _fitnessLevel = 'Intermediate';

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get userId => _userId;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get fitnessLevel => _fitnessLevel;

  AuthProvider() {
    checkAuth();
  }

  Future<void> checkAuth() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('is_authenticated') ?? false;
    if (_isAuthenticated) {
      _userId = prefs.getString('user_id') ?? 'alex_123';
      _userName = prefs.getString('user_name') ?? 'Alex Johnson';
      _userEmail = prefs.getString('user_email') ?? 'alex@example.com';
      _fitnessLevel = prefs.getString('fitness_level') ?? 'Intermediate';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (FirebaseService.instance.isFirebaseAvailable) {
        final credential = await FirebaseService.instance.loginWithEmail(email, password);
        if (credential == null || credential.user == null) {
          _isLoading = false;
          notifyListeners();
          return 'Authentication failed.';
        }
        _userId = credential.user!.uid;
        _userEmail = credential.user!.email ?? email;

        // Fetch name dynamically from Firestore
        final profile = await FirebaseService.instance.pullUserProfileFromCloud(_userId!);
        if (profile != null) {
          _userName = profile['name'] ?? credential.user!.displayName ?? _userName;
          _fitnessLevel = profile['fitness_level'] ?? _fitnessLevel;
        } else {
          _userName = credential.user!.displayName ?? email.split('@')[0];
        }

        // Store user in local SQLite for offline access
        await DatabaseService.instance.insert('users', {
          'id': _userId!,
          'name': _userName,
          'email': _userEmail,
          'password': password,
          'fitness_level': _fitnessLevel,
        }, syncToCloud: false);
      } else {
        // Offline / Local Mode validation
        await Future.delayed(const Duration(milliseconds: 500));
        
        final localUsers = await DatabaseService.instance.query(
          'users',
          where: 'email = ?',
          whereArgs: [email],
        );
        if (localUsers.isEmpty) {
          _isLoading = false;
          notifyListeners();
          return 'No user found with this email.';
        }

        final userMap = localUsers.first;
        if (userMap['password'] != password) {
          _isLoading = false;
          notifyListeners();
          return 'Incorrect password.';
        }

        _userId = userMap['id']?.toString() ?? 'user_${email.hashCode}';
        _userName = userMap['name']?.toString() ?? '';
        _userEmail = userMap['email']?.toString() ?? email;
        _fitnessLevel = userMap['fitness_level']?.toString() ?? 'Intermediate';
      }

      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', true);
      await prefs.setString('user_id', _userId!);
      await prefs.setString('user_name', _userName);
      await prefs.setString('user_email', _userEmail);
      await prefs.setString('fitness_level', _fitnessLevel);

      _isLoading = false;
      notifyListeners();
      return null; // success
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (FirebaseService.instance.isFirebaseAvailable) {
        final credential = await FirebaseService.instance.signUpWithEmail(name, email, password);
        if (credential == null || credential.user == null) {
          _isLoading = false;
          notifyListeners();
          return 'Registration failed.';
        }
        _userId = credential.user!.uid;
        _userName = name;
        _userEmail = email;

        // Sync profile to Firestore
        await FirebaseService.instance.syncUserProfileToCloud(
          _userId!,
          _userName,
          _userEmail,
          _fitnessLevel,
        );

        // Store profile in SQLite local db
        await DatabaseService.instance.insert('users', {
          'id': _userId!,
          'name': _userName,
          'email': _userEmail,
          'password': password,
          'fitness_level': _fitnessLevel,
        }, syncToCloud: false);
      } else {
        // Offline / Local Mode check for duplicate accounts
        await Future.delayed(const Duration(milliseconds: 500));
        
        final existing = await DatabaseService.instance.query(
          'users',
          where: 'email = ?',
          whereArgs: [email],
        );
        if (existing.isNotEmpty) {
          _isLoading = false;
          notifyListeners();
          return 'An account already exists with this email.';
        }

        _userId = 'user_${email.hashCode}';
        _userName = name;
        _userEmail = email;

        // Save profile in SQLite local db
        await DatabaseService.instance.insert('users', {
          'id': _userId!,
          'name': _userName,
          'email': _userEmail,
          'password': password,
          'fitness_level': _fitnessLevel,
        }, syncToCloud: false);
      }

      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', true);
      await prefs.setString('user_id', _userId!);
      await prefs.setString('user_name', _userName);
      await prefs.setString('user_email', _userEmail);
      await prefs.setString('fitness_level', _fitnessLevel);

      _isLoading = false;
      notifyListeners();
      return null; // success
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> loginWithSocial(String provider) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (provider == 'Google' && FirebaseService.instance.isFirebaseAvailable) {
        final credential = await FirebaseService.instance.signInWithGoogle();
        if (credential == null || credential.user == null) {
          _isLoading = false;
          notifyListeners();
          return 'Google authentication failed.';
        }
        _userId = credential.user!.uid;
        _userName = credential.user!.displayName ?? 'Google User';
        _userEmail = credential.user!.email ?? 'google@example.com';
        
        // Sync profile to Firestore
        await FirebaseService.instance.syncUserProfileToCloud(
          _userId!,
          _userName,
          _userEmail,
          _fitnessLevel,
        );

        // Store profile in SQLite local db
        await DatabaseService.instance.insert('users', {
          'id': _userId!,
          'name': _userName,
          'email': _userEmail,
          'password': 'google_auth_placeholder',
          'fitness_level': _fitnessLevel,
        }, syncToCloud: false);
      } else {
        // Mock social login for local/offline mode or Apple provider
        await Future.delayed(const Duration(milliseconds: 1000));
        _userId = '${provider.toLowerCase()}_user_123';
        _userName = 'Alex Johnson';
        _userEmail = 'alex.johnson@example.com';
        
        // Save to local db
        await DatabaseService.instance.insert('users', {
          'id': _userId!,
          'name': _userName,
          'email': _userEmail,
          'password': 'social_auth_placeholder',
          'fitness_level': _fitnessLevel,
        }, syncToCloud: false);
      }

      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', true);
      await prefs.setString('user_id', _userId!);
      await prefs.setString('user_name', _userName);
      await prefs.setString('user_email', _userEmail);
      await prefs.setString('fitness_level', _fitnessLevel);

      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> updateProfile({required String name, required String fitnessLevel}) async {
    _userName = name;
    _fitnessLevel = fitnessLevel;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _userName);
    await prefs.setString('fitness_level', _fitnessLevel);

    if (_userId != null) {
      // Update in local SQLite
      await DatabaseService.instance.update(
        'users',
        {
          'name': _userName,
          'fitness_level': _fitnessLevel,
        },
        where: 'id = ?',
        whereArgs: [_userId],
        syncToCloud: false,
      );

      // Sync to Firestore
      if (FirebaseService.instance.isFirebaseAvailable) {
        await FirebaseService.instance.syncUserProfileToCloud(
          _userId!,
          _userName,
          _userEmail,
          _fitnessLevel,
        );
      }
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    if (FirebaseService.instance.isFirebaseAvailable) {
      await FirebaseService.instance.logOut();
    } else {
      await Future.delayed(const Duration(milliseconds: 800));
    }

    _isAuthenticated = false;
    _userId = null;
    _userName = 'Alex Johnson';
    _userEmail = 'alex@example.com';

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_authenticated');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('fitness_level');

    _isLoading = false;
    notifyListeners();
  }
}
