// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/attendence_provider.dart';
import '/utils/formatter.dart';
import '/models/classroom.dart';
import '/pages/class_check_page.dart';

class LecturerViewWidget extends StatefulWidget {
  final List<Classroom> classrooms;
  const LecturerViewWidget({
    required this.classrooms,
    super.key,
  });

  @override
  State<LecturerViewWidget> createState() => _LecturerViewWidgetState();
}

class _LecturerViewWidgetState extends State<LecturerViewWidget> {
  bool classYearsLoading = false;
  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (ctx, provider, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RECORDS',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                provider.classYears[provider.selectedYearIndex],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              StatefulBuilder(
                builder: (ctx, snap) {
                  return DropdownButton<String>(
                    onChanged: (value) {
                      provider.getLecturerClassrooms(value!);
                      setState(() {});
                    },
                    value: provider.classYears[provider.selectedYearIndex],
                    items: [
                      for (String year in provider.classYears)
                        DropdownMenuItem(
                          child: Text(year),
                          value: year,
                          onTap: () {
                            provider.setYearIndex(year);
                          },
                        ),
                    ],
                    icon: switch (classYearsLoading) {
                      true => const CircularProgressIndicator(),
                      false => IconButton(
                          icon: const Icon(Icons.replay_outlined),
                          onPressed: () async {
                            snap(() => classYearsLoading = true);
                            await provider
                                .getLecturerYears()
                                .whenComplete(() => snap(() => classYearsLoading = false));
                          },
                        ),
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: widget.classrooms.length,
              itemBuilder: (context, index) {
                return LecturerClassCard(
                  classroom: widget.classrooms[index],
                );
              },
            ),
          ),
        ],
      ),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
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
            ],
          ),
        ),
      ),
    );
  }
}
