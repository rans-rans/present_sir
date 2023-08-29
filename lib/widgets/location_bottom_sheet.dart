// ignore_for_file: use_build_context_synchronously

import 'package:geodesy/geodesy.dart';
import 'package:flutter/material.dart';
import 'package:fl_location/fl_location.dart';
import 'package:permission_handler/permission_handler.dart';

import '/models/class_location.dart';
import '../utils/class_locations.dart';

Future<ClassLocation?> locationBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        height: 250,
        padding: const EdgeInsets.all(5),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Locations',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 220,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Use current location'),
                        onTap: () async {
                          await Permission.location.request();
                          final locationData = await FlLocation.getLocation();
                          final stLoc = LatLng(
                            locationData.latitude,
                            locationData.longitude,
                          );
                          Navigator.pop(
                            context,
                            ClassLocation(
                              name: 'Current Location',
                              location: LatLng(stLoc.latitude, stLoc.longitude),
                            ),
                          );
                        },
                      ),
                      for (var place in classLocations)
                        ListTile(
                          title: Text(place.name),
                          onTap: () => Navigator.pop(context, place),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
