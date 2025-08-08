import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/dynamic_config.dart';
import '../../../config/wp_config.dart';
import 'package:easy_localization/easy_localization.dart';

class BookingTypeSelector extends ConsumerWidget {
  final VoidCallback onDailyBookingTap;
  final VoidCallback onMonthlyBookingTap;

  const BookingTypeSelector({
    Key? key,
    required this.onDailyBookingTap,
    required this.onMonthlyBookingTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = WPConfig.navbarColor; // Use constant color directly

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onDailyBookingTap,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'daily_booking'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onMonthlyBookingTap,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'monthly_booking'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

