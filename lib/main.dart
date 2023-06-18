import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:upi_qr_code/screens/qr_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UPI QR Code',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.light(useMaterial3: true),
      home: const QRPage(),
    );
  }
}
