import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 12),
            Text('built the Find hotel app as a Commercial app. This SERVICE is provided by and is intended for use as is.'),
            SizedBox(height: 12),
            Text('This page is used to inform visitors regarding our policies with the collection, use, and disclosure of Personal Information if anyone decided to use our Service.'),
            SizedBox(height: 12),
            Text('If you choose to use our Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that we collect is used for providing and improving the Service. We will not use or share your information with anyone except as described in this Privacy Policy.'),
            SizedBox(height: 12),
            Text('The terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which is accessible at Find hotel unless otherwise defined in this Privacy Policy.'),
            SizedBox(height: 18),
            Text('Information Collection and Use', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('For a better experience, while using our Service, we may require you to provide us with certain personally identifiable information. The information that we request will be retained by us and used as described in this privacy policy.'),
            SizedBox(height: 8),
            Text('The app does use third party services that may collect information used to identify you.'),
            SizedBox(height: 8),
            Text('Link to privacy policy of third party service providers used by the app'),
            SizedBox(height: 18),
            Text('Log Data', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('We want to inform you that whenever you use our Service, in a case of an error in the app we collect data and information (through third party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol (\'IP\') address, device name, operating system version, the configuration of the app when utilizing our Service, the time and date of your use of the Service, and other statistics.'),
            SizedBox(height: 18),
            Text('Cookies', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Cookies are files with a small amount of data that are commonly used as anonymous unique identifiers.'),
          ],
        ),
      ),
    );
  }
} 