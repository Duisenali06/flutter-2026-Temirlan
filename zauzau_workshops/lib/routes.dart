import 'package:flutter/material.dart';

import 'models/workshop.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';

/// R25: route names live here and nowhere else.
abstract final class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const form = '/form';
}

abstract final class Tabs {
  static const list = 0;
  static const favourites = 1;
  static const profile = 2;
}

class DetailArgs {
  const DetailArgs({
    required this.workshop,
    required this.profileName,
    required this.onChanged,
    required this.onDelete,
    required this.onSwitchTab,
  });

  final Workshop workshop;
  final String profileName;
  final ValueChanged<Workshop> onChanged;
  final ValueChanged<Workshop> onDelete;
  final ValueChanged<int> onSwitchTab;
}

class FormArgs {
  const FormArgs({this.workshop});

  /// null -> new workshop; otherwise edit.
  final Workshop? workshop;
}

Route<dynamic>? generateRoute(RouteSettings settings) {
  return switch ((settings.name, settings.arguments)) {
    (Routes.detail, final DetailArgs args) => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => DetailScreen(args: args),
      ),
    (Routes.form, final FormArgs args) => MaterialPageRoute<Workshop>(
        settings: settings,
        builder: (_) => FormScreen(args: args),
      ),
    _ => null,
  };
}

Route<dynamic> unknownRoute(RouteSettings settings) => MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: const Center(child: Text('Not found')),
      ),
    );
