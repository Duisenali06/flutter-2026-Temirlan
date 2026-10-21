import 'package:flutter/material.dart';

import 'routes.dart';
import 'screens/shell.dart';
import 'theme.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // R11: ThemeMode lives above MaterialApp.
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) => setState(() => _themeMode = mode);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZauZau Workshops',
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: _themeMode,
      routes: {
        Routes.home: (_) => ShellPage(
              themeMode: _themeMode,
              onThemeChanged: _setThemeMode,
            ),
      },
      onGenerateRoute: generateRoute,
      onUnknownRoute: unknownRoute,
    );
  }
}
