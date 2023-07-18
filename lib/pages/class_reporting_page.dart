// ignore_for_file: sort_child_properties_last, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/models/classroom.dart';
import '../models/passcode.dart';
import '/widgets/loading_dialog.dart';
import '/provider/attendence_provider.dart';

class ClassRecordingPage extends StatefulWidget {
  final Passcode passcode;
  const ClassRecordingPage({required this.passcode, super.key});

  @override
  State<ClassRecordingPage> createState() => _ClassRecordingPageState();
}

class _ClassRecordingPageState extends State<ClassRecordingPage> {
  Classroom? classroom;
  late AttendanceProvider _provider;
  late Future<DocumentSnapshot<Map<String, dynamic>>> _getFuture;

  Future<DocumentSnapshot<Map<String, dynamic>>> getFuture() async {
    final future = await FirebaseFirestore.instance
        .collection('lecturer')
        .doc(widget.passcode.lecturerId)
        .collection('classList')
        .doc(widget.passcode.sessionId)
        .snapshots()
        .first;
    return future;
  }

  Future<void> recoredPresent() async {
    showLoadingDialog(context);
    final isSuccessful = await _provider.recoredPresent(
      passcode: widget.passcode,
      classroom: classroom!,
    );

    if (isSuccessful) {
      classroom!.classList.add({
        'studentName': _provider.userName,
        'indexNumber': _provider.indexNumber,
      });
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          presentSnackBar('Successfully marked present'),
        );
      setState(() {});
    } else {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          presentSnackBar('Error marking present'),
        );
    }
  }

  SnackBar presentSnackBar(String message) {
    return SnackBar(
      content: SnackBar(content: Text(message)),
    );
  }

  bool showPresentButton() {
    return (classroom == null ||
        !classroom!.classList.any((e) => e['indexNumber'] == _provider.indexNumber) ||
        DateTime.now().year > classroom!.date.year ||
        DateTime.now().month > classroom!.date.month ||
        DateTime.now().day > classroom!.date.day ||
        TimeOfDay.now().hour > classroom!.endTime.hour ||
        TimeOfDay.now().minute > classroom!.endTime.minute);
  }

  @override
  void initState() {
    super.initState();
    _getFuture = getFuture();
    _provider = Provider.of<AttendanceProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      bottomSheet: switch (showPresentButton()) {
        true => null,
        false => ElevatedButton(
            child: const Text('REPORT PRESENT'),
            onPressed: () async => await recoredPresent(),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
      },
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _getFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(
              child: CircularProgressIndicator(),
            );
          final classMap = snapshot.data!.data();
          classroom = Classroom.fromJson(classMap!);
          return Column(
            children: [
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
                          classroom!.todayTopic,
                          softWrap: true,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          classroom!.lecturer,
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
                              classroom!.startTime.format(context),
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
                              classroom!.endTime.format(context),
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            alignment: Alignment.bottomCenter,
                            width: MediaQuery.sizeOf(context).width * 0.75,
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              switch (classroom!.classList
                                  .any((e) => e['studentName'] == _provider.indexNumber)) {
                                true => 'PRESENT',
                                false => 'ABSENT',
                              },
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: switch (classroom!.classList
                                  .any((e) => e['indexNumber'] == _provider.indexNumber)) {
                                true => Colors.green,
                                false => Colors.red,
                              },
                            ),
                          ),
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
