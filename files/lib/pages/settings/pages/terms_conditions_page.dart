import 'package:flutter/material.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Terms & Conditions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 12),
            Text('By downloading or using the app, these terms will automatically apply to you – you should make sure therefore that you read them carefully before using the app. You are not allowed to copy, or modify the app, any part of the app, or our trademarks in any way.'),
            SizedBox(height: 12),
            Text('It is committed to ensuring that the app is as useful and efficient as possible. For that reason, we reserve the right to make changes to the app or to charge for its services, at any time and for any reason.'),
            SizedBox(height: 12),
            Text('At some point, we may wish to update the app. The app is currently available on – the requirements for system (and for any additional systems we decide to extend the availability of the app to) may change, and youll need to download the updates if you want to keep using the app.'),
            SizedBox(height: 18),
            Text('Changes to This Terms and Conditions', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('We may update our Terms and Conditions from time to time. Thus, you are advised to review this page periodically for any changes.'),
            SizedBox(height: 18),
            Text('Contact Us', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('If you have any questions or suggestions about our Terms and Conditions, do not hesitate to contact us.'),
          ],
        ),
      ),
    );
  }
} 