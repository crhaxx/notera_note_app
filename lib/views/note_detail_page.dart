import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:notera_note/models/note.dart';
import 'package:notera_note/services/encryption_service.dart';
import 'package:notera_note/services/isar_service.dart';
import 'package:notera_note/services/notification_service.dart';
import 'package:notera_note/services/widget_service.dart';
import 'package:notera_note/widgets/rich_input_field.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notera_note/utils/app_globals.dart';
import 'package:flutter/services.dart';

class NoteDetailPage extends StatefulWidget {
  final Note? note;
  final Function(bool) changeTheme;

  const NoteDetailPage({super.key, this.note, required this.changeTheme});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final isarService = IsarService();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final auth = LocalAuthentication();

  late bool isNewNote;
  bool isDark = true;
  Color selectedColor = Colors.black;
  DateTime? reminderDate;

  @override
  void initState() {
    super.initState();
    isNewNote = widget.note == null;

    if (!isNewNote) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.isLocked
          ? "🔒 Locked note"
          : widget.note!.content;
      selectedColor = Color(widget.note!.colorValue);
    } else {
      _loadDefaultColor();
    }

    // if (widget.note != null) {
    //   selectedColor = Color(widget.note!.colorValue);
    // }
  }

  Future<void> _loadDefaultColor() async {
    final prefs = await SharedPreferences.getInstance();
    int? colorValue = prefs.getInt('defaultNoteColor');
    if (colorValue != null) {
      setState(() {
        selectedColor = Color(colorValue);
      });
    }
  }

  Future<void> _pickReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    if (notificationsEnabled == false) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Notifications Disabled"),
            content: Text(
              "Please enable notifications in settings to use reminders.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleBack();
                  bottomNavGlobalKey.currentState?.changeTab(2);
                },
                child: Text("Open Settings"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      reminderDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });

    _saveNote();
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

    if (!widget.note!.isLocked) {
      note.content = content;
    }

    note.colorValue = selectedColor.value;
    note.updatedAt = DateTime.now();

    if (reminderDate != null) {
      await NotificationService.scheduleNotification(
        id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch,
        title: note.title.isEmpty ? "Note Reminder" : note.title,
        body: note.content,
        scheduledDate: reminderDate!,
      );
    }

    await isarService.addNote(note);

    // po uložení aktualizovat widget
    await WidgetService.updateLastNoteForWidget(
      title: note.title,
      content: note.content,
      noteId: note.id.toString(),
    );

    print(content + note.content);
  }

  Future<void> _handleBack() async {
    await _saveNote();
    Navigator.pop(context, true);
  }

  Future<void> _toggleLock() async {
    if (widget.note == null) return;

    if (widget.note!.isLocked) {
      // odemykání
      final didAuth = await auth.authenticate(
        localizedReason: 'Verify yourself to unlock the note',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (didAuth) {
        await isarService.lockNote(widget.note!, false);
        final decrypted = await EncryptionService.decrypt(widget.note!.content);
        setState(() {
          _contentController.text = decrypted;
        });
      }
    } else {
      // zamykání
      await isarService.lockNote(widget.note!, true);
      setState(() {
        _contentController.text = "🔒 Locked note";
      });
    }
    setState(() {});
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
              icon: widget.note != null || widget.note?.isLocked == false
                  ? Icon(Icons.share)
                  : SizedBox(),
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

            if (!isNewNote)
              IconButton(
                icon: Icon(
                  widget.note?.isLocked == true ? Icons.lock : Icons.lock_open,
                ),
                onPressed: _toggleLock,
              ),
          ],
        ),
        body: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! < 0) {
              // Swipe left
              _handleBack();
            } else if (details.primaryVelocity! > 0) {
              // Swipe right
              _handleBack();
            }
          },
          child: Padding(
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
                  child: widget.note!.isLocked
                      ? TextField(
                          enabled: false,
                          decoration: const InputDecoration(
                            hintText: "🔒 Locked note",
                            border: InputBorder.none,
                          ),
                        )
                      : RichInputField(controller: _contentController),

                  // TextField(
                  //   controller: _contentController,
                  //   decoration: const InputDecoration(
                  //     hintText: "Note content...",
                  //     border: InputBorder.none,
                  //   ),
                  //   keyboardType: TextInputType.multiline,
                  //   maxLines: null,
                  //   expands: true,
                  // ),
                ),

                if (!isNewNote)
                  ElevatedButton.icon(
                    onPressed: _pickReminder,
                    icon: Icon(Icons.alarm),
                    label: Text(
                      reminderDate == null
                          ? "Set a reminder"
                          : "Reminder: ${reminderDate.toString()}",
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
      ),
    );
  }
}
