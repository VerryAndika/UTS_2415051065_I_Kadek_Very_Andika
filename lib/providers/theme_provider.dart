import 'package:flutter/material.dart';

// Shared state tema aplikasi (fitur tambahan: dark mode).
class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void setDark(bool value) {
    final next = value ? ThemeMode.dark : ThemeMode.light;
    if (next == _mode) return;
    _mode = next;
    notifyListeners();
  }

  void toggle() => setDark(!isDark);
}
