import 'package:flutter/material.dart';

Future<dynamic> showLoadingDialog(BuildContext context) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        content: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: 150,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 25),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(strokeWidth: 10),
              SizedBox(height: 15),
              Text('Request loaing'),
            ],
          ),
        ),
      );
    },
  );
}
