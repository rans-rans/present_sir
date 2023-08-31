// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:io';
import 'dart:convert';
import 'dart:math' show cos, sqrt, asin;

import 'package:flutter/material.dart';
import 'package:fl_location/fl_location.dart';
import 'package:geodesy/geodesy.dart' show LatLng;
import 'package:permission_handler/permission_handler.dart' as per;
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

import '../models/passcode.dart';
import '../models/app_user.dart';
import '../models/classroom.dart';
import '../models/attendant.dart';

class AttendanceProvider with ChangeNotifier {
  static SharedPreferences? _shared;

  final supabase = Supabase.instance.client;

  bool _isLecturer = false;
  bool get isLecturer => _isLecturer;
  AppUser appUser = AppUser(name: '');
  int _selectedYearIndex = 0;
  List<String> _classYears = [
    DateTime.now().year.toString(),
  ];

  int get selectedYearIndex => _selectedYearIndex;
  List<String> get classYears => _classYears;

  void setYearIndex(String year) {
    _selectedYearIndex = _classYears.indexWhere((e) => e == year);
    notifyListeners();
  }

  void setClassYears(List<String> years) {
    _classYears = years;
    notifyListeners();
  }

  static Future init() async {
    _shared = await SharedPreferences.getInstance();
  }

  Future<void> getUserData(bool mounted) async {
    final data = _shared!.getString('credentials');
    final jsonUser = json.decode(data!);
    appUser = AppUser.fromJson(jsonUser);
    _isLecturer = jsonUser['lecturer_id'] != null;
  }

  void setUserProfile({
    required String name,
    required bool mounted,
    String? indexNumber,
    String? lecturerId,
    String? programName,
  }) async {
    appUser.name = name;
    appUser.lecturerId = lecturerId;
    appUser.indexNumber = indexNumber;
    appUser.programmeName = programName;
    await _shared!.setString('credentials', json.encode(appUser.toJson()));
    if (mounted) notifyListeners();
  }

  Future<void> signOutUser() async {
    await supabase.auth.signOut();
    appUser.clearUser();
    notifyListeners();
  }

  Future<Classroom> getClassFuture(Passcode passcode) async {
    final response = await supabase
        .from('class')
        .select()
        .eq('class_id', passcode.classId)
        .eq('lecturer_id', passcode.lecturerId)
        .onError((error, stackTrace) {
      throw stackTrace;
    }).timeout(
      const Duration(seconds: 7),
      onTimeout: () => throw const SocketException('timeout'),
    ) as List<dynamic>;
    final classroom = Classroom.networkFromJson(response[0]);

    return classroom;
  }

  Future<bool> recordPresent({
    required LatLng classLocation,
    required Attendant attendant,
  }) async {
    try {
      await per.Permission.location.request();
      final locationData = await FlLocation.getLocation();
      final studentLocation = LatLng(
        locationData.latitude,
        locationData.longitude,
      );

      final distance = double.parse(calculateDistance(classLocation, studentLocation));

      if (distance > 30) return false;

      await supabase.from('classattendance').insert(attendant.toJson()).onError((e, s) {
        throw s;
      }).timeout(
        const Duration(seconds: 7),
        onTimeout: () => throw const SocketException('class report timeout'),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> loginLecturer({
    required String lecturerId,
    required bool mounted,
  }) async {
    try {
      final lecturerRequest = await supabase.from('lecturer').select().eq(
            'lecturer_id',
            lecturerId.trim(),
          ) as List<dynamic>;

      final lecturerDetails = lecturerRequest[0] as Map<String, dynamic>;
      final email = lecturerDetails['email'];
      final password = lecturerDetails['password'];
      final name = lecturerDetails['personal_name'];
      final programName = lecturerDetails['programme_name'];
      await supabase.auth
          .signInWithPassword(
        email: email,
        password: password!,
      )
          .onError((error, stackTrace) {
        throw stackTrace;
      }).timeout(const Duration(seconds: 7), onTimeout: () {
        throw const SocketException('lecturer login timeout');
      });
      setUserProfile(
        name: name!,
        mounted: mounted,
        lecturerId: lecturerId.trim(),
        programName: programName.toString(),
      );
      _isLecturer = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> loginStudent({
    required String email,
    required String name,
    required String indexNumber,
    required bool isLogin,
    required String password,
    required bool mounted,
  }) async {
    try {
      final canContinue = switch (isLogin) {
        true => await supabase.auth
              .signInWithPassword(email: email.trim(), password: password.trim())
              .onError((_, err) => throw err)
              .timeout(const Duration(seconds: 7), onTimeout: () {
            throw const SocketException('student login timeout');
          }),
        false => await supabase.auth
              .signUp(email: email.trim(), password: password.trim())
              .onError((a, err) => throw err)
              .timeout(const Duration(seconds: 12), onTimeout: () {
            throw const SocketException('student sign-up timeout');
          }),
      };
      if (canContinue.user == null) return false;
      setUserProfile(
        name: name,
        mounted: mounted,
        indexNumber: indexNumber,
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

    final session = await supabase
        .rpc('create_class', params: classroom.networkJson())
        .onError((_, __) => null)
        .timeout(const Duration(seconds: 7), onTimeout: () => null);
    return session;
  }

  Future<List<Classroom>> getLecturerClassrooms(String year) async {
    try {
      final response = await supabase
          .from('class')
          .select()
          .eq('year', year)
          .eq('lecturer_id', appUser.lecturerId)
          .onError((error, stackTrace) {
        throw stackTrace;
      }) as List<dynamic>;
      final classList = response.map((e) => Classroom.networkFromJson(e)).toList();
      return classList;
    } catch (e) {
      return [];
    }
  }

  Future<List<Attendant>> fetchAttendants(String classId) async {
    try {
      final response = await supabase
          .from('classattendance')
          .select()
          .eq('class_id', classId)
          .eq('lecturer_id', appUser.lecturerId)
          .onError((_, err) => throw err)
          .timeout(
            const Duration(seconds: 7),
            onTimeout: () => throw const SocketException('attendants fetch failed'),
          ) as List<dynamic>;

      final attendants = response.map((e) => Attendant.fromJson(e)).toList();
      return attendants;
    } catch (_) {
      return [];
    }
  }

  Future<void> getLecturerYears() async {
    try {
      final response = await supabase.rpc('get_lecturer_uinque_years', params: {
        'p_lecturer_id': appUser.lecturerId,
      }) as List<dynamic>;
      final data = response[0]['years'] as List<dynamic>;
      final years = data.map((e) => '$e').toList();
      _classYears = years;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  String calculateDistance(LatLng classpoint, LatLng studentpoint) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((studentpoint.latitude - classpoint.latitude) * p) / 2 +
        cos(classpoint.latitude * p) *
            cos(studentpoint.latitude * p) *
            (1 - cos((studentpoint.longitude - classpoint.longitude) * p)) /
            2;
    final metres = 1274200 * asin(sqrt(a));
    return metres.toStringAsFixed(3);
  }
}
