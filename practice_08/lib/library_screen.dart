import 'package:flutter/material.dart';

import 'add_book_screen.dart';
import 'detail_screen.dart';
import 'models/book.dart';
import 'widgets/book_tile.dart';

enum Filter { all, unread, read }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Book> _books = [...seed];
  Filter _filter = Filter.all;

  List<Book> get _visible => switch (_filter) {
    Filter.all => _books,
    Filter.unread => unread(_books),
    Filter.read => _books.where((b) => b.read).toList(),
  };

  Future<void> _open(Book book) async {
    final action = await Navigator.of(context).push<BookAction>(
      MaterialPageRoute(builder: (_) => DetailScreen(book: book)),
    );
    if (!mounted) return;
    switch (action) {
      case null:
        break;
      case BookAction.toggleRead:
        setState(() => book.read = !book.read);
      case BookAction.delete:
        setState(() => _books.remove(book));
    }
  }

  Future<void> _add() async {
    final book = await Navigator.of(context)
        .push<Book>(MaterialPageRoute(builder: (_) => const AddBookScreen()));
    if (book == null || !mounted) return;
    setState(() => _books.add(book));
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return Scaffold(
      appBar: AppBar(title: Text('Reading list (${visible.length})')),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        tooltip: 'Add book',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _Header(books: _books),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              spacing: 8,
              children: [
                for (final (f, label) in const [
                  (Filter.all, 'All'),
                  (Filter.unread, 'Unread'),
                  (Filter.read, 'Read'),
                ])
                  ChoiceChip(
                    label: Text(label),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
              itemCount: visible.length,
              itemBuilder: (context, i) {
                final book = visible[i];
                return BookTile(
                  book: book,
                  onToggle: () => setState(() => book.read = !book.read),
                  onTap: () => _open(book),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.books});

  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    Widget cell(String value, String label) => Expanded(
      child: Column(
        children: [
          Text(value, style: text.headlineSmall),
          Text(label, style: text.bodySmall),
        ],
      ),
    );
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            cell('${books.length}', 'Books'),
            cell('${totalPages(books)}', 'Pages'),
            cell('${unread(books).length}', 'Unread'),
          ],
        ),
      ),
    );
  }
}
