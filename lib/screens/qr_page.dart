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
  List<User> users = [];
  User? selectedUser;
  TextEditingController amntController = TextEditingController();
  TextEditingController descController = TextEditingController(text: '');
  int pageState = 0;
  String qrData = '';

  @override
  void initState() {
    super.initState();
    getUserList().then((userList) {
      if (userList.isEmpty) {
        migrateOldUser().then((_) {
          goToUserDetailsPage();
        });
      } else {
        getDefaultUser().then((defaultUserId) {
          User defaultUser = userList[0];
          if (defaultUserId != null && defaultUserId.isNotEmpty) {
            for (User u in userList) {
              if (u.upiId == defaultUserId) {
                defaultUser = u;
                break;
              }
            }
          }
          setState(() {
            users = userList;
            selectedUser = defaultUser;
          });
        });
      }
    });
  }

  String generateQrData() {
    return 'upi://pay?pa=${selectedUser?.upiId}&pn=${selectedUser?.name}'
        '&am=${amntController.text}&tn=${descController.text}&cu=INR';
  }

  void goToUserDetailsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserDetailsPage()),
    ).then((_) {
      getUserList().then((userList) {
        if (userList.isEmpty) {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        } else {
          getDefaultUser().then((defaultUserId) {
            User defaultUser = userList[0];
            if (defaultUserId != null && defaultUserId.isNotEmpty) {
              for (User u in userList) {
                if (u.upiId == defaultUserId) {
                  defaultUser = u;
                  break;
                }
              }
            }
            setState(() {
              users = userList;
              selectedUser = defaultUser;
            });
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
            qrData = generateQrData();
          });
        },
        child: const Text('Generate QR Code'),
      ),
      gap,
      TextButton(
        child: const Text('Share this App'),
        onPressed: () {
          Share.share('Please checkout "UPI QR Code Generator"'
              ' App on Google Play Store '
              'https://play.google.com/store/apps/details?id=com.crylo.upi_qr_code');
        },
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
      title: Text(
        selectedUser?.name ?? '',
      ),
      subtitle: Text(
        selectedUser?.upiId ?? '',
      ),
      dense: true,
      trailing: pageState == 0
          ? IconButton(
              icon: const Icon(Icons.edit),
              onPressed: goToUserDetailsPage,
              visualDensity: VisualDensity.compact,
            )
          : IconButton(
              icon: const Icon(Icons.share),
              onPressed: shareUPIPayment,
              visualDensity: VisualDensity.compact,
            ),
    );
  }

  void shareUPIPayment() {
    Share.share('Pay ₹${amntController.text}/- to ${selectedUser?.name}\n'
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
