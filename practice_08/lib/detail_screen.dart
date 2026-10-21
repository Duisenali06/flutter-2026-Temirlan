import 'package:flutter/material.dart';

import 'models/book.dart';

enum BookAction { toggleRead, delete }

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.book});

  final Book book;

  Future<void> _delete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete '${book.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    Navigator.of(context).pop(BookAction.delete);
  }

  @override
  Widget build(BuildContext context) {
    final year = book.year;
    return Scaffold(
      appBar: AppBar(title: Text(book.title, maxLines: 1)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: Text(book.title),
            subtitle: const Text('Title'),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(book.author),
            subtitle: const Text('Author'),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text('${book.pages} pages'),
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: Text(year == null ? 'Year unknown' : '$year'),
          ),
          ListTile(
            leading: Icon(
              book.read ? Icons.check_circle : Icons.circle_outlined,
            ),
            title: Text(book.read ? 'Read' : 'Not read yet'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(BookAction.toggleRead),
            child: Text(book.read ? 'Mark as unread' : 'Mark as read'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _delete(context),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
