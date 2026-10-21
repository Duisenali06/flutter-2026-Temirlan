import 'package:flutter/material.dart';

import '../models/workshop.dart';
import 'workshop_card.dart';

/// R20: list on phones, grid from 600 px, decided by LayoutBuilder.
class WorkshopsView extends StatelessWidget {
  const WorkshopsView({
    super.key,
    required this.workshops,
    required this.onOpen,
    required this.onFavourite,
    required this.empty,
  });

  final List<Workshop> workshops;
  final ValueChanged<Workshop> onOpen;
  final ValueChanged<Workshop> onFavourite;
  final Widget empty;

  static const double gridBreakpoint = 600;
  static const double maxCellWidth = 360;
  static const _padding = EdgeInsets.fromLTRB(16, 8, 16, 88);

  @override
  Widget build(BuildContext context) {
    if (workshops.isEmpty) return empty;

    return LayoutBuilder(
      builder: (context, constraints) {
        Widget cardAt(int i) {
          final workshop = workshops[i];
          return WorkshopCard(
            workshop: workshop,
            onTap: () => onOpen(workshop),
            onFavourite: () => onFavourite(workshop),
          );
        }

        if (constraints.maxWidth >= gridBreakpoint) {
          return GridView.builder(
            padding: _padding,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: maxCellWidth,
              mainAxisExtent: 132,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: workshops.length,
            itemBuilder: (_, i) => cardAt(i),
          );
        }
        return ListView.separated(
          padding: _padding,
          itemCount: workshops.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, i) => cardAt(i),
        );
      },
    );
  }
}
