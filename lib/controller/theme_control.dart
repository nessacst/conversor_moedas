import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  bool isDartTheme = false;

  static ThemeController instance = ThemeController();

  changeTheme() {
    isDartTheme = !isDartTheme;
    notifyListeners();
  }
}
