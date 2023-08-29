import 'package:flutter/material.dart';

class InfoSnackBarWidget {
  static SnackBar snackbar({
    String? message,
    bool response = false,
  }) {
    return SnackBar(
      backgroundColor: switch (response || message == 'DONE') {
        true => Colors.green,
        false => Colors.red,
      },
      content: Text(
        style: const TextStyle(color: Colors.white),
        message ??
            switch (response) {
              true => "Sign in successful",
              false => 'Sign in failed',
            },
      ),
    );
  }
}
