import 'package:isar/isar.dart';

part 'note.g.dart';

@Collection()
class Note {
  Id id = Isar.autoIncrement;

  @Index(caseSensitive: false)
  String title;

  @Index(caseSensitive: false)
  String content;

  @Index()
  bool isPinned = false;

  @Index()
  bool isArchived = false;

  @Index()
  bool isLocked = false;

  @Index()
  bool isDeleted = false;

  int colorValue = 0x000000;

  DateTime createdAt;
  DateTime updatedAt;

  Note({
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isLocked = false,
  });

  Note.create({required this.title, required this.content})
    : createdAt = DateTime.now(),
      updatedAt = DateTime.now();
}
