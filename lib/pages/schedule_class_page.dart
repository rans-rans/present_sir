// // ignore_for_file: use_build_context_synchronously, sort_child_properties_last, curly_braces_in_flow_control_structures

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geodesy/geodesy.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:screenshot/screenshot.dart';

// import '../models/class_session.dart';

// class ScheduleClassPage extends StatefulWidget {
//   const ScheduleClassPage({super.key});

//   @override
//   State<ScheduleClassPage> createState() => _ScheduleClassPageState();
// }

// class _ScheduleClassPageState extends State<ScheduleClassPage> {
//   final todayTopicCtrl = TextEditingController();
//   String sessionId = '';
//   final screenshotController = ScreenshotController();
//   TimeOfDay? startTime;
//   TimeOfDay? endTime;
//   bool scheduleCreationLoading = false;
//   bool scheduleSuccesful = false;
//   bool sessionIdCopied = false;

//   Future<bool> completeClassScheduling() async {
//     PermissionStatus? status;
//     bool galleryGranted = await Permission.photos.isGranted;
//     if (!galleryGranted) status = await Permission.photos.request();
//     if (status == PermissionStatus.denied) return false;
//     if (startTime == null || endTime == null || todayTopicCtrl.text.isEmpty) return false;
//     final classSession = ClassSession(
//       endTime: endTime!,
//       topic: todayTopicCtrl.text,
//       startTime: startTime!,
//       //TODO  make location dynamic later
//       location: const LatLng(0, 0),
//     );

//     final response = await FirebaseFirestore.instance.collection('class').add(
//           classSession.toJson(),
//         );
//     sessionId = response.id;
//     setState(() {});

//     final imageBytes = await screenshotController.capture();

//     if (imageBytes == null) return false;
//     ImageGallerySaver.saveImage(imageBytes);
//     return true;
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     todayTopicCtrl.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         if (scheduleSuccesful && sessionIdCopied == false) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Please copy the class id')),
//           );
//           return false;
//         }

//         return true;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           centerTitle: true,
//           title: const Text('Schedule class'),
//         ),
//         bottomSheet: ElevatedButton(
//           child: scheduleCreationLoading ? const CircularProgressIndicator() : const Text('COMPLETE'),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.black87,
//             minimumSize: const Size(double.infinity, 50),
//           ),
//           onPressed: scheduleSuccesful
//               ? null
//               : () async {
//                   setState(() => scheduleCreationLoading = true);
//                   scheduleSuccesful = await completeClassScheduling().whenComplete(() {
//                     setState(() => scheduleCreationLoading = false);
//                   });
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                     backgroundColor: scheduleSuccesful ? Colors.green : Colors.red,
//                     content: Text(
//                       scheduleSuccesful ? ' QR code saved to gallery' : 'Operation failed. Try again',
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ));
//                 },
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 const SizedBox(height: 20),
//                 ListTile(
//                   title: const Text('Start time'),
//                   trailing: Text(
//                     startTime == null ? '--:--' : '${startTime!.hour}:${startTime!.minute}',
//                   ),
//                   onTap: () async {
//                     final time = await showTimePicker(
//                       context: context,
//                       initialTime: const TimeOfDay(hour: 0, minute: 0),
//                     );
//                     if (time == null) return;
//                     startTime = time;
//                     setState(() {});
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('End time'),
//                   trailing: Text(
//                     endTime == null ? '--:--' : '${endTime!.hour}:${endTime!.minute}',
//                   ),
//                   onTap: () async {
//                     final time = await showTimePicker(
//                       context: context,
//                       initialTime: const TimeOfDay(hour: 0, minute: 0),
//                     );
//                     if (time == null) return;
//                     endTime = time;
//                     setState(() {});
//                   },
//                 ),
//                 const SizedBox(height: 15),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                   child: TextField(
//                     controller: todayTopicCtrl,
//                     decoration: const InputDecoration(labelText: 'Topic:Eg. Fraction'),
//                   ),
//                 ),
//                 const SizedBox(height: 250),
//                 if (sessionId.isNotEmpty)
//                   Column(
//                     children: [
//                       Screenshot(
//                         controller: screenshotController,
//                         child: QrImageView(
//                           data: sessionId,
//                           size: 200,
//                           backgroundColor: Colors.white,
//                         ),
//                       ),
//                       Container(
//                         color: Colors.grey.shade800,
//                         padding: const EdgeInsets.all(5),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               sessionId,
//                               style: const TextStyle(color: Colors.white),
//                             ),
//                             ElevatedButton.icon(
//                               icon: const Icon(Icons.copy),
//                               label: const Text('Copy'),
//                               onPressed: () {
//                                 Clipboard.setData(ClipboardData(text: sessionId));
//                               },
//                             ),
//                           ],
//                         ),
//                       )
//                     ],
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
