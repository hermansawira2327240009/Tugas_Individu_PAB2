class CourseModel {
  final String id;
  final String name;
  final String lecturer;

  CourseModel({
    required this.id,
    required this.name,
    required this.lecturer,
  });

  /// Factory constructor: buat dari snapshot Firebase
  factory CourseModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return CourseModel(
      id: id,
      name: map['name'] ?? '',
      lecturer: map['lecturer'] ?? '',
    );
  }

  /// Konversi ke Map untuk disimpan ke Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lecturer': lecturer,
    };
  }

  @override
  String toString() => name;
}
