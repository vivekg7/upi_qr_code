import 'package:flutter/material.dart';

class AppTitle extends StatelessWidget {
  const AppTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'UPI QR Code',
        textScaleFactor: 1.3,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
