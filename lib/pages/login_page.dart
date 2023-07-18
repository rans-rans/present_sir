// ignore_for_file: curly_braces_in_flow_control_structures, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/info_snackbar_widget.dart';
import '../widgets/loading_dialog.dart';
import '/provider/attendence_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final studentFormKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final indexCtrl = TextEditingController();
  final lecturerIdCtrl = TextEditingController();

  bool isLecturer = false;

  bool? isStudentFormVaild() {
    final isVaild = studentFormKey.currentState!.validate();
    return isVaild;
  }

  @override
  void dispose() {
    super.dispose();
    nameCtrl.dispose();
    lecturerIdCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //TODO  add styling to  background
    return Consumer<AttendanceProvider>(
      builder: (context, provider, chidl) => Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'ACCOUNT',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 35),
                      Form(
                        key: studentFormKey,
                        child: switch (isLecturer) {
                          true => Column(
                              children: [
                                TextField(
                                  controller: lecturerIdCtrl,
                                  decoration: const InputDecoration(labelText: 'Lecturer Id'),
                                ),
                                const SizedBox(height: 50),
                                ElevatedButton(
                                  child: const Text('Login'),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColor),
                                    minimumSize: const MaterialStatePropertyAll(
                                      Size(double.infinity, 50),
                                    ),
                                  ),
                                  onPressed: () async {
                                    showLoadingDialog(context);
                                    final response =
                                        await provider.loginLecturer(lecturerId: lecturerIdCtrl.text.trim());
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(InfoSnackBarWidget.snackbar(response));
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              ],
                            ),
                          false => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: nameCtrl,
                                  validator: (e) {
                                    if (e == null || e.isEmpty) return 'Enter your full name';
                                    if (e.length < 2) return 'Length should be more than 2 characters';
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your full name',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: indexCtrl,
                                  validator: (e) {
                                    if (e == null || e.isEmpty) return 'Enter your index number';
                                    if (e.length < 5) return 'Length should be more than 5 characters';
                                    if (int.tryParse(e) == null) return 'Enter a valid index number';
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your index number',
                                  ),
                                ),
                                OutlinedButton.icon(
                                  icon: Image.asset(
                                    'assets/google-icon.jpg',
                                    width: 50,
                                  ),
                                  label: const Text(
                                    'Continue with Google',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    if (isStudentFormVaild() != true) {
                                      setState(() {});
                                      return;
                                    }
                                    final authResponse = await provider.signInWithGoogle(
                                      nameCtrl.text.trim(),
                                      indexCtrl.text.trim(),
                                    );
                                    if (mounted)
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        InfoSnackBarWidget.snackbar(authResponse),
                                      );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        },
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          child: Text(
                            switch (isLecturer) {
                              true => 'Login as Student',
                              false => 'Login as Lecturer',
                            },
                          ),
                          onPressed: () {
                            setState(() => isLecturer = !isLecturer);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
