import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../config/dynamic_config.dart';

class MobileSearchCard extends ConsumerWidget {
  final VoidCallback onDailyBookingTap;
  final VoidCallback onMonthlyBookingTap;

  const MobileSearchCard({
    Key? key,
    required this.onDailyBookingTap,
    required this.onMonthlyBookingTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final primaryColor = dynamicConfig.primaryColor ?? Color(0xFF895ffc);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Destination field
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Madrid City Center',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Dates field
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Fri, Nov 10 - Sun, Nov 12',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Guests/Rooms field
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.grey.shade600, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '1 room · 1 adult · 0 children',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Search button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDailyBookingTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 16,
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