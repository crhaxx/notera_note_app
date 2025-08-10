import 'package:flutter/material.dart';
import 'package:notera_note/models/note.dart';
import 'package:notera_note/services/isar_service.dart';

class NoteDetailPage extends StatefulWidget {
  final Note? note;

  const NoteDetailPage({super.key, this.note});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final isarService = IsarService();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late bool isNewNote;
  bool isDark = true;

  @override
  void initState() {
    super.initState();
    isNewNote = widget.note == null;

    if (!isNewNote) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) return;

    final note =
        widget.note ??
        Note(
          title: "Note",
          content: "detail",
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    note.title = title;
    note.content = content;
    note.updatedAt = DateTime.now();

    await isarService.addNote(note);
  }

  Future<void> _deleteNote() async {
    if (widget.note != null) {
      await isarService.deleteNote(widget.note!.id);
    }
  }

  Future<void> _handleBack() async {
    await _saveNote();
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (!didPop) {
          await _handleBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isNewNote ? "New Note" : "Edit Note"),
          leading: IconButton(
            onPressed: _handleBack,
            icon: Icon(Icons.arrow_back),
          ),
          actions: [
            if (!isNewNote)
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
                    await _deleteNote();
                    Navigator.pop(context, true);
                  }
                },
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: "Title",
                  border: InputBorder.none,
                ),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: "Note content...",
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  expands: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
