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
    return await Isar.open([NoteSchema], directory: dir.path);
  }

  Future<List<Note>> getAllNotes() async {
    final isar = await db;
    return await isar.notes
        .where()
        .isArchivedEqualTo(false)
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
    note.updatedAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.notes.put(note);
    });
  }

  Future<void> archiveNote(int id, bool value) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final note = await isar.notes.get(id);
      if (note != null) {
        note.isArchived = value;
        await isar.notes.put(note);
      }
    });
  }

  Stream<List<Note>> listenToNotes({bool filterArchived = false}) async* {
    final isar = await db;
    final query = isar.notes
        .filter()
        .isArchivedEqualTo(filterArchived)
        .sortByCreatedAtDesc();
    yield* query.watch(fireImmediately: true);
  }

  Future<void> updateNoteColor(int noteId, int colorValue) async {
    final isar = await db;
    final note = await isar.notes.get(noteId);
    if (note != null) {
      note.colorValue = colorValue;
      await isar.writeTxn(() => isar.notes.put(note));
    }
  }
}
