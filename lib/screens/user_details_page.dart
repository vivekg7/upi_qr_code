import 'package:flutter/material.dart';
import 'package:upi_qr_code/models/user.dart';
import 'package:upi_qr_code/utils.dart';
import 'package:upi_qr_code/widgets/app_title.dart';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({super.key});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  TextEditingController nameController = TextEditingController(text: '');
  TextEditingController upiIdController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    getUser().then((user) {
      if (user != null) {
        nameController.text = user.name;
        upiIdController.text = user.upiId;
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    upiIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            largeGap,
            const AppTitle(),
            largeGap,
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
                labelText: 'Name',
                hintText: 'Enter Name',
              ),
            ),
            gap,
            TextField(
              controller: upiIdController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'UPI ID',
                hintText: 'Enter UPI ID',
              ),
            ),
            gap,
            FilledButton(
              onPressed: () {
                final user = User(
                  name: nameController.text,
                  upiId: upiIdController.text,
                );
                setUser(user).then((_) => Navigator.pop(context));
              },
              child: const Text('Save Account Data'),
            ),
          ],
        ),
      ),
    );
  }
}
