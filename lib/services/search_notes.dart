import 'package:isar/isar.dart';
import '../models/note.dart';

class NoteRepository {
  final Isar isar;

  NoteRepository(this.isar);

  Future<List<Note>> searchNotes(String query) async {
    if (query.isEmpty) {
      return await isar.notes.where().findAll();
    }

    final notes = await isar.notes
        .filter()
        .group(
          (q) => q
              .titleContains(query, caseSensitive: false)
              .or()
              .contentContains(query, caseSensitive: false),
        )
        .findAll();

    return notes;
  }
}
