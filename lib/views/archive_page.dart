import 'package:flutter/material.dart';
import 'package:notera_note/models/note.dart';
import 'package:notera_note/services/isar_service.dart';
import 'package:notera_note/views/note_detail_page.dart';

class ArchivePage extends StatefulWidget {
  final Function(bool) changeTheme;

  const ArchivePage({super.key, required this.changeTheme});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  final isarService = IsarService();

  void _openNote(Note? note) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NoteDetailPage(note: note, changeTheme: widget.changeTheme),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Archive")),
      body: StreamBuilder<List<Note>>(
        stream: isarService.listenToNotes(filterArchived: true),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final notes = snapshot.data!;
          if (notes.isEmpty) {
            return Center(child: Text('No archived notes found'));
          }
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return ListTile(
                onTap: () => _openNote(note),
                title: Text(
                  note.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  note.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: Icon(Icons.unarchive),
                  onPressed: () {
                    isarService.archiveNote(note.id, false);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
