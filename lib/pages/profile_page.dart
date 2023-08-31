import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/widgets/loading_dialog.dart';
import '/provider/attendence_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool lecturerIdCopied = false;
  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Profile'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.grey,
                  padding: const EdgeInsets.all(20),
                  height: 150,
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    provider.appUser.name,
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 45),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (provider.isLecturer)
                        ListTile(
                          title: const Text('Lecturer ID'),
                          subtitle: SelectableText(provider.appUser.lecturerId!),
                        ),
                      if (provider.isLecturer)
                        ListTile(
                          title: const Text('Programme name'),
                          subtitle: SelectableText(provider.appUser.programmeName!),
                        ),
                      if (provider.isLecturer == false)
                        ListTile(
                          title: const Text('Student ID'),
                          subtitle: SelectableText(provider.appUser.indexNumber!),
                        ),
                      const Divider(
                        thickness: 2,
                        color: Colors.grey,
                      ),
                      ListTile(
                        title: const Text(
                          'Long press to sign out',
                          style: TextStyle(color: Colors.red),
                        ),
                        selected: true,
                        selectedTileColor: Colors.red.shade100,
                        onLongPress: () async {
                          showLoadingDialog(context);
                          await provider.signOutUser();
                          if (mounted) Navigator.pushNamed(context, '/');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
