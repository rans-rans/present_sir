class Passcode {
  final String lecturerId;
  final String sessionId;

  Passcode({
    required this.lecturerId,
    required this.sessionId,
  });

  factory Passcode.fromJson(Map<String, dynamic> map) {
    return Passcode(
      lecturerId: map['l'],
      sessionId: map['s'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      's': sessionId,
      'l': lecturerId,
    };
  }
}
