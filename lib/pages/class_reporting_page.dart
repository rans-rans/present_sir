// ignore_for_file: sort_child_properties_last, curly_braces_in_flow_control_structures

import 'package:fl_location/fl_location.dart';
import 'package:geodesy/geodesy.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:present_sir/main.dart';
import 'package:provider/provider.dart';
import 'package:android_id/android_id.dart';

import '../widgets/info_snackbar_widget.dart';
import '/models/classroom.dart';
import '../models/passcode.dart';
import '../models/attendant.dart';
import '/widgets/loading_dialog.dart';
import '/provider/attendence_provider.dart';

class ClassRecordingPage extends StatefulWidget {
  final Passcode passcode;
  const ClassRecordingPage({required this.passcode, super.key});

  @override
  State<ClassRecordingPage> createState() => _ClassRecordingPageState();
}

class _ClassRecordingPageState extends State<ClassRecordingPage> {
  late Classroom classroom;
  late AttendanceProvider _provider;
  String? phoneId = '';
  late Future<Classroom> _getClassFuture;
  late Future<bool?> _getPresentStatus;

  ValueNotifier<bool?> canRecordPresent = ValueNotifier(null);

  Future<bool?> getPresentStatus() async {
    phoneId = await const AndroidId().getId() ?? '';

    final student = await supabase
        .from('classattendance')
        .select()
        .eq('student_id', _provider.appUser.indexNumber)
        .eq('phone_id', phoneId)
        .onError((_, __) => null)
        .timeout(const Duration(seconds: 7)) as List<dynamic>;
    if (student.isEmpty) {
      canRecordPresent.value = true;
      setState(() {});
      return true;
    }
    canRecordPresent.value = false;
    setState(() {});
    return false;
  }

  Future<void> recoredPresent() async {
    showLoadingDialog(context);
    final indexNumber = _provider.appUser.indexNumber;
    final attendant = Attendant(
      phoneId: phoneId!,
      classId: widget.passcode.classId,
      lecturerId: classroom.lecturerId,
      studentName: _provider.appUser.name,
      studentId: indexNumber!,
    );
    final now = DateTime.now();
    if (now.difference(classroom.date).inDays.abs() > 1 || now.hour > classroom.endTime.hour) {
      Navigator.pop(context);
      return;
    }

    final isSuccessful = await _provider.recordPresent(
      attendant: attendant,
      classLocation: classroom.location,
    );
    if (mounted) {
      Navigator.pop(context);
      if (isSuccessful) {
        ScaffoldMessenger.of(context).showSnackBar(
          InfoSnackBarWidget.snackbar(message: 'DONE'),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          InfoSnackBarWidget.snackbar(message: 'FAILED'),
        );
      }
    }
  }

  SnackBar presentSnackBar(String message) {
    return SnackBar(
      content: SnackBar(content: Text(message)),
    );
  }

  bool isWithinRange(Location location) =>
      double.parse(_provider.calculateDistance(
        classroom.location,
        LatLng(location.latitude, location.longitude),
      )) <=
      30;

  @override
  void initState() {
    super.initState();
    Permission.location.request();
    _provider = Provider.of<AttendanceProvider>(context, listen: false);
    _getClassFuture = _provider.getClassFuture(widget.passcode).whenComplete(() {
      _getPresentStatus = getPresentStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      bottomSheet: ValueListenableBuilder(
        valueListenable: ValueNotifier(canRecordPresent),
        builder: (context, value, child) {
          return ElevatedButton(
            child: const Text('REPORT PRESENT'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            onPressed: switch (canRecordPresent.value) {
              false => null,
              null => null,
              true => () async => await recoredPresent(),
            },
          );
        },
      ),
      body: FutureBuilder<Classroom>(
        future: _getClassFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(
              child: CircularProgressIndicator(),
            );
          if (snapshot.data == null)
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {});
                  _getClassFuture = _provider.getClassFuture(widget.passcode);
                },
                child: const Text('RELOAD'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(100, 100),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              ),
            );

          classroom = snapshot.data!;
          return Column(
            children: [
              StreamBuilder<Location>(
                stream: FlLocation.getLocationStream(),
                builder: (context, snapshot) {
                  final condition =
                      snapshot.data == null || snapshot.connectionState == ConnectionState.waiting;
                  return switch (condition) {
                    true => Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.all(15),
                        child: const Text(
                          'Waiting for location',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.red.shade400,
                      ),
                    false => Container(
                        height: 50,
                        width: double.infinity,
                        alignment: Alignment.bottomCenter,
                        margin: const EdgeInsets.all(15),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: switch (isWithinRange(snapshot.data!)) {
                              true => Colors.green,
                              false => Colors.red,
                            }),
                        child: Text(
                          style: const TextStyle(color: Colors.white),
                          switch (isWithinRange(snapshot.data!)) {
                            false => "You're outside classroom range",
                            true => "You're within classroom range. Distance:${_provider.calculateDistance(
                                classroom.location,
                                LatLng(snapshot.data!.latitude, snapshot.data!.longitude),
                              )}",
                          },
                        ),
                      )
                  };
                },
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.only(bottom: 30),
                color: Colors.grey.shade300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    Column(
                      children: [
                        Text(
                          classroom.todayTopic,
                          softWrap: true,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          classroom.todayTopic,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 125),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text(
                              'Start Time',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              classroom.startTime.format(context),
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text(
                              'End Time',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              classroom.endTime.format(context),
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: ValueListenableBuilder(
                              valueListenable: canRecordPresent,
                              builder: (context, presentValue, child) {
                                return Container(
                                  alignment: Alignment.bottomCenter,
                                  width: MediaQuery.sizeOf(context).width * 0.75,
                                  margin: const EdgeInsets.symmetric(vertical: 20),
                                  padding: const EdgeInsets.all(10),
                                  child: FutureBuilder<bool?>(
                                      future: _getPresentStatus,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting)
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        return Text(
                                          switch (presentValue) {
                                            true => 'ABSENT',
                                            null => 'INVALID',
                                            false => 'ALREADY PRESENT',
                                          },
                                          style: const TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: switch (presentValue) {
                                      true => Colors.red,
                                      null => Colors.grey,
                                      false => Colors.green,
                                    },
                                  ),
                                );
                              }),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
