import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:upi_qr_code/models/user.dart';
import 'package:upi_qr_code/screens/user_details_page.dart';
import 'package:upi_qr_code/utils.dart';
import 'package:upi_qr_code/widgets/app_title.dart';

class QRPage extends StatefulWidget {
  const QRPage({super.key});

  @override
  State<QRPage> createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  User? user;
  TextEditingController amntController = TextEditingController();
  TextEditingController descController = TextEditingController(text: '');
  int pageState = 0;
  String qrData = '';

  @override
  void initState() {
    super.initState();
    getUser().then((userResult) {
      if (userResult == null) {
        goToUserDetailsPage();
      } else {
        setState(() {
          user = userResult;
        });
      }
    });
  }

  void goToUserDetailsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserDetailsPage()),
    ).then((_) {
      getUser().then((userResult) {
        if (userResult == null) {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        } else {
          setState(() {
            user = userResult;
          });
        }
      });
    });
  }

  List<Widget> formFields() {
    return [
      TextField(
        controller: amntController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.currency_rupee),
          border: OutlineInputBorder(),
          labelText: 'Amount',
          hintText: 'Enter Amount',
        ),
      ),
      gap,
      TextField(
        controller: descController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Notes (Optional)',
          hintText: 'Enter Notes (Optional)',
        ),
      ),
      gap,
      FilledButton(
        onPressed: () {
          setState(() {
            pageState = 1;
            qrData = 'upi://pay?pa=${user?.upiId}&pn=${user?.name}'
                '&am=${amntController.text}&tn=${descController.text}&cu=INR';
          });
        },
        child: const Text('Generate QR Code'),
      ),
    ];
  }

  List<Widget> qrCode() {
    return [
      QrImageView(data: qrData),
      ListTile(
        title: Text.rich(TextSpan(
          text: 'Amount: ',
          children: [
            TextSpan(
              text: '₹${amntController.text}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        )),
        subtitle: Text.rich(TextSpan(
          text: 'Notes: ',
          children: [
            TextSpan(
              text: clipText(descController.text, size: 20),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        )),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            setState(() {
              pageState = 0;
            });
          },
        ),
      ),
      const Center(
        child: Text('Scan and pay with any BHIM UPI app'),
      ),
      Row(
        children: [
          Expanded(child: SvgPicture.asset('assets/icons/bhim.svg')),
          Expanded(child: SvgPicture.asset('assets/icons/upi.svg')),
        ],
      ),
    ];
  }

  Widget userWidget() {
    return ListTile(
      title: Text(user?.name ?? ''),
      subtitle: Text(user?.upiId ?? ''),
      trailing: pageState == 0
          ? IconButton(
              icon: const Icon(Icons.edit),
              onPressed: goToUserDetailsPage,
            )
          : IconButton(
              icon: const Icon(Icons.share),
              onPressed: shareUPIPayment,
            ),
    );
  }

  void shareUPIPayment() {
    Share.share('Pay ₹${amntController.text}/- to ${user?.name}\n'
        '${qrData.replaceAll(" ", "%20")}');
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
            userWidget(),
            gap,
            if (pageState == 0) ...formFields(),
            if (pageState == 1) ...qrCode(),
          ],
        ),
      ),
    );
  }
}
