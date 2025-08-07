import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';

class IsarService {
  static final IsarService _instance = IsarService._internal();

  factory IsarService() => _instance;

  IsarService._internal() {
    db = _initDb();
  }

  late Future<Isar> db;

  Future<Isar> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open(
      [NoteSchema],
      directory: dir.path,
    );
  }

  Future<List<Note>> getAllNotes() async {
    final isar = await db;
    return await isar.notes
        .where()
        .sortByIsPinnedDesc()
        .thenByCreatedAtDesc()
        .findAll();
  }

  Future<void> addNote(Note note) async {
    final isar = await db;
    await isar.writeTxn(() => isar.notes.put(note));
  }

  Future<void> deleteNote(int id) async {
    final isar = await db;
    final noteExists = await isar.notes.get(id) != null;

    if (noteExists) {
      await isar.writeTxn(() => isar.notes.delete(id));
    }
  }

  Future<void> togglePin(Note note) async {
    final isar = await db;
    note.isPinned = !note.isPinned;
    await isar.writeTxn(() async {
      await isar.notes.put(note);
    });
  }
}
