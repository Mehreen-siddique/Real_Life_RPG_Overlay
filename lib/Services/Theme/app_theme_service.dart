import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme persistence using `SharedPreferences`.
class AppThemeService extends ChangeNotifier {
  static const String darkModePrefsKey = 'dark_mode_enabled';

  bool _isDarkMode;
  late final Stream<User?> _authStream;

  AppThemeService({required bool initialDarkMode}) : _isDarkMode = initialDarkMode {
    _authStream = FirebaseAuth.instance.authStateChanges();
    _authStream.listen((user) {
      if (user != null) {
        _loadForUser(user.uid);
      }
    });
  }

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await prefs.setBool('${darkModePrefsKey}_$uid', value);
      } else {
        await prefs.setBool(darkModePrefsKey, value);
      }
    } catch (e) {
      debugPrint('AppThemeService: failed to persist dark mode: $e');
    }

    // Optional: also store for the current user (best-effort).
    try {
      final authUid = await _tryGetCurrentUid();
      if (authUid != null) {
        await FirebaseFirestore.instance.collection('users').doc(authUid).set({
          'settings': {
            'darkMode': value,
          }
        }, SetOptions(merge: true));
      }
    } catch (_) {
      // ignore best-effort persistence to Firestore
    }
  }

  static Future<bool> loadInitialDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      return prefs.getBool('${darkModePrefsKey}_$uid') ??
          prefs.getBool(darkModePrefsKey) ??
          false;
    }
    return prefs.getBool(darkModePrefsKey) ?? false;
  }

  Future<void> _loadForUser(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final local = prefs.getBool('${darkModePrefsKey}_$uid');
      if (local != null) {
        if (_isDarkMode != local) {
          _isDarkMode = local;
          notifyListeners();
        }
        return;
      }

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final remote = ((userDoc.data()?['settings'] as Map<String, dynamic>?)?['darkMode']) as bool?;
      if (remote != null && _isDarkMode != remote) {
        _isDarkMode = remote;
        notifyListeners();
      }
    } catch (_) {
      // best effort
    }
  }

  Future<String?> _tryGetCurrentUid() async {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }
}

