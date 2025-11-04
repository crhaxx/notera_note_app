import 'package:flutter/material.dart';
import 'package:notera_note/models/note.dart';
import 'package:notera_note/services/isar_service.dart';
import 'package:notera_note/services/notification_service.dart';

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

    Icon leadIcon() {
      if (note.isLocked) {
        return note.isPinned
            ? Icon(Icons.lock, color: Colors.white)
            : Icon(Icons.lock, color: Colors.grey);
      } else {
        return Icon(
          note.isPinned ? Icons.text_fields : Icons.text_fields_outlined,
          color: note.isPinned
              ? Color(note.colorValue)
              : Color(note.colorValue).withAlpha(180),
        );
      }
    }

    Future<void> _deleteNote(Note note) async {
      await isarService.moveToDeleted(note.id, true);
    }

    if (isGrid) {
      return Card(
        elevation: note.isPinned ? 4 : 1,
        color: note.isPinned
            ? Theme.of(context).highlightColor
            : Theme.of(context).cardColor,
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
                          await NotificationService.cancelNotification(note.id);
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
        color: note.isPinned
            ? Theme.of(context).highlightColor
            : Theme.of(context).cardColor,
        child: ListTile(
          title: Text(
            note.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: note.isPinned ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            note.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: note.isLocked ? Colors.grey : Colors.white),
          ),
          onTap: onTap,
          onLongPress: onLongPress,
          leading: leadIcon(),
          trailing: PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              switch (value) {
                case 0: // Pin/Unpin
                  await isarService.togglePin(note);
                  onActionToRefresh();

                  break;

                case 1: // Change Color
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Change Color"),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: [
                                for (var color in Colors.primaries)
                                  GestureDetector(
                                    onTap: () async {
                                      await isarService.updateNoteColor(
                                        note.id,
                                        color.value,
                                      );
                                      Navigator.pop(context);
                                      onActionToRefresh();
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: color,
                                      radius: 20,
                                      child: note.colorValue == color.value
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Close"),
                        ),
                      ],
                    ),
                  );

                  break;

                case 2: // Archive/Unarchive
                  await isarService.archiveNote(note.id, !note.isArchived);
                  onActionToRefresh();

                  break;

                case 3: // Delete
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
                          child: Text("Cancel"),
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
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: Row(
                  children: [
                    Icon(
                      note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(note.isPinned ? 'Unpin' : 'Pin'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.palette, size: 20),
                    const SizedBox(width: 8),
                    Text('Change Color'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(
                      note.isArchived ? Icons.unarchive : Icons.archive,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(note.isArchived ? 'Unarchive' : 'Archive'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 3,
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
