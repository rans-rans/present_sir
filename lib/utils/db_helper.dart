// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';
import 'package:present_sir/models/classroom.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

const classrooms = "classroom";

class DbHelper {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute("""CREATE TABLE IF NOT EXISTS $classrooms,
         (date TEXT PRIMARY KEY, todayTopic TEXT, location TEXT, lecturer TEXT, startTime TEXT,endTime TEXT,lecturerId TEXT
         );""");
      },
    );
  }

  static Future<void> addNote({required Classroom classroom}) async {
    final value = await database();
    await value.rawInsert("""
    INSERT INTO  $classroom(todayTopic, location, date, lecturer,startTime,endTime,lecturerId)
    VALUES (?,?,?,?,?,?,?);
    """, [
      classroom.todayTopic,
      json.encode({
        'lat': classroom.location.latitude,
        'lon': classroom.location.longitude,
      }),
      classroom.date.toIso8601String(),
      classroom.lecturer,
      json.encode({
        'hour': classroom.startTime.hour,
        'minute': classroom.startTime.minute,
      }),
      json.encode({
        'hour': classroom.endTime.hour,
        'minute': classroom.endTime.minute,
      }),
      classroom.lecturerId,
    ]);
  }

  static Future<List<Classroom>> getNotes() async {
    final value = await database();
    final jsonClassroomList = await value.rawQuery("SELECT * FROM $classrooms");
    List<Classroom> dummyClassroooms = [];
    for (var map in jsonClassroomList) {
      final jsonLocation = json.decode(map['location'].toString()) as Map<String, dynamic>;
      final jsonStartTime = json.decode(map['startTime'].toString()) as Map<String, dynamic>;
      final jsonEndTime = json.decode(map['endTime'].toString()) as Map<String, dynamic>;
      final location = LatLng(
        jsonLocation['lat'],
        jsonLocation['lon'],
      );
      final startTime = TimeOfDay(
        hour: jsonStartTime['hour'],
        minute: jsonStartTime['minute'],
      );
      final endTime = TimeOfDay(
        hour: jsonEndTime['hour'],
        minute: jsonEndTime['minute'],
      );
      dummyClassroooms.add(
        Classroom(
          todayTopic: map['todayTopic'].toString(),
          classList: [],
          endTime: endTime,
          date: DateTime.parse(map['todayTopic'].toString()),
          lecturer: map['lecturer'].toString(),
          startTime: startTime,
          location: location,
          lecturerId: map['lecturerId'].toString(),
        ),
      );
    }
    return dummyClassroooms;
  }
}
