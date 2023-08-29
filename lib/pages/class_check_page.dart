// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/attendant.dart';
import '../provider/attendence_provider.dart';
import '/models/classroom.dart';

class ClassCheckPage extends StatefulWidget {
  final Classroom classroom;
  const ClassCheckPage({required this.classroom, super.key});

  @override
  State<ClassCheckPage> createState() => _ClassCheckPageState();
}

class _ClassCheckPageState extends State<ClassCheckPage> {
  int classLength = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Classroom'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Consumer<AttendanceProvider>(builder: (context, provider, ch) {
          return FutureBuilder<List<Attendant>>(
              future: provider.fetchAttendants(widget.classroom.classId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (snapshot.data == null || snapshot.data!.isEmpty)
                  return const Center(
                    child: Text(
                      'EMPTY CLASS',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                classLength = snapshot.data!.length;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('TOTAL:'),
                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(15),
                            child: Text(
                              classLength.toString(),
                              style: TextStyle(color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final person = snapshot.data![index];
                            return ListTile(
                              title: Text(person.studentName),
                              subtitle: Text(person.studentId),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              });
        }));
  }
}
