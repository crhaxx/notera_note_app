import 'package:flutter/material.dart';
import 'package:notera_note/models/note.dart';
import 'package:notera_note/services/isar_service.dart';

class NoteTile extends StatelessWidget {
  final Note note;
  final bool isGrid;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onActionToRefresh;

  const NoteTile({
    super.key,
    required this.note,
    required this.isGrid,
    required this.onTap,
    required this.onLongPress,
    required this.onActionToRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isarService = IsarService();

    Future<void> _deleteNote(Note note) async {
      await isarService.deleteNote(note.id);
    }

    if (isGrid) {
      return Card(
        elevation: note.isPinned ? 4 : 1,
        color: Theme.of(context).cardColor,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    note.content,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 20,
                      icon: Icon(
                        note.isPinned
                            ? Icons.push_pin
                            : Icons.push_pin_outlined,
                      ),
                      onPressed: () async {
                        await isarService.togglePin(note);
                        onActionToRefresh();
                      },
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        note.isArchived ? Icons.unarchive : Icons.archive,
                        color: Colors.grey,
                      ),
                      onPressed: () async {
                        await isarService.archiveNote(
                          note.id,
                          !note.isArchived,
                        );
                        onActionToRefresh();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Delete note?"),
                            content: Text(
                              "Are you sure you want to delete this note?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (shouldDelete == true) {
                          await _deleteNote(note);
                          onActionToRefresh();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Card(
        elevation: note.isPinned ? 4 : 1,
        color: Theme.of(context).cardColor,
        child: ListTile(
          title: Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          leading: IconButton(
            onPressed: () async {
              await isarService.togglePin(note);
              onActionToRefresh();
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
              onActionToRefresh(); // přenačte seznam po archivaci
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
}
