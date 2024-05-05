import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upi_qr_code/models/user.dart';

const spUserDetails = 'user_details';
const spUsersList = 'user_detail_list';
const spDefaultUser = 'user_default';

Future<List<User>> getUserList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? data = prefs.getStringList(spUsersList);
  if (data == null || data.isEmpty) {
    return [];
  } else {
    return data.map((e) => User.fromString(e)).toList();
  }
}

Future<void> setUserList(List<User> users) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> usersData = users.map((e) => e.toString()).toList();
  await prefs.setStringList(spUsersList, usersData);
}

Future<String?> getDefaultUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? data = prefs.getString(spDefaultUser);
  if (data == null || data.isEmpty) {
    return null;
  } else {
    return data;
  }
}

Future<void> setDefaultUser(String defaultUser) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(spDefaultUser, defaultUser);
}

Future<void> migrateOldUser() async {
  // TODO: remove this code in future: 2024-05-01
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? data = prefs.getString(spUserDetails);
  if (data == null || data.isEmpty) {
    return;
  }
  await prefs.setStringList(spUsersList, [data]);
  await prefs.remove(spUserDetails);
}

const smallGap = SizedBox(height: 10);
const gap = SizedBox(height: 20);
const largeGap = SizedBox(height: 30);

String clipText(String text, {int size = 10}) {
  if (text.length <= size) return text;
  return '${text.substring(0, size)}...';
}
