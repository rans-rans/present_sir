class Passcode {
  final String lecturerId;
  final String classId;

  Passcode({
    required this.lecturerId,
    required this.classId,
  });

  factory Passcode.fromJson(Map<String, dynamic> map) {
    return Passcode(
      classId: map['s'],
      lecturerId: map['l'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      's': classId,
      'l': lecturerId,
    };
  }
}
