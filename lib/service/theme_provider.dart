import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  Future<void> initDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      notifyListeners();
    } catch (e) {
      print('Error initializing dark mode: $e');
    }
  }

  Future<void> toggleDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = !_isDarkMode;
      await prefs.setBool('dark_mode', _isDarkMode);
      notifyListeners();
    } catch (e) {
      print('Error toggling dark mode: $e');
    }
  }
}
