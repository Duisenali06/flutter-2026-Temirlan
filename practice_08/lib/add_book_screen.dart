import 'package:flutter/material.dart';

import 'models/book.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _pages = TextEditingController();
  final _year = TextEditingController();

  @override
  void dispose() {
    for (final c in [_title, _author, _pages, _year]) {
      c.dispose();
    }
    super.dispose();
  }

  void _unfocus(PointerDownEvent _) =>
      FocusManager.instance.primaryFocus?.unfocus();

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final book = Book(
      title: _title.text.trim(),
      author: _author.text.trim(),
      pages: int.parse(_pages.text.trim()),
      year: int.tryParse(_year.text.trim()),
    );
    Navigator.of(context).pop(book);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Add book')),
    body: Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            TextFormField(
              controller: _title,
              textInputAction: TextInputAction.next,
              onTapOutside: _unfocus,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) =>
                  (v ?? '').trim().length < 2 ? 'At least 2 characters' : null,
            ),
            TextFormField(
              controller: _author,
              textInputAction: TextInputAction.next,
              onTapOutside: _unfocus,
              decoration: const InputDecoration(labelText: 'Author'),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Author is required' : null,
            ),
            TextFormField(
              controller: _pages,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              onTapOutside: _unfocus,
              decoration: const InputDecoration(labelText: 'Pages'),
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                if (n == null || n <= 0) return 'A whole number above 0';
                return null;
              },
            ),
            TextFormField(
              controller: _year,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
              onTapOutside: _unfocus,
              decoration: const InputDecoration(
                labelText: 'Year',
                helperText: 'Optional',
              ),
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty) return null;
                final n = int.tryParse(value);
                if (n == null || n < 1450 || n > DateTime.now().year) {
                  return 'A year between 1450 and ${DateTime.now().year}';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    ),
  );
}
