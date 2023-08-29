// ignore_for_file: use_build_context_synchronously, sort_child_properties_last

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import '../models/class_location.dart';
import '/models/passcode.dart';
import '/models/classroom.dart';
import '../utils/formatter.dart';
import '../provider/attendence_provider.dart';
import '../widgets/location_bottom_sheet.dart';

class CreateClassPage extends StatefulWidget {
  const CreateClassPage({super.key});

  @override
  State<CreateClassPage> createState() => _CreateClassPageState();
}

class _CreateClassPageState extends State<CreateClassPage> {
  final todayTopicFocus = FocusNode();
  final todayTopicCtrl = TextEditingController();
  final screenshotController = ScreenshotController();

  String sessionId = '';
  bool scheduleCreationLoading = false;
  bool scheduleSuccesful = false;
  bool sessionIdCopied = false;

  TimeOfDay? startTime;
  TimeOfDay? endTime;
  DateTime? date;
  ClassLocation? location;

  bool buttonShouldEnable() {
    if (startTime == null || endTime == null || date == null || location == null) return false;
    if (todayTopicCtrl.text.isEmpty) return false;
    if (scheduleCreationLoading) return false;
    if (scheduleSuccesful) return false;
    return true;
  }

  @override
  void dispose() {
    super.dispose();
    todayTopicFocus.dispose();
    todayTopicCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Create your class'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          bottomNavigationBar: ElevatedButton(
            child: scheduleCreationLoading ? const CircularProgressIndicator() : const Text('COMPLETE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: switch (buttonShouldEnable()) {
              false => null,
              true => () async {
                  setState(() => scheduleCreationLoading = true);
                  final classroom = Classroom(
                    date: date!,
                    endTime: endTime!,
                    startTime: startTime!,
                    location: location!.location,
                    todayTopic: todayTopicCtrl.text,
                    lecturerId: provider.appUser.lecturerId!,
                  );
                  final response = await provider.completeClassScheduling(classroom);
                  if (response != null) {
                    scheduleSuccesful = true;
                    sessionId = response;
                  }
                  scheduleCreationLoading = false;

                  setState(() {});

                  final imageBytes = await screenshotController.capture();
                  if (imageBytes == null || response == null) return;
                  ImageGallerySaver.saveImage(imageBytes);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 3),
                      backgroundColor: scheduleSuccesful ? Colors.green : Colors.red,
                      content: Text(
                        style: const TextStyle(color: Colors.white),
                        switch (scheduleSuccesful) {
                          true => ' QR code saved to gallery',
                          false => 'Operation failed. Try again'
                        },
                      ),
                    ),
                  );
                },
            },
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 55),
                  TextField(
                    controller: todayTopicCtrl,
                    focusNode: todayTopicFocus,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Topic',
                      hintText: 'Topic for the day',
                    ),
                  ),
                  const SizedBox(height: 45),
                  ListTile(
                    title: const Text('Start time'),
                    trailing: Text(switch (startTime) {
                      null => '--:--',
                      _ => startTime!.format(context),
                    }),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 0, minute: 0),
                      );
                      if (time == null) return;
                      startTime = time;
                      setState(() {});
                    },
                  ),
                  ListTile(
                    title: const Text('End time'),
                    trailing: Text(switch (endTime) {
                      null => '--:--',
                      _ => endTime!.format(context),
                    }),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 0, minute: 0),
                      );
                      if (time == null) return;
                      endTime = time;
                      setState(() {});
                    },
                  ),
                  ListTile(
                    title: const Text('Date'),
                    trailing: Text(switch (date) {
                      null => 'Set date',
                      _ => Formatters.formatYear(date!),
                    }),
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2099),
                      );
                      if (selectedDate == null) return;
                      date = selectedDate;
                      setState(() {});
                    },
                  ),
                  ListTile(
                    title: const Text('Select location'),
                    trailing: switch (location == null) {
                      true => const Text('No Location selected'),
                      false => Text(location!.name),
                    },
                    onTap: () async {
                      final value = await locationBottomSheet(context);
                      if (value == null) return;
                      location = value;
                      if (mounted) setState(() {});
                    },
                  ),
                  if (sessionId.isNotEmpty)
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Screenshot(
                            controller: screenshotController,
                            child: QrImageView(
                              data: json
                                  .encode(Passcode(
                                    classId: sessionId,
                                    lecturerId: provider.appUser.lecturerId!,
                                  ).toJson())
                                  .toString(),
                              size: 200,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
