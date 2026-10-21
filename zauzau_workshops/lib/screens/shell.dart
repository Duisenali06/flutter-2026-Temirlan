import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/workshop.dart';
import '../models/profile.dart';
import '../routes.dart';
import '../widgets/confirm_dialog.dart';
import 'favourites_tab.dart';
import 'list_tab.dart';
import 'profile_tab.dart';


class ShellPage extends StatefulWidget {
  const ShellPage({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  static const _titles = ['ZauZau Workshops', 'Favourites', 'Profile'];

  late List<Workshop> _workshops;
  Profile _profile = const Profile.empty();
  int _tab = Tabs.list;

  @override
  void initState() {
    super.initState();
    _workshops = seedWorkshops();
  }


  void _goToTab(int index) => setState(() => _tab = index);

  void _toggleFavourite(Workshop workshop) {
    final updated = workshop.copyWith(favourite: !workshop.favourite);
    setState(() => _workshops = _replace(updated));
  }

  void _upsert(Workshop workshop) => setState(() => _workshops = _replace(workshop));

  void _delete(Workshop workshop) {
    setState(() => _workshops = _workshops.where((i) => i.id != workshop.id).toList());
  }

  void _setProfile(Profile profile) => setState(() => _profile = profile);

  List<Workshop> _replace(Workshop updated) => [
        for (final i in _workshops) i.id == updated.id ? updated : i,
      ];

  void _openDetail(Workshop workshop) {
    Navigator.pushNamed(
      context,
      Routes.detail,
      arguments: DetailArgs(
        workshop: workshop,
        profileName: _profile.name,
        onChanged: _upsert,
        onDelete: _delete,
        onSwitchTab: _goToTab,
      ),
    );
  }

  Future<void> _addWorkshop() async {
    final created = await Navigator.pushNamed<Workshop>(
      context,
      Routes.form,
      arguments: const FormArgs(),
    );
    if (created == null || !mounted) return;
    setState(() => _workshops = [..._workshops, created]);
  }


  void _showAbout() {
    Navigator.pop(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('About'),
        content: const Text('ZauZau Workshops — baking workshops at the Zau Zau confectionery, Almaty.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetData() async {
    Navigator.pop(context);
    final ok = await confirm(
      context,
      title: 'Reset data?',
      message: 'Workshops return to the seed list and the profile is cleared.',
      confirmLabel: 'Reset',
    );
    if (ok != true || !mounted) return;
    setState(() {
      _workshops = seedWorkshops();
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_tab])),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'ZauZau Workshops',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: _showAbout,
            ),
            ListTile(
              leading: const Icon(Icons.restart_alt),
              title: const Text('Reset data'),
              onTap: _resetData,
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          ListTab(
            workshops: _workshops,
            onOpen: _openDetail,
            onFavourite: _toggleFavourite,
          ),
          FavouritesTab(
            workshops: _workshops,
            onOpen: _openDetail,
            onFavourite: _toggleFavourite,
          ),
          ProfileTab(
            profile: _profile,
            workshops: _workshops,
            themeMode: widget.themeMode,
            onProfileChanged: _setProfile,
            onThemeChanged: widget.onThemeChanged,
          ),
        ],
      ),
      floatingActionButton: _tab == Tabs.list
          ? FloatingActionButton(
              onPressed: _addWorkshop,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _goToTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event), label: 'Workshops'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Favourites'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
