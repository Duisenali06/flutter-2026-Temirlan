import 'package:flutter/material.dart';

import '../models/workshop.dart';
import '../widgets/empty_state.dart';
import '../widgets/workshops_view.dart';

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.workshops,
    required this.onOpen,
    required this.onFavourite,
  });

  final List<Workshop> workshops;
  final ValueChanged<Workshop> onOpen;
  final ValueChanged<Workshop> onFavourite;

  @override
  Widget build(BuildContext context) {
    return WorkshopsView(
      workshops: sortUpcomingFirst(workshops.where((i) => i.favourite)),
      onOpen: onOpen,
      onFavourite: onFavourite,
      empty: const EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet',
      ),
    );
  }
}
