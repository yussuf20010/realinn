import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../config/dynamic_config.dart';

class TabletSearchCard extends ConsumerWidget {
  final VoidCallback onDailyBookingTap;
  final VoidCallback onMonthlyBookingTap;

  const TabletSearchCard({
    Key? key,
    required this.onDailyBookingTap,
    required this.onMonthlyBookingTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final primaryColor = dynamicConfig.primaryColor;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            // Destination field
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey.shade600, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Madrid City Center',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Dates field
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fri, Nov 10 - Sun, Nov 12',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Guests/Rooms field
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.grey.shade600, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '1 room · 1 adult · 0 children',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 12),
            
            // Search button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDailyBookingTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 