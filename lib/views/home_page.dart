import 'package:flutter/material.dart';
import 'package:notera_note/models/note.dart';
import 'package:notera_note/services/isar_service.dart';
import 'package:notera_note/services/search_notes.dart';
import 'package:notera_note/views/note_detail_page.dart';
import 'package:notera_note/widgets/note_tile.dart';
import 'package:notera_note/widgets/theme_toggle.dart';

abstract class HomePageStateInterface {
  void refreshNotes();
}

class HomePage extends StatefulWidget {
  final bool isDark;
  final IsarService isarService;
  final Function(bool) changeTheme;

  const HomePage({
    super.key,
    required this.isDark,
    required this.isarService,
    required this.changeTheme,
  });

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> implements HomePageStateInterface {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Note>> _notesFuture = Future.value([]);
  final isarService = IsarService();
  bool isGrid = false;
  List<Note> notes = [];
  late NoteRepository _noteRepo;
  bool enableSearchbar = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final isar = await widget.isarService.db;
    _noteRepo = NoteRepository(isar);
    _loadNotes();
    _searchController.addListener(() {
      _search(_searchController.text);
    });
  }

  @override
  void refreshNotes() {
    _loadNotes();
  }

  void _loadNotes({String query = ""}) async {
    // First get all notes with proper sorting from Isar
    final loadedNotes = await widget.isarService.getAllNotes();

    // Apply search filter if needed
    if (query.isNotEmpty) {
      final searchedNotes = await _noteRepo.searchNotes(query);
      // Combine search results with the original sorting
      final searchedIds = searchedNotes.map((n) => n.id).toSet();
      notes = loadedNotes
          .where((note) => searchedIds.contains(note.id))
          .toList();
    } else {
      notes = loadedNotes;
    }

    setState(() {
      _notesFuture = Future.value(notes);
      enableSearchbar = true;
    });

    print("Loaded ${notes.length} notes");
    print(
      notes
          .map((note) => "${note.isPinned ? '[PINNED] ' : ''}${note.title}")
          .toList(),
    );
  }

  void _toggleView() {
    setState(() {
      isGrid = !isGrid;
    });
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      _loadNotes();
      return;
    }

    final searchedNotes = await _noteRepo.searchNotes(query);
    final loadedNotes = await widget.isarService.getAllNotes();

    // Filter both by search and archived status while maintaining sort order
    final searchedIds = searchedNotes.map((n) => n.id).toSet();
    notes = loadedNotes.where((note) => searchedIds.contains(note.id)).toList();

    setState(() {
      _notesFuture = Future.value(notes);
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search notes...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: _toggleView,
          ),
          ThemeToggle(isDark: widget.isDark, changeTheme: widget.changeTheme),
        ],
      ),
      body: FutureBuilder<List<Note>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          final notes = snapshot.data ?? [];
          if (notes.isEmpty) {
            return const Center(child: Text("No notes"));
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
                        onPinToggle: _loadNotes,
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
                        onPinToggle: _loadNotes,
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
