import 'package:flutter/material.dart';
import 'package:notera_note/models/note.dart';
import 'package:notera_note/services/isar_service.dart';

class NoteTile extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onPinToggle;

  const NoteTile({
    super.key,
    required this.note,
    required this.onTap,
    required this.onLongPress,
    required this.onPinToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isarService = IsarService();
    return Card(
      elevation: note.isPinned ? 4 : 1,
      color: Theme.of(context).cardColor,
      child: ListTile(
        title: Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        leading: IconButton(
          onPressed: () async {
            await isarService.togglePin(note);
            onPinToggle();
            if (note.isPinned) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Note pinned'),
                  duration: Duration(seconds: 1),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Note unpinned'),
                  duration: Duration(seconds: 1),
                ),
              );
            }
          },
          icon: Icon(
            note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            size: 20,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            note.isArchived ? Icons.unarchive : Icons.archive,
            color: Colors.grey,
          ),
          onPressed: () async {
            await isarService.archiveNote(note.id, !note.isArchived);
            onPinToggle(); // přenačte seznam po archivaci
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  note.isArchived ? 'Note unarchived' : 'Note archived',
                ),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        subtitle: Text(
          note.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
