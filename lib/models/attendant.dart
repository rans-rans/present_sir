class Attendant {
  final String studentId;
  final String studentName;
  final String classId;
  final String phoneId;
  final String lecturerId;

  Attendant({
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.phoneId,
    required this.lecturerId,
  });

  factory Attendant.fromJson(Map<String, dynamic> map) {
    return Attendant(
      classId: map["class_id"],
      phoneId: map["phone_id"],
      studentId: map["student_id"],
      lecturerId: map["lecturer_id"],
      studentName: map["student_name"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_id': classId,
      'phone_id': phoneId,
      'student_id': studentId,
      'lecturer_id': lecturerId,
      'student_name': studentId,
    };
  }
}
