import 'package:flutter/material.dart';

import '../models/workshop.dart';
import '../models/profile.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.workshops,
    required this.themeMode,
    required this.onProfileChanged,
    required this.onThemeChanged,
  });

  final Profile profile;
  final List<Workshop> workshops;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onProfileChanged;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  static final _groupPattern = RegExp(r'^[A-Za-z]{2,5}-\d{2,4}$');

  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile.name);
  late final _group = TextEditingController(text: widget.profile.group);
  final _groupFocus = FocusNode();

  @override
  void didUpdateWidget(ProfileTab old) {
    super.didUpdateWidget(old);
    // The shell can change the profile (Reset data): keep fields in sync.
    if (old.profile != widget.profile) {
      _name.text = widget.profile.name;
      _group.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    _groupFocus.dispose();
    super.dispose();
  }

  String? _validateName(String? v) =>
      (v ?? '').trim().length > 40 ? 'At most 40 characters' : null;

  String? _validateGroup(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty || _groupPattern.hasMatch(t)) return null;
    return 'Use a format like IS-2301';
  }

  // Saves on submit of either field.
  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onProfileChanged(
      Profile(
        name: _name.text.trim(),
        group: _group.text.trim().toUpperCase(),
      ),
    );
  }

  String _modeLabel(ThemeMode m) => switch (m) {
        ThemeMode.system => 'System',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = widget.profile.name;
    // Computed from the list on every build.
    final lists = name.isEmpty
        ? 0
        : widget.workshops.where((i) => i.contains(name)).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'You are on $lists list${lists == 1 ? '' : 's'}',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.name,
                validator: _validateName,
                onFieldSubmitted: (_) => _groupFocus.requestFocus(),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _group,
                focusNode: _groupFocus,
                decoration: const InputDecoration(
                  labelText: 'Group',
                  hintText: 'IS-2301',
                ),
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                validator: _validateGroup,
                onFieldSubmitted: (_) => _submit(),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Theme', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final m in ThemeMode.values)
              ChoiceChip(
                label: Text(_modeLabel(m)),
                selected: widget.themeMode == m,
                onSelected: (_) => widget.onThemeChanged(m),
              ),
          ],
        ),
      ],
    );
  }
}
