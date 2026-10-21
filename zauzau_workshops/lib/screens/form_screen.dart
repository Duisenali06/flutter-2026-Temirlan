import 'package:flutter/material.dart';

import '../models/workshop.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/confirm_dialog.dart';

typedef _Snapshot = ({
  String title,
  String place,
  String limit,
  DateTime when,
  WorkshopCategory category,
  bool online,
  String description,
});

class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.args});

  final FormArgs args;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  // R35: controllers and focus nodes are State fields, created once, disposed.
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _place = TextEditingController();
  final _limit = TextEditingController();
  final _date = TextEditingController();
  final _time = TextEditingController();
  final _description = TextEditingController();
  final _titleFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _limitFocus = FocusNode();
  final _descriptionFocus = FocusNode();

  late final Workshop _base = widget.args.workshop ?? Workshop.empty();
  late WorkshopCategory _category;
  late bool _online;
  late DateTime _when;
  late final _Snapshot _initial;
  bool _dirty = false;
  bool _saving = false;

  bool get _isNew => widget.args.workshop == null;

  @override
  void initState() {
    super.initState();
    _title.text = _base.title;
    _place.text = _base.place;
    _limit.text = _base.limit.toString();
    _description.text = _base.description ?? '';
    _category = _base.category;
    _online = _base.online;
    _when = _base.when;
    _syncPickers();
    _initial = _snapshot();
  }

  @override
  void dispose() {
    for (final c in [_title, _place, _limit, _date, _time, _description]) {
      c.dispose();
    }
    for (final f in [_titleFocus, _placeFocus, _limitFocus, _descriptionFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  void _syncPickers() {
    _date.text = formatDateYear(_when);
    _time.text = formatClock(_when.hour, _when.minute);
  }

  _Snapshot _snapshot() => (
        title: _title.text.trim(),
        place: _place.text.trim(),
        limit: _limit.text.trim(),
        when: _when,
        category: _category,
        online: _online,
        description: _description.text.trim(),
      );

  // R30: dirty = current values differ from the ones the form opened with.
  void _onChanged() => setState(() => _dirty = _snapshot() != _initial);

  // R12: setState wraps only the change.
  void _apply(VoidCallback change) {
    setState(() {
      change();
      _syncPickers();
      _dirty = _snapshot() != _initial;
    });
  }

  // ---- validators (R33/R34) ----
  String? _validateTitle(String? v) {
    final t = (v ?? '').trim();
    return t.length < 3 || t.length > 60 ? 'Title must be 3–60 characters' : null;
  }

  String? _validatePlace(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return _online ? 'Link is required' : 'Place is required';
    if (_online && !t.contains('://')) return 'A link must contain ://';
    return null;
  }

  String? _validateLimit(String? v) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null || n < 1 || n > 500) return 'Enter a whole number 1–500';
    if (!_isNew && n < _base.count) {
      return 'Not below the current count (${_base.count})';
    }
    return null;
  }

  String? _validateDate(String? v) =>
      (v ?? '').isEmpty ? 'Pick a date' : null;

  String? _validateTime(String? v) {
    if ((v ?? '').isEmpty) return 'Pick a time';
    if (_isNew && !_when.isAfter(DateTime.now())) return 'Must be in the future';
    return null;
  }

  String? _validateDescription(String? v) =>
      (v ?? '').length > 300 ? 'At most 300 characters' : null;

  // ---- pickers (R36): Cancel keeps the old value ----
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    _apply(() {
      _when = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _when.hour,
        _when.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_when),
    );
    if (picked == null || !mounted) return;
    _apply(() {
      _when = DateTime(
        _when.year,
        _when.month,
        _when.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Workshop _buildWorkshop() {
    final text = _description.text.trim();
    return _base.copyWith(
      id: _isNew ? DateTime.now().microsecondsSinceEpoch.toString() : _base.id,
      title: _title.text.trim(),
      category: _category,
      when: _when,
      limit: int.parse(_limit.text.trim()),
      place: _place.text.trim(),
      online: _online,
      description: text,
      clearDescription: text.isEmpty,
    );
  }

  // R17: one-second fake save; a second tap cannot start a second save.
  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.of(context).pop(_buildWorkshop()); // Save never asks to discard.
  }

  void _dismissKeyboard(PointerDownEvent _) =>
      FocusManager.instance.primaryFocus?.unfocus();

  @override
  Widget build(BuildContext context) {
    // R30: a clean form pops freely; a dirty one asks first.
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final discard = await confirm(
          context,
          title: 'Discard changes?',
          message: 'Your edits will be lost.',
          confirmLabel: 'Discard',
        );
        if (discard == true && mounted) navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isNew ? 'New workshop' : 'Edit workshop')),
        // R37: scrolls, no Spacer, Save is the last child.
        body: Form(
          key: _formKey,
          onChanged: _onChanged,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _title,
                  focusNode: _titleFocus,
                  maxLength: 60,
                  decoration: const InputDecoration(labelText: 'Title'),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  validator: _validateTitle,
                  onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                  onTapOutside: _dismissKeyboard,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<WorkshopCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    for (final c in WorkshopCategory.values)
                      DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(c.icon),
                            const SizedBox(width: 12),
                            Text(c.label),
                          ],
                        ),
                      ),
                  ],
                  validator: (v) => v == null ? 'Pick a category' : null,
                  onChanged: (v) {
                    if (v != null) _apply(() => _category = v);
                  },
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Online workshop'),
                  subtitle: const Text('The place becomes a link'),
                  value: _online,
                  onChanged: (v) => _apply(() => _online = v ?? false),
                ),
                TextFormField(
                  controller: _place,
                  focusNode: _placeFocus,
                  decoration: InputDecoration(
                    labelText: _online ? 'Link' : 'Place',
                    hintText: _online ? 'https://…' : null,
                  ),
                  keyboardType: _online ? TextInputType.url : TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: _validatePlace,
                  onFieldSubmitted: (_) => _limitFocus.requestFocus(),
                  onTapOutside: _dismissKeyboard,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _date,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: _validateDate,
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _time,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          suffixIcon: Icon(Icons.schedule),
                        ),
                        validator: _validateTime,
                        onTap: _pickTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _limit,
                  focusNode: _limitFocus,
                  decoration: const InputDecoration(labelText: 'Capacity'),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: _validateLimit,
                  onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
                  onTapOutside: _dismissKeyboard,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _description,
                  focusNode: _descriptionFocus,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  validator: _validateDescription,
                  onTapOutside: _dismissKeyboard,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
