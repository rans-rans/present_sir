// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:convert';
import 'dart:io';
import 'dart:math' show cos, sqrt, asin;

import 'package:geodesy/geodesy.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart' as per;

import '../models/classroom.dart';
import '../models/passcode.dart';

const lecturer = 'lecturer';
const classList = 'classList';

class AttendanceProvider with ChangeNotifier {
  static SharedPreferences? _shared;
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  String _userName = '';
  String? _lecturerId;
  String? _programName;
  String? _indexNumber;

  bool _isLecturer = false;
  bool get isLecturer => _isLecturer;

  String get userName => _userName;
  String? get lecturerId => _lecturerId;
  String? get indexNumber => _indexNumber;
  String? get programName => _programName;

  static Future init() async {
    _shared = await SharedPreferences.getInstance();
  }

  Future<void> getStoredData() async {
    final data = _shared!.getString('credentials');
    final jsonUser = json.decode(data!);
    _userName = jsonUser['username'];
    _lecturerId = jsonUser['lecturerId'];
    _programName = jsonUser['programName'];
    _indexNumber = jsonUser['indexNumber'];
    if (jsonUser['lecturerId'] != null) {
      _isLecturer = true;
    }
  }

  void setUserProfile({
    required String name,
    String? indexNumber,
    String? lecturerId,
    String? programName,
  }) async {
    _userName = name;
    _lecturerId = lecturerId;
    _indexNumber = indexNumber;
    _programName = programName;
    await _shared!.setString(
        'credentials',
        json.encode({
          'username': userName,
          'indexNumber': indexNumber,
          'lecturerId': lecturerId,
          'programName': programName,
        }));
    notifyListeners();
  }

  Future<bool> recoredPresent({
    required Passcode passcode,
    required Classroom classroom,
  }) async {
    try {
      await per.Permission.location.request();
      final location = Location();
      final locationData = await location.getLocation();
      final studentLocation = LatLng(
        locationData.latitude!,
        locationData.longitude!,
      );

      final distance = calculateDistance(classroom.location, studentLocation);

      if (distance > 50) return false;

      await FirebaseFirestore.instance
          .collection('lecturer')
          .doc(passcode.lecturerId)
          .collection('classList')
          .doc(passcode.sessionId)
          .update({
            'classList': FieldValue.arrayUnion([
              {'studentName': _userName, 'indexNumber': indexNumber},
            ]),
          })
          .onError((error, stackTrace) => throw stackTrace)
          .timeout(
            const Duration(seconds: 7),
            onTimeout: () => throw const SocketException('Timeout reporting to class'),
          );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> completeClassScheduling(Classroom classroom) async {
    per.PermissionStatus? status;
    bool galleryGranted = await per.Permission.photos.isGranted;
    if (!galleryGranted) status = await per.Permission.photos.request();
    if (status == per.PermissionStatus.denied) return null;
    final classSession = Classroom(
      date: classroom.date,
      classList: [],
      endTime: classroom.endTime,
      lecturer: _userName,
      lecturerId: _lecturerId!,
      startTime: classroom.startTime,
      todayTopic: classroom.todayTopic,
      location: classroom.location,
    );

    final id = await FirebaseFirestore.instance
        .collection(lecturer)
        .doc(_lecturerId)
        .collection(classList)
        .add(classSession.toJson());
    return id.id;
  }

  Future<bool> signInWithGoogle(String name, String indexNumber) async {
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      setUserProfile(name: name, indexNumber: indexNumber);
      await auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> loginLecturer({
    required String lecturerId,
  }) async {
    try {
      final lecturerDetails = await firestore.collection('lecturer').doc(lecturerId).get();
      final lecturerData = lecturerDetails.data();
      final name = lecturerData!['name'];
      final email = lecturerData['email'];
      final password = lecturerData['password'];
      final programName = lecturerData['program'];
      await auth.signInWithEmailAndPassword(email: email, password: password);
      setUserProfile(
        name: name,
        lecturerId: lecturerId,
        programName: programName,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Classroom>> getLecturerClassrooms() async {
    List<Classroom> classrooms = [];
    final lecturerResponse = firestore.collection('lecturer').doc(_lecturerId).collection('classList');
    final classesJson = await lecturerResponse.snapshots().first;
    classrooms = classesJson.docs.map((item) => Classroom.fromJson(item.data())).toList();
    return classrooms;
  }

  double calculateDistance(LatLng classpoint, LatLng studentpoint) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((studentpoint.latitude - classpoint.latitude) * p) / 2 +
        cos(classpoint.latitude * p) *
            cos(studentpoint.latitude * p) *
            (1 - cos((studentpoint.longitude - classpoint.longitude) * p)) /
            2;
    final kilometer = 12742 * asin(sqrt(a));
    return kilometer / 1000;
  }
}
