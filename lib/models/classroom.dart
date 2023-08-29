import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';

class Classroom {
  final String todayTopic;
  final LatLng location;
  final int year;
  final DateTime date;
  final String lecturerId;
  final String classId;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  Classroom({
    required this.todayTopic,
    required this.lecturerId,
    this.classId = '',
    required this.endTime,
    this.year = 2000,
    required this.date,
    required this.startTime,
    required this.location,
  });

  factory Classroom.networkFromJson(Map<String, dynamic> map) {
    final location = json.decode(map['location']);
    final endTime = json.decode(map['end_time']);
    final startTime = json.decode(map['start_time']);
    return Classroom(
      year: int.parse(map['year']),
      classId: map['class_id'],
      todayTopic: map['topic'],
      lecturerId: map['lecturer_id'],
      date: DateTime.parse(map['class_date']),
      location: LatLng(
        location['lat'],
        location['lon'],
      ),
      endTime: TimeOfDay(
        hour: endTime['hr'],
        minute: endTime['min'],
      ),
      startTime: TimeOfDay(
        hour: startTime['hr'],
        minute: startTime['min'],
      ),
    );
  }

  Map<String, dynamic> networkJson() {
    return {
      'p_topic': todayTopic,
      'p_year': DateTime.now().year.toString(),
      'p_lecturer_id': lecturerId,
      'p_class_date': date.toIso8601String(),
      'p_location': json.encode({
        'lat': location.latitude,
        'lon': location.longitude,
      }),
      'p_start_time': json.encode({
        'hr': startTime.hour,
        'min': startTime.minute,
      }),
      'p_end_time': json.encode({
        'hr': endTime.hour,
        'min': endTime.minute,
      }),
    };
  }
}
