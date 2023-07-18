import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';

class Classroom {
  final String todayTopic;
  final LatLng location;
  final DateTime date;
  final String lecturer;
  final String lecturerId;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<Map<String, dynamic>> classList;
  Classroom({
    required this.todayTopic,
    required this.classList,
    required this.lecturerId,
    required this.endTime,
    required this.date,
    required this.lecturer,
    required this.startTime,
    required this.location,
  });

  factory Classroom.fromJson(Map<String, dynamic> map) {
    final classList = map['classList'] as List<dynamic>;
    final convertedClassList = List.generate(
      classList.length,
      (index) => {
        'studentName': classList[index]['studentName'],
        'indexNumber': classList[index]['indexNumber'],
      },
    );
    return Classroom(
      date: DateTime.parse(map['date']),
      lecturer: map['lecturer'],
      lecturerId: map['lecturerId'],
      todayTopic: map['classTopic'],
      classList: convertedClassList,
      endTime: TimeOfDay(hour: map['endHour'], minute: map['endMinute']),
      startTime: TimeOfDay(hour: map['startHour'], minute: map['startMinute']),
      location: LatLng(map['latitude'], map['longitude']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'classTopic': todayTopic,
      'classList': classList,
      'lecturerId': lecturerId,
      'lecturer': lecturer,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'startHour': startTime.hour,
      'startMinute': startTime.minute,
      'endHour': endTime.hour,
      'endMinute': endTime.minute,
    };
  }
}
