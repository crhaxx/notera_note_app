import 'package:isar/isar.dart';

part 'note.g.dart';

@Collection()
class Note {
  Id id = Isar.autoIncrement;

  String title;
  String content;
  bool isPinned = false;
  DateTime createdAt;
  DateTime updatedAt;

  Note({
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  Note.create({
    required this.title,
    required this.content,
  })  : createdAt = DateTime.now(),
        updatedAt = DateTime.now();
}
