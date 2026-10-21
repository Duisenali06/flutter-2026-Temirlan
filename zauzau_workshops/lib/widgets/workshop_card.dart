import 'package:flutter/material.dart';

import '../models/workshop.dart';
import '../utils/format.dart';

/// R18/R19: the one reusable card.
class WorkshopCard extends StatelessWidget {
  const WorkshopCard({
    super.key,
    required this.workshop,
    required this.onTap,
    required this.onFavourite,
  });

  final Workshop workshop;
  final VoidCallback onTap;
  final VoidCallback onFavourite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = workshop.category.colorIn(scheme);
    final free = workshop.places.free;
    final String? badge = workshop.isFull
        ? 'FULL'
        : (free <= lowPlacesThreshold ? '$free left' : null);

    return Opacity(
      opacity: workshop.isPast ? 0.6 : 1,
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: color.withValues(alpha: 0.15),
                      child: Icon(workshop.category.icon, color: color),
                    ),
                    if (badge != null)
                      Positioned(
                        left: -6,
                        right: -6,
                        bottom: -10,
                        child: Center(
                          child: _Badge(text: badge, full: workshop.isFull),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        workshop.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        formatDateTime(workshop.when),
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        workshop.online ? 'Online' : workshop.place,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onFavourite,
                  color: workshop.favourite ? scheme.error : null,
                  icon: Icon(
                    workshop.favourite ? Icons.favorite : Icons.favorite_border,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.full});

  final String text;
  final bool full;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: full ? scheme.errorContainer : scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        child: Text(
          text,
          style: theme.textTheme.labelSmall?.copyWith(
            color: full ? scheme.onErrorContainer : scheme.onTertiaryContainer,
          ),
        ),
      ),
    );
  }
}
