import 'package:flutter/material.dart';
import 'package:present_sir/pages/class_check_page.dart';

import '/models/classroom.dart';
import '/utils/formatter.dart';

class LecturerViewWidget extends StatelessWidget {
  final List<Classroom> classrooms;
  const LecturerViewWidget({
    required this.classrooms,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attendance History',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: classrooms.length,
            itemBuilder: (context, index) {
              return LecturerClassCard(
                classroom: classrooms[index],
              );
            },
          ),
        ),
      ],
    );
  }
}

class LecturerClassCard extends StatelessWidget {
  final Classroom classroom;
  const LecturerClassCard({
    required this.classroom,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return ClassCheckPage(classroom: classroom);
          },
        ));
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      classroom.date.day.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      months[classroom.date.month],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Topic',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        classroom.todayTopic,
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 19,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 30),
              Column(
                children: [
                  const Text('Attended'),
                  const SizedBox(height: 20),
                  Text(
                    classroom.classList.length.toString(),
                    style: const TextStyle(fontSize: 30),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
