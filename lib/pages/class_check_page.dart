import 'package:flutter/material.dart';

import '/models/classroom.dart';

class ClassCheckPage extends StatelessWidget {
  final Classroom classroom;
  const ClassCheckPage({required this.classroom, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Classroom'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: classroom.classList.length,
            itemBuilder: (context, index) {
              final person = classroom.classList[index];
              return ListTile(
                leading: Text((index + 1).toString()),
                title: Text(person['studentName']),
                subtitle: Text(person['indexNumber']),
              );
            },
          ),
        ));
  }
}
