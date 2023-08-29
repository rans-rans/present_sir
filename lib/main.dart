// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/pages/homepage.dart';
import 'database_variables.dart';
import '/pages/login_page.dart';
import 'provider/attendence_provider.dart';

final supabase = Supabase.instance.client;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: anonKey);
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
        home: StreamBuilder<AuthState>(
            stream: supabase.auth.onAuthStateChange,
            builder: (context, snapshot) {
              return switch (supabase.auth.currentUser == null) {
                true => const LoginPage(),
                false => const Homepage(),
              };
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
