import 'package:flutter/material.dart';
import 'package:notera_note/models/note.dart';
import 'package:notera_note/services/isar_service.dart';
import 'package:notera_note/services/search_notes.dart';
import 'package:notera_note/views/note_detail_page.dart';
import 'package:notera_note/widgets/note_tile.dart';
import 'package:notera_note/widgets/theme_toggle.dart';

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
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  void _loadNotes() async {
    setState(() {
      _notesFuture = widget.isarService.getAllNotes();
    });
    final loadedNotes = await _notesFuture;
    setState(() {
      notes = loadedNotes;
    });

    notes = await _noteRepo.searchNotes("");
    _searchController.value = TextEditingValue(
      text: "",
      selection: TextSelection.collapsed(offset: 0),
    );

    enableSearchbar = true;
    setState(() {});
  }

  void _toggleView() {
    setState(() {
      isGrid = !isGrid;
    });
  }

  Future<void> _search(String query) async {
    notes = await _noteRepo.searchNotes(query);
    _notesFuture = Future.value(notes);
    setState(() {});
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
