import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart' as u;


class NotificationsRepository {
  final String _boxName = 'notifications_box';

  /// Initialize Local Notifcations
  Future<NotificationsRepository> init() async {
    await Hive.openLazyBox(_notificationSwitchBox);
    await Hive.openLazyBox(_boxName);
    return NotificationsRepository();
  }


  /* <---- Notifications Settings -----> */
  final String _notificationSwitchBox = 'notificationSwitchBox';
  final String _toggle = 'notificationToggle';

  Future<bool> isNotificationOn() async {
    var box = await Hive.openLazyBox(_notificationSwitchBox);
    return await box.get(_toggle) ?? true;
  }

  /// Turn on notifications
  Future<void> turnOnNotifications() async {
    var box = await Hive.openLazyBox(_notificationSwitchBox);
    await box.put(_toggle, true);
  }

  /// Turn off notifications
  Future<void> turnOffNotifications() async {
    var box = await Hive.openLazyBox(_notificationSwitchBox);
    await box.put(_toggle, false);
  }
}

