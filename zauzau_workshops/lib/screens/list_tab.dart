import 'package:flutter/material.dart';

import '../models/workshop.dart';
import '../widgets/empty_state.dart';
import '../widgets/workshops_view.dart';

class ListTab extends StatefulWidget {
  const ListTab({
    super.key,
    required this.workshops,
    required this.onOpen,
    required this.onFavourite,
  });

  final List<Workshop> workshops;
  final ValueChanged<Workshop> onOpen;
  final ValueChanged<Workshop> onFavourite;

  @override
  State<ListTab> createState() => _ListTabState();
}

class _ListTabState extends State<ListTab> {
  final _search = TextEditingController();
  String _query = '';
  WorkshopCategory? _category;
  bool _showPast = true;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _search.clear();
    setState(() => _query = '');
  }

  // R7: where + sort on a copy.
  List<Workshop> get _visible {
    final q = _query.trim().toLowerCase();
    final filtered = widget.workshops.where(
      (i) =>
          (_category == null || i.category == _category) &&
          (_showPast || !i.isPast) &&
          (q.isEmpty || i.title.toLowerCase().contains(q)),
    );
    return sortUpcomingFirst(filtered);
  }

  @override
  Widget build(BuildContext context) {
    // R21: search + chips + Expanded list in one Column.
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            controller: _search,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search workshops',
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _category == null,
                onSelected: (_) => setState(() => _category = null),
              ),
              for (final c in WorkshopCategory.values)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    avatar: Icon(c.icon),
                    label: Text(c.label),
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
                  ),
                ),
              const SizedBox(width: 16),
              FilterChip(
                label: const Text('Past'),
                selected: _showPast,
                onSelected: (v) => setState(() => _showPast = v),
              ),
            ],
          ),
        ),
        Expanded(
          child: WorkshopsView(
            workshops: _visible,
            onOpen: widget.onOpen,
            onFavourite: widget.onFavourite,
            empty: EmptyState(
              icon: Icons.search_off,
              message: 'No workshops match',
              buttonLabel: 'Clear search',
              onPressed: _clearSearch,
            ),
          ),
        ),
      ],
    );
  }
}
