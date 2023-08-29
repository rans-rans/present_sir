// ignore_for_file: curly_braces_in_flow_control_structures, use_build_context_synchronously, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'profile_page.dart';
import '../models/classroom.dart';
import '/pages/create_class_page.dart';
import '/provider/attendence_provider.dart';
import '../widgets/student_view_widget.dart';
import '../widgets/lecturer_view_widget.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;

  late Future<List<Classroom>> classrooms;
  late Future<void> userProfile;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AttendanceProvider>(context, listen: false);
    userProfile = provider.getUserData(mounted);
    classrooms = provider.getLecturerClassrooms(
      provider.classYears[provider.selectedYearIndex],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, child) => Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.yard_rounded),
          title: const Text('Present Sir'),
          backgroundColor: Theme.of(context).primaryColor,
          actions: [
            if (provider.isLecturer) createClassIcon(context),
            if (provider.isLecturer)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {});
                  classrooms = provider.getLecturerClassrooms(
                    provider.classYears[provider.selectedYearIndex],
                  );
                },
              ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20.0),
          child: Column(
            children: [
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Greetings',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            provider.appUser.name,
                            style: const TextStyle(
                              fontSize: 21,
                            ),
                          ),
                        ],
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/profile_avatar.png',
                          width: 120,
                          height: 120,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              switch (provider.isLecturer) {
                false => StudentViewWidget(
                    qrKey: qrKey,
                    mounted: mounted,
                  ),
                true => FutureBuilder<List<Classroom>>(
                    future: classrooms,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return const Center(child: CircularProgressIndicator());
                      if (snapshot.data == null || snapshot.data!.isEmpty)
                        return Container(
                          alignment: Alignment.center,
                          height: 70,
                          child: const Text(
                            'Empty Data',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      return Expanded(
                        child: LecturerViewWidget(
                          classrooms: snapshot.data!,
                        ),
                      );
                    },
                  ),
              }
            ],
          ),
        ),
      ),
    );
  }

  IconButton createClassIcon(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              return const CreateClassPage();
            },
          ),
        );
      },
    );
  }
}
