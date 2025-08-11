import 'package:flutter/material.dart';
import 'package:notera_note/models/note.dart';
import 'package:notera_note/services/isar_service.dart';
import 'package:share_plus/share_plus.dart';

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
  Color selectedColor = Colors.black;

  @override
  void initState() {
    super.initState();
    isNewNote = widget.note == null;

    if (!isNewNote) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }

    if (widget.note != null) {
      selectedColor = Color(widget.note!.colorValue);
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
    note.colorValue = selectedColor.value;
    note.updatedAt = DateTime.now();

    await isarService.addNote(note);
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
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                final title = _titleController.text.trim();
                final content = _contentController.text.trim();

                if (title.isEmpty && content.isEmpty) return;

                final textToShare = title.isNotEmpty
                    ? '$title\n\n$content'
                    : content;

                Share.share(textToShare);
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
                decoration: InputDecoration(
                  hintText: "Title",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: selectedColor, width: 1.0),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: selectedColor, width: 2.0),
                  ),
                  // Volitelně: stejná barva i pro další stavy
                  disabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: selectedColor),
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: selectedColor),
                  ),
                  focusedErrorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: selectedColor),
                  ),
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

              // Row(
              //   children: [
              //     for (final color in [
              //       Colors.red,
              //       Colors.green,
              //       Colors.blue,
              //       Colors.orange,
              //       Colors.purple,
              //     ])
              //       GestureDetector(
              //         onTap: () async {
              //           setState(() {
              //             selectedColor = color;
              //           });

              //           if (!isNewNote && widget.note != null) {
              //             await isarService.updateNoteColor(
              //               widget.note!.id,
              //               color.value,
              //             );
              //           }
              //         },
              //         child: Container(
              //           margin: const EdgeInsets.symmetric(horizontal: 4),
              //           width: 28,
              //           height: 28,
              //           decoration: BoxDecoration(
              //             color: color,
              //             shape: BoxShape.circle,
              //             border: Border.all(
              //               color: selectedColor == color
              //                   ? Colors.black
              //                   : Colors.transparent,
              //               width: 2,
              //             ),
              //           ),
              //         ),
              //       ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
