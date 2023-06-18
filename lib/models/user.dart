import 'dart:convert';

class User {
  final String name;
  final String upiId;

  User({
    required this.name,
    required this.upiId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'upi_id': upiId,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  static User fromJson(Map<String, dynamic> json) {
    return User(name: json['name'], upiId: json['upi_id']);
  }

  static User fromString(String data) {
    return fromJson(Map<String, dynamic>.from(jsonDecode(data)));
  }
}
