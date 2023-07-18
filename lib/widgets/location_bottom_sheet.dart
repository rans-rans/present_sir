import 'package:flutter/material.dart';

import '/models/class_location.dart';
import '../utils/class_locations.dart';

Future<ClassLocation?> locationBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        height: 250,
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            const Text(
              'Locations',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  for (var place in classLocations)
                    ListTile(
                      title: Text(place.name),
                      onTap: () => Navigator.pop(context, place),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
