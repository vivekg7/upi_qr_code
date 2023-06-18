import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upi_qr_code/models/user.dart';

const spUserDetails = 'user_details';

Future<User?> getUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? data = prefs.getString(spUserDetails);
  print('GetUser: $data');
  if (data == null || data.isEmpty) {
    return null;
  } else {
    return User.fromString(data);
  }
}

Future<void> setUser(User user) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(spUserDetails, user.toString());
  print('Saved User: ${user.toString()}');
}

const smallGap = SizedBox(height: 10);
const gap = SizedBox(height: 20);
const largeGap = SizedBox(height: 30);
