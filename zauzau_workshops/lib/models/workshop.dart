import 'dart:collection';

import 'package:flutter/material.dart';

/// "N left" badge is shown when this many places or fewer remain.
const lowPlacesThreshold = 5;

enum WorkshopCategory {
  cakes('Cakes', Icons.cake),
  bread('Bread', Icons.bakery_dining),
  desserts('Desserts', Icons.icecream),
  cookies('Cookies', Icons.cookie),
  drinks('Drinks', Icons.local_cafe);

  const WorkshopCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  Color colorIn(ColorScheme scheme) => switch (this) {
        WorkshopCategory.cakes => scheme.primary,
        WorkshopCategory.bread => scheme.secondary,
        WorkshopCategory.desserts => scheme.tertiary,
        WorkshopCategory.cookies => scheme.error,
        WorkshopCategory.drinks => scheme.outline,
      };
}

/// R9: sealed countdown.
sealed class Countdown {
  const Countdown();
}

final class Upcoming extends Countdown {
  const Upcoming(this.left);
  final Duration left;
}

final class Started extends Countdown {
  const Started(this.ago);
  final Duration ago;
}

final class Ended extends Countdown {
  const Ended();
}

@immutable
class Workshop {
  const Workshop({
    required this.id,
    required this.title,
    required this.category,
    required this.when,
    required this.limit,
    required this.place,
    this.online = false,
    this.description,
    this.favourite = false,
    List<String> names = const [],
  }) : _names = names;

  /// R3: defaults for a new workshop.
  Workshop.empty()
      : this(
          id: '',
          title: '',
          category: WorkshopCategory.cakes,
          when: _tomorrowMorning(),
          limit: 30,
          place: '',
        );

  static DateTime _tomorrowMorning() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1, 10);
  }

  final String id;
  final String title;
  final WorkshopCategory category;
  final DateTime when;
  final int limit;
  final String place; // a link when [online] is true
  final bool online;
  final String? description;
  final bool favourite;
  final List<String> _names;

  /// R1: nobody can mutate the list from outside.
  List<String> get names => UnmodifiableListView(_names);

  // R4: derived values are getters.
  int get count => _names.length;
  int get freePlaces => limit - count;
  bool get isFull => count >= limit;
  bool get isPast => when.isBefore(DateTime.now());
  bool contains(String name) => _names.contains(name);

  // R5: record getter.
  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  Countdown get countdown {
    final diff = when.difference(DateTime.now());
    if (diff > Duration.zero) return Upcoming(diff);
    return diff > const Duration(hours: -3) ? Started(-diff) : const Ended();
  }

  Workshop copyWith({
    String? id,
    String? title,
    WorkshopCategory? category,
    DateTime? when,
    int? limit,
    String? place,
    bool? online,
    String? description,
    bool clearDescription = false,
    bool? favourite,
    List<String>? names,
  }) =>
      Workshop(
        id: id ?? this.id,
        title: title ?? this.title,
        category: category ?? this.category,
        when: when ?? this.when,
        limit: limit ?? this.limit,
        place: place ?? this.place,
        online: online ?? this.online,
        description:
            clearDescription ? null : (description ?? this.description),
        favourite: favourite ?? this.favourite,
        names: List.unmodifiable(names ?? _names),
      );
}

/// R7: sorting copies; upcoming first by date, past workshops last.
List<Workshop> sortUpcomingFirst(Iterable<Workshop> workshops) => [...workshops]
  ..sort((a, b) {
    if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
    return a.when.compareTo(b.when);
  });
