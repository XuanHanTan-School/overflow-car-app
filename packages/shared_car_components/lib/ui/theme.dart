import 'package:flutter/material.dart';

final customMenuThemeData = MenuThemeData(
  style: MenuStyle().copyWith(
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  ),
);

final lightColorScheme = ColorScheme.fromSeed(seedColor: Colors.blueAccent);
final lightTheme = ThemeData.light().copyWith(
  colorScheme: lightColorScheme,
  menuTheme: customMenuThemeData,
  scaffoldBackgroundColor: lightColorScheme.surface,
);

final darkColorScheme = ColorScheme.fromSeed(seedColor: Colors.blueAccent, brightness: Brightness.dark);
final darkTheme = ThemeData.dark().copyWith(
  colorScheme: darkColorScheme,
  menuTheme: customMenuThemeData,
  scaffoldBackgroundColor: darkColorScheme.surface,
);
