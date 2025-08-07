import 'package:flutter/material.dart';
import 'package:notera_note/models/note.dart';
import 'package:notera_note/services/isar_service.dart';
import 'package:notera_note/views/note_detail_page.dart';
import 'package:notera_note/widgets/note_tile.dart';
import 'package:notera_note/widgets/theme_toggle.dart';

class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDark;
  final IsarService isarService;

  const HomePage({
    super.key,
    required this.toggleTheme,
    required this.isDark,
    required this.isarService,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Note>> _notesFuture;
  final isarService = IsarService();
  bool isGrid = false;
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    _notesFuture = widget.isarService.getAllNotes();
    final loadedNotes = await _notesFuture;
    setState(() {
      notes = loadedNotes;
    });
  }

  void _toggleView() {
    setState(() {
      isGrid = !isGrid;
    });
  }

  void _openNote(Note? note) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteDetailPage(note: note)),
    ).then((value) {
      if (value == true) {
        _loadNotes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notera'),
        actions: [
          IconButton(
            icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: _toggleView,
          ),
          ThemeToggle(isDark: widget.isDark, toggleTheme: widget.toggleTheme),
        ],
      ),
      body: FutureBuilder<List<Note>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          final notes = snapshot.data ?? [];

          if (notes.isEmpty) {
            return const Center(child: Text("Žádné poznámky"));
          }

          return GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity!.abs() > 300) {
                _toggleView();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: isGrid
                  ? GridView.builder(
                      itemCount: notes.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 4 / 3,
                          ),
                      itemBuilder: (_, i) => NoteTile(
                        note: notes[i],
                        onTap: () => _openNote(notes[i]),
                        onLongPress: () async {
                          notes[i].isPinned = !notes[i].isPinned;
                          notes[i].updatedAt = DateTime.now();
                          await isarService.addNote(notes[i]);
                        },
                      ),
                    )
                  : ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (_, i) => NoteTile(
                        note: notes[i],
                        onTap: () => _openNote(notes[i]),
                        onLongPress: () async {
                          notes[i].isPinned = !notes[i].isPinned;
                          notes[i].updatedAt = DateTime.now();
                          await isarService.addNote(notes[i]);
                        },
                      ),
                    ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNote(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
