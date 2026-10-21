import 'package:flutter/material.dart';

// R22: the app has no colour literals. The seed is taken from Material's own
// default primary, so every colour in lib/ comes from the colorScheme.
final Color _seed = ThemeData().colorScheme.primary;

ThemeData buildTheme(Brightness brightness) => ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: brightness,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
