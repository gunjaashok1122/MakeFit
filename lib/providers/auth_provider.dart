import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';

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

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    String name = '';
    if (FirebaseService.instance.isFirebaseAvailable) {
      final credential = await FirebaseService.instance.loginWithEmail(email, password);
      if (credential == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      _userId = credential.user?.uid;
      name = credential.user?.displayName ?? '';
    } else {
      await Future.delayed(const Duration(seconds: 1));
      _userId = 'user_${email.hashCode}';
    }

    if (email.contains('@') && password.length >= 6) {
      _isAuthenticated = true;
      _userEmail = email;
      if (name.isNotEmpty) {
        _userName = name;
      } else {
        // Extract username from email
        _userName = email.split('@')[0];
        _userName = _userName[0].toUpperCase() + _userName.substring(1);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', true);
      await prefs.setString('user_id', _userId!);
      await prefs.setString('user_name', _userName);
      await prefs.setString('user_email', _userEmail);
      await prefs.setString('fitness_level', _fitnessLevel);

      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    if (FirebaseService.instance.isFirebaseAvailable) {
      final credential = await FirebaseService.instance.signUpWithEmail(name, email, password);
      if (credential == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      _userId = credential.user?.uid;
    } else {
      await Future.delayed(const Duration(seconds: 1));
      _userId = 'user_${email.hashCode}';
    }

    if (name.isNotEmpty && email.contains('@') && password.length >= 6) {
      _isAuthenticated = true;
      _userName = name;
      _userEmail = email;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', true);
      await prefs.setString('user_id', _userId!);
      await prefs.setString('user_name', _userName);
      await prefs.setString('user_email', _userEmail);
      await prefs.setString('fitness_level', _fitnessLevel);

      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> loginWithSocial(String provider) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200));

    _isAuthenticated = true;
    _userId = '${provider.toLowerCase()}_user';
    _userName = 'Alex Johnson';
    _userEmail = 'alex.johnson@$provider.com';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_authenticated', true);
    await prefs.setString('user_id', _userId!);
    await prefs.setString('user_name', _userName);
    await prefs.setString('user_email', _userEmail);
    await prefs.setString('fitness_level', _fitnessLevel);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile({required String name, required String fitnessLevel}) async {
    _userName = name;
    _fitnessLevel = fitnessLevel;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _userName);
    await prefs.setString('fitness_level', _fitnessLevel);
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    _isAuthenticated = false;
    _userId = null;

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
