// ignore_for_file: sort_child_properties_last, curly_braces_in_flow_control_structures

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/passcode.dart';
import '../pages/class_reporting_page.dart';

class StudentViewWidget extends StatelessWidget {
  const StudentViewWidget({
    super.key,
    required this.qrKey,
    required this.mounted,
  });

  final GlobalKey<State<StatefulWidget>> qrKey;
  final bool mounted;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: InkWell(
          child: Container(
            height: 250,
            width: 300,
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.camera_alt_rounded,
                  size: 75,
                ),
                Text('Scan To Class')
              ],
            ),
          ),
          onTap: () async {
            Passcode? passcode;
            String? scanningValue;
            await Permission.camera.request();
            if (mounted)
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return StatefulBuilder(
                      builder: (context, snap) => Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          QRView(
                            key: qrKey,
                            overlay: QrScannerOverlayShape(borderColor: Colors.green),
                            formatsAllowed: const [
                              BarcodeFormat.qrcode,
                            ],
                            onQRViewCreated: (ctrl) {
                              ctrl.scannedDataStream.listen((event) {
                                if (event.code != null) scanningValue = event.code;
                                if (mounted) snap(() {});
                              });
                            },
                          ),
                          if (scanningValue != null)
                            ElevatedButton(
                              child: const Text('CONTINUE'),
                              style: const ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(Colors.green),
                                minimumSize: MaterialStatePropertyAll(Size(double.infinity, 65)),
                              ),
                              onPressed: () {
                                final passmap = json.decode(scanningValue!) as Map<String, dynamic>;
                                passcode = Passcode.fromJson(passmap);
                                if (mounted)
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) {
                                        return ClassRecordingPage(passcode: passcode!);
                                      },
                                    ),
                                  );
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
              );
          },
        ),
      ),
    );
  }
}
