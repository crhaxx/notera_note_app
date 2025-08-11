import 'package:flutter/material.dart';
import 'package:notera_note/models/note.dart';
import 'package:notera_note/services/isar_service.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  final isarService = IsarService();

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
                title: Text(note.title),
                subtitle: Text(note.content),
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
