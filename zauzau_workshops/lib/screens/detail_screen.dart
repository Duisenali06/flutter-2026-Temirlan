import 'dart:async';

import 'package:flutter/material.dart';

import '../models/workshop.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';

enum _MenuAction { edit, delete }

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Workshop _workshop;
  Timer? _timer;

  String get _me => widget.args.profileName;

  @override
  void initState() {
    super.initState();
    _workshop = widget.args.workshop;
    // R13: one-minute tick, cancelled in dispose.
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // R15: ask, then act on true; empty name -> SnackBar to the profile tab.
  Future<void> _primary() async {
    if (_me.isEmpty) {
      final navigator = Navigator.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Set your name in the profile first'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: () {
              navigator.pop();
              widget.args.onSwitchTab(Tabs.profile);
            },
          ),
        ),
      );
      return;
    }
    final joined = _workshop.contains(_me);
    final ok = await confirm(
      context,
      title: joined ? 'Cancel your spot?' : 'Sign up?',
      message: joined
          ? 'Remove "$_me" from "${_workshop.title}"?'
          : 'Add "$_me" to "${_workshop.title}"?',
      confirmLabel: joined ? 'Cancel spot' : 'Sign up',
    );
    if (ok != true || !mounted) return;
    final updated = _workshop.copyWith(
      names: joined
          ? _workshop.names.where((n) => n != _me).toList()
          : [..._workshop.names, _me],
    );
    setState(() => _workshop = updated);
    widget.args.onChanged(updated);
  }

  Future<void> _edit() async {
    final edited = await Navigator.pushNamed<Workshop>(
      context,
      Routes.form,
      arguments: FormArgs(workshop: _workshop),
    );
    if (edited == null || !mounted) return;
    setState(() => _workshop = edited);
    widget.args.onChanged(edited);
  }

  Future<void> _delete() async {
    final ok = await confirm(
      context,
      title: 'Delete workshop?',
      message: '"${_workshop.title}" will be removed.',
      confirmLabel: 'Delete',
    );
    if (ok != true || !mounted) return;
    widget.args.onDelete(_workshop);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final joined = _workshop.contains(_me);
    // R16: null when it cannot act.
    final canAct = joined || (!_workshop.isFull && !_workshop.isPast);
    final label = joined ? 'Cancel spot' : (_workshop.isFull ? 'Full' : 'Sign up');

    // R31: no back arrow written anywhere; AppBar supplies it.
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_workshop.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: [
            PopupMenuButton<_MenuAction>(
              onSelected: (a) => switch (a) {
                _MenuAction.edit => _edit(),
                _MenuAction.delete => _delete(),
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: _MenuAction.edit, child: Text('Edit')),
                PopupMenuItem(value: _MenuAction.delete, child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _Header(workshop: _workshop),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Names (${_workshop.count})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _AboutTab(workshop: _workshop),
                  _NamesTab(workshop: _workshop, me: _me),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: canAct ? _primary : null,
                    icon: Icon(joined ? Icons.logout : Icons.how_to_reg),
                    label: Text(label),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// R24: asset image + icon + category (one corner) + countdown (other corner).
class _Header extends StatelessWidget {
  const _Header({required this.workshop});

  final Workshop workshop;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 180,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/header.png', fit: BoxFit.cover),
          ColoredBox(color: scheme.scrim.withValues(alpha: 0.35)),
          Center(child: Icon(workshop.category.icon, size: 72, color: scheme.surface)),
          Positioned(
            top: 12,
            left: 12,
            child: Chip(label: Text(workshop.category.label)),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Chip(
              avatar: const Icon(Icons.timer_outlined),
              label: Text(formatCountdown(workshop.countdown)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.workshop});

  final Workshop workshop;

  @override
  Widget build(BuildContext context) {
    final (:taken, :free) = workshop.places;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.event),
          title: Text(formatDateTime(workshop.when)),
        ),
        ListTile(
          leading: Icon(workshop.online ? Icons.link : Icons.place),
          title: Text(workshop.place),
        ),
        ListTile(
          leading: const Icon(Icons.group),
          title: Text('$taken of ${workshop.limit} taken · $free free'),
        ),
        // R6: collection if with a pattern, no `!`.
        if (workshop.description case final text?)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(text),
          ),
      ],
    );
  }
}

class _NamesTab extends StatelessWidget {
  const _NamesTab({required this.workshop, required this.me});

  final Workshop workshop;
  final String me;

  @override
  Widget build(BuildContext context) {
    if (workshop.count == 0) {
      return const EmptyState(
        icon: Icons.group_off,
        message: 'Nobody has joined yet',
      );
    }
    final scheme = Theme.of(context).colorScheme;
    final names = workshop.names;
    return ListView.builder(
      itemCount: names.length,
      itemBuilder: (_, i) {
        final name = names[i];
        final isMe = name == me;
        return ListTile(
          selected: isMe,
          tileColor: isMe ? scheme.primaryContainer : null,
          leading: Icon(isMe ? Icons.person : Icons.person_outline),
          title: Text(
            isMe ? '$name (You)' : name,
            style: isMe ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
        );
      },
    );
  }
}
