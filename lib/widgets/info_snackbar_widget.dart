import 'package:flutter/material.dart';

class InfoSnackBarWidget {
  static SnackBar snackbar(bool response) {
    return SnackBar(
      backgroundColor: switch (response) {
        true => Colors.green,
        false => Colors.red,
      },
      content: Text(
        style: const TextStyle(color: Colors.white),
        switch (response) {
          true => "Sign in successful",
          false => 'Sign in failed',
        },
      ),
    );
  }
}
