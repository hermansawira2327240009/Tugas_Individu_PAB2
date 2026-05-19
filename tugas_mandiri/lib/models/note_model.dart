class NoteModel {
  final String id;
  final String courseId;
  final String courseName;
  final String title;
  final String content;
  final int timestamp;

  NoteModel({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.title,
    required this.content,
    required this.timestamp,
  });

  /// Factory constructor: buat dari snapshot Firebase
  factory NoteModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return NoteModel(
      id: id,
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] is int
          ? map['timestamp']
          : int.tryParse(map['timestamp'].toString()) ?? 0,
    );
  }

  /// Konversi ke Map untuk disimpan ke Firebase
  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'title': title,
      'content': content,
      'timestamp': timestamp,
    };
  }

  /// Salin objek dengan nilai yang diubah
  NoteModel copyWith({
    String? courseId,
    String? courseName,
    String? title,
    String? content,
  }) {
    return NoteModel(
      id: id,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp,
    );
  }
}
