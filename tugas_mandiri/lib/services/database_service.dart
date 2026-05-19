import 'package:firebase_database/firebase_database.dart';
import '../models/course_model.dart';
import '../models/note_model.dart';

/// Service untuk semua operasi CRUD ke Firebase Realtime Database.
class DatabaseService {
  // Singleton instance
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // ─────────────────────── COURSES ───────────────────────

  /// Referensi node courses
  DatabaseReference get _coursesRef => _db.child('courses');

  /// Tambah mata kuliah baru
  Future<void> addCourse(CourseModel course) async {
    await _coursesRef.push().set(course.toMap());
  }

  /// Stream daftar semua mata kuliah (realtime)
  Stream<List<CourseModel>> getCourses() {
    return _coursesRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];

      final map = Map<String, dynamic>.from(data as Map);
      return map.entries.map((e) {
        final val = Map<dynamic, dynamic>.from(e.value as Map);
        return CourseModel.fromMap(e.key, val);
      }).toList();
    });
  }

  // ─────────────────────── NOTES ───────────────────────

  /// Referensi node notes
  DatabaseReference get _notesRef => _db.child('notes');

  /// Tambah catatan baru
  Future<void> addNote(NoteModel note) async {
    await _notesRef.push().set(note.toMap());
  }

  /// Update catatan yang sudah ada
  Future<void> updateNote(NoteModel note) async {
    await _notesRef.child(note.id).update(note.toMap());
  }

  /// Hapus catatan berdasarkan ID
  Future<void> deleteNote(String noteId) async {
    await _notesRef.child(noteId).remove();
  }

  /// Stream daftar semua catatan (realtime), diurutkan berdasarkan timestamp descending
  Stream<List<NoteModel>> getNotes() {
    return _notesRef.orderByChild('timestamp').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];

      final map = Map<String, dynamic>.from(data as Map);
      final list = map.entries.map((e) {
        final val = Map<dynamic, dynamic>.from(e.value as Map);
        return NoteModel.fromMap(e.key, val);
      }).toList();

      // Urutkan descending (terbaru di atas)
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  /// Stream catatan berdasarkan courseId
  Stream<List<NoteModel>> getNotesByCourse(String courseId) {
    return _notesRef
        .orderByChild('courseId')
        .equalTo(courseId)
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];

      final map = Map<String, dynamic>.from(data as Map);
      final list = map.entries.map((e) {
        final val = Map<dynamic, dynamic>.from(e.value as Map);
        return NoteModel.fromMap(e.key, val);
      }).toList();

      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }
}
