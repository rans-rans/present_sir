// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:present_sir/pages/login_page.dart';
import 'package:provider/provider.dart';

import '/pages/homepage.dart';
import 'firebase_options.dart';
import 'provider/attendence_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AttendanceProvider.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AttendanceProvider(),
      child: MaterialApp(
        home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.data == null) return const LoginPage();
              return const Homepage();
            }),
        theme: ThemeData(
            primaryColor: const Color.fromARGB(255, 255, 99, 60),
            datePickerTheme: DatePickerThemeData(
                shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            )),
            inputDecorationTheme: const InputDecorationTheme(
              enabledBorder: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(),
            )),
      ),
    );
  }
}
