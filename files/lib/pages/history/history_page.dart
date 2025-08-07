import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/custom_app_bar.dart';
import '../notifications/notifications_page.dart';
import '../settings/pages/customer_support_page.dart';

class HistoryPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'History',
        showBackButton: true,
        onNotificationPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NotificationsPage()),
          );
        },
        onProfilePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerSupportPage(),
            ),
          );
        },
      ),
      body: Center(
        child: Text('Your history will appear here.'),
      ),
    );
  }
}