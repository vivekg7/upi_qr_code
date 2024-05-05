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
  List<User> users = [];
  int selectedIdx = 0;
  bool canAddAccount = true;
  TextEditingController nameController = TextEditingController(text: '');
  TextEditingController upiIdController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    getUserList().then((userList) {
      if (userList.isEmpty) {
        return;
      }
      for (User u in userList) {
        if (u.upiId.isEmpty) {
          setState(() {
            canAddAccount = false;
          });
        }
      }
      setState(() {
        users = userList;
      });
      getDefaultUser().then((defaultUserId) {
        if (defaultUserId != null && defaultUserId.isNotEmpty) {
          int newIdx = userList.indexWhere((u) => u.upiId == defaultUserId);
          if (newIdx > 0) {
            setState(() {
              selectedIdx = newIdx;
            });
          }
        }
        onChangeSelectedIdx();
      });
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    upiIdController.dispose();
    super.dispose();
  }

  void promptDeleteUser(User u) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: const Text('are you sure you want to delete?'),
          actions: [
            FilledButton(
              style: ButtonStyle(
                backgroundColor:
                    const MaterialStatePropertyAll(Colors.transparent),
                foregroundColor: MaterialStatePropertyAll(
                    Theme.of(context).colorScheme.primary),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  users.remove(u);
                  if (selectedIdx > 0) {
                    selectedIdx--;
                  }
                });
                onSaveUsers();
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void onChangeSelectedIdx({int? newIdx}) {
    setState(() {
      if (newIdx != null) {
        selectedIdx = users.length > newIdx ? newIdx : 0;
      }
      if (users.length > selectedIdx) {
        nameController.text = users[selectedIdx].name;
        upiIdController.text = users[selectedIdx].upiId;
      } else {
        nameController.text = '';
        upiIdController.text = '';
      }
    });
  }

  Future<void> onSaveUsers() async {
    setState(() {
      if (users.isNotEmpty && users[0].upiId.isEmpty) {
        users.removeAt(0);
        if (selectedIdx > 0) {
          selectedIdx--;
        }
      }
      users.removeWhere((u) => u.upiId.isEmpty);
      if (users.length <= selectedIdx) {
        selectedIdx = 0;
      }
    });
    await setUserList(users);
    await setDefaultUser(
        users.length > selectedIdx ? users[selectedIdx].upiId : '');
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
                if (users.isNotEmpty) {
                  users[selectedIdx] = user;
                } else {
                  users.add(user);
                }
                onSaveUsers().then((_) => Navigator.pop(context));
              },
              child: const Text('Save Account Data'),
            ),
            // largeGap,
            if (canAddAccount)
              FilledButton(
                onPressed: () {
                  setState(() {
                    users.insert(0, User(name: '', upiId: ''));
                    canAddAccount = false;
                  });
                  onChangeSelectedIdx(newIdx: 0);
                },
                style: ButtonStyle(
                  backgroundColor:
                      const MaterialStatePropertyAll(Colors.transparent),
                  foregroundColor: MaterialStatePropertyAll(
                      Theme.of(context).colorScheme.primary),
                ),
                child: const Text('Add New Account'),
              ),
            ...users.map((u) {
              return ListTile(
                onTap: () {
                  onChangeSelectedIdx(newIdx: users.indexOf(u));
                },
                onLongPress: () {
                  onChangeSelectedIdx(newIdx: users.indexOf(u));
                  onSaveUsers().then((_) => Navigator.pop(context));
                },
                title: Text(
                  u.name.isEmpty ? '--' : u.name,
                ),
                subtitle: Text(
                  u.upiId.isEmpty ? '--' : u.upiId,
                ),
                dense: true,
                selected: u.upiId == users[selectedIdx].upiId,
                trailing: IconButton(
                  onPressed: () {
                    promptDeleteUser(u);
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
