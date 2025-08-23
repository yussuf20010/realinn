import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/custom_app_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import '../notifications/notifications_page.dart';
import '../settings/pages/customer_support_page.dart';

class HistoryPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'history'.tr(),
        showBackButton: false,
        onNotificationPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: CustomAppBar(
                title: 'notifications'.tr(),
                showBackButton: true,
                backAndLogoOnly: true,
              ),
              body: NotificationsPage(),
            ),
          ));
        },
      ),
      body: Center(
        child: Text('history_empty'.tr()),
      ),
    );
  }
}