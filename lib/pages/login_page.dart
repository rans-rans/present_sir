// ignore_for_file: curly_braces_in_flow_control_structures, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/loading_dialog.dart';
import '/provider/attendence_provider.dart';
import '../widgets/info_snackbar_widget.dart';

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

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  final idFocus = FocusNode();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();

  bool isLogin = true;
  bool isLecturer = false;

  bool? isStudentFormVaild() {
    final isVaild = studentFormKey.currentState!.validate();
    return isVaild;
  }

  @override
  void dispose() {
    super.dispose();
    nameCtrl.dispose();
    indexCtrl.dispose();
    lecturerIdCtrl.dispose();

    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();

    idFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, child) => Scaffold(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Lecturer',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Switch(
                      value: isLecturer,
                      thumbColor: const MaterialStatePropertyAll(
                        Color.fromARGB(255, 255, 0, 230),
                      ),
                      trackColor: const MaterialStatePropertyAll(
                        Colors.white,
                      ),
                      onChanged: (value) {
                        setState(() => isLecturer = value);
                      },
                    ),
                  ],
                ),
                //top spacer
                SizedBox(
                    height: switch (isLecturer) {
                  true => 200,
                  false => 85,
                }),
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
                          const SizedBox(height: 15),
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
                                        backgroundColor:
                                            MaterialStatePropertyAll(Theme.of(context).primaryColor),
                                        minimumSize: const MaterialStatePropertyAll(
                                          Size(double.infinity, 50),
                                        ),
                                      ),
                                      onPressed: () async {
                                        showLoadingDialog(context);
                                        final response = await provider.loginLecturer(
                                          lecturerId: lecturerIdCtrl.text.trim(),
                                          mounted: mounted,
                                        );
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(InfoSnackBarWidget.snackbar(response: response));
                                          Navigator.pop(context);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              false => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    //name field
                                    TextFormField(
                                      controller: nameCtrl,
                                      textInputAction: TextInputAction.next,
                                      onEditingComplete: () {
                                        FocusScope.of(context).requestFocus(idFocus);
                                      },
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
                                    //index number  field,
                                    TextFormField(
                                      focusNode: idFocus,
                                      controller: indexCtrl,
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter your index number',
                                      ),
                                      onEditingComplete: () {
                                        FocusScope.of(context).requestFocus(emailFocus);
                                      },
                                      validator: (e) {
                                        if (e == null || e.isEmpty) return 'Enter your index number';
                                        if (e.length < 5) return 'Length should be more than 5 characters';
                                        if (int.tryParse(e) == null) return 'Enter a valid index number';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    //email field
                                    TextFormField(
                                      controller: emailCtrl,
                                      focusNode: emailFocus,
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter your email',
                                      ),
                                      onEditingComplete: () {
                                        FocusScope.of(context).requestFocus(passwordFocus);
                                      },
                                      validator: (e) {
                                        if (e == null || e.isEmpty) return 'Enter your email';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    //password field
                                    TextFormField(
                                      obscureText: true,
                                      controller: passwordCtrl,
                                      focusNode: passwordFocus,
                                      textInputAction: switch (isLogin) {
                                        true => TextInputAction.done,
                                        false => TextInputAction.next,
                                      },
                                      decoration: const InputDecoration(
                                        hintText: 'Password',
                                      ),
                                      onEditingComplete: () {
                                        if (!isLogin)
                                          FocusScope.of(context).requestFocus(confirmPasswordFocus);
                                        else
                                          FocusScope.of(context).unfocus();
                                      },
                                      validator: (e) {
                                        if (e == null || e.isEmpty) return 'Enter your password';
                                        if (!isLogin && passwordCtrl.text != confirmPasswordCtrl.text)
                                          return 'Passwords do not match';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    //confirm password field
                                    if (!isLogin)
                                      TextFormField(
                                        obscureText: true,
                                        controller: confirmPasswordCtrl,
                                        focusNode: confirmPasswordFocus,
                                        decoration: const InputDecoration(
                                          hintText: 'Confirm Password',
                                        ),
                                        validator: (e) {
                                          if (e == null || e.isEmpty) return 'Enter your password';
                                          if (passwordCtrl.text != confirmPasswordCtrl.text)
                                            return 'Passwords do not match';
                                          return null;
                                        },
                                      ),
                                    const SizedBox(height: 16),
                                    OutlinedButton(
                                      child: Text(
                                        switch (isLogin) {
                                          true => 'Login',
                                          false => 'Sign up',
                                        },
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () async {
                                        if (isStudentFormVaild() != true) return;
                                        showLoadingDialog(context);
                                        final canContinue = await provider.loginStudent(
                                          email: emailCtrl.text,
                                          name: nameCtrl.text,
                                          indexNumber: indexCtrl.text,
                                          password: passwordCtrl.text,
                                          isLogin: isLogin,
                                          mounted: mounted,
                                        );
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            InfoSnackBarWidget.snackbar(response: canContinue),
                                          );
                                          Navigator.pop(context);
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(double.infinity, 50),
                                        backgroundColor: Theme.of(context).primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
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
                                switch (isLogin) {
                                  true => 'Sign up instead',
                                  false => 'Login instead',
                                },
                                style: const TextStyle(color: Colors.pink),
                              ),
                              onPressed: () {
                                setState(() => isLogin = !isLogin);
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
        ),
      ),
    );
  }
}
