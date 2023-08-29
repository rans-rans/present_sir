class AppUser {
  String name;
  String? lecturerId;
  String? programmeName;
  String? indexNumber;

  AppUser({
    required this.name,
    this.lecturerId,
    this.programmeName,
    this.indexNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lecturer_id': lecturerId,
      'index_number': indexNumber,
      'programme_name': programmeName,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> map) {
    return AppUser(
      name: map['name'],
      lecturerId: map['lecturer_id'],
      indexNumber: map['index_number'],
      programmeName: map['programme_name'],
    );
  }

  void clearUser() {
    name = '';
    indexNumber = null;
    lecturerId = null;
    programmeName = null;
  }
}
