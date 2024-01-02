//ThemeProvider.dart
import 'package:flutter/material.dart';
// import 'package:meditation_app/models/tip.dart';
// import 'package:meditation_app/services/TodoService.dart';
// import 'dart:js';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// final themeProvider = Provider.of<ThemeProvider>(context as BuildContext);
class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData;

  ThemeProvider(this._themeData);

  getTheme() => _themeData;

  setTheme(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  // final currentTheme = themeProvider.getTheme();
}
