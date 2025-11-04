import 'package:flutter/material.dart';
import 'package:notera_note/models/note.dart';
import 'package:notera_note/services/isar_service.dart';
import 'package:notera_note/views/note_detail_page.dart';

class DeletedNotePage extends StatefulWidget {
  final Function(bool) changeTheme;

  const DeletedNotePage({super.key, required this.changeTheme});

  @override
  State<DeletedNotePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<DeletedNotePage> {
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

  Future<void> _deleteNote(Note note) async {
    await isarService.deleteNote(note.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Deleted Notes")),
      body: StreamBuilder<List<Note>>(
        stream: isarService.listenToDeletedNotes(filterDeleted: true),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final notes = snapshot.data!;
          if (notes.isEmpty) {
            return Center(child: Text('No deleted notes found'));
          }
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return ListTile(
                onTap: () => _openNote(note),
                title: Text(note.title),
                subtitle: Text(note.content),

                // trailing: PopupMenuButton<int>(
                //   icon: const Icon(Icons.more_vert),
                //   onSelected: (value) async {
                //     switch (value) {
                //       case 0: // Pin/Unpin
                //         await isarService.togglePin(note);

                //         break;

                //       case 1: // Delete
                //         final shouldDelete = await showDialog<bool>(
                //           context: context,
                //           builder: (context) => AlertDialog(
                //             title: Text("Delete note?"),
                //             content: Text(
                //               "Are you sure you want to delete this note?",
                //             ),
                //             actions: [
                //               TextButton(
                //                 onPressed: () => Navigator.pop(context, false),
                //                 child: Text("Cancel"),
                //               ),
                //               TextButton(
                //                 onPressed: () => Navigator.pop(context, true),
                //                 child: Text(
                //                   "Delete",
                //                   style: TextStyle(color: Colors.red),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         );
                //         if (shouldDelete == true) {
                //           await _deleteNote(note);
                //         }
                //         break;
                //     }
                //   },
                //   itemBuilder: (context) => [
                //     PopupMenuItem(
                //       value: 0,
                //       child: Row(
                //         children: [
                //           Icon(Icons.restore, size: 20),
                //           const SizedBox(width: 8),
                //           Text('Restore'),
                //         ],
                //       ),
                //     ),
                //     // const PopupMenuDivider(),
                //     PopupMenuItem(
                //       value: 3,
                //       child: Row(
                //         children: [
                //           Icon(Icons.delete, size: 20, color: Colors.red),
                //           const SizedBox(width: 8),
                //           Text('Delete', style: TextStyle(color: Colors.red)),
                //         ],
                //       ),
                //     ),
                //   ],
                // ),
              );
            },
          );
        },
      ),
    );
  }
}
