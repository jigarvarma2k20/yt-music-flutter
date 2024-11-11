import 'package:flutter/material.dart';
import 'package:yt_music/themes/dark_theme.dart';
import 'package:yt_music/themes/light_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkMode;

  set setThemeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  //toggle theme
  void toggleTheme() {
    setThemeData = themeData == darkMode ? lightMode : darkMode;
  }
}
