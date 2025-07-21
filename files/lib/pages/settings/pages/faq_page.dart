import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': 'Do I have to buy the Mobile App?',
        'a': 'No. Our Mobile App is completely free to download and install.'
      },
      {
        'q': 'How do I get the Mobile App for my phone?',
        'a': 'You can download it from the App Store or Google Play Store.'
      },
      {
        'q': 'What features does the Mobile App have?',
        'a': 'Room booking, car booking, car washing, profile management, and more.'
      },
      {
        'q': 'Is the Mobile App secure?',
        'a': 'Yes, we use industry-standard security practices to protect your data.'
      },
      {
        'q': 'How current is the account information ...',
        'a': 'Account information is updated in real-time as you use the app.'
      },
      {
        'q': 'How do I find your offices and payment locations?',
        'a': 'You can find this information in the About or Contact section of the app.'
      },
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faq', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              title: Text(faq['q']!),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(faq['a']!),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 