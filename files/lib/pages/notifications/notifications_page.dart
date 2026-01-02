import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../config/constants/app_colors.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primary(context);
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: _buildCustomAppBar(context, primaryColor, isTablet),
      ),
      body: _buildMainContent(isTablet, primaryColor),
    );
  }

  Widget _buildCustomAppBar(
      BuildContext context, Color primaryColor, bool isTablet) {
    return Container(
      color: primaryColor,
      child: SafeArea(
        child: Container(
          height: 80,
          child: Row(
            children: [
              // Back button
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              // Title
              Expanded(
                child: Center(
                  child: Text(
                    'notifications'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 28 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Placeholder for symmetry
              SizedBox(width: 56),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isTablet, Color primaryColor) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'stay_updated'.tr(),
            style: TextStyle(
              fontSize: isTablet ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'latest_updates_offers'.tr(),
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: isTablet ? 32 : 24),

          // Notifications list
          _buildNotificationItem(
            icon: Icons.local_offer,
            title: 'special_offer'.tr(),
            message: 'get_20_percent_off'.tr(),
            time: '2 ${'hours_ago'.tr()}',
            isRead: false,
            isTablet: isTablet,
            primaryColor: primaryColor,
          ),
          SizedBox(height: 16),

          _buildNotificationItem(
            icon: Icons.flight_takeoff,
            title: 'booking_confirmed'.tr(),
            message: 'trip_cairo_confirmed'.tr(),
            time: '1 ${'day_ago'.tr()}',
            isRead: true,
            isTablet: isTablet,
            primaryColor: primaryColor,
          ),
          SizedBox(height: 16),

          _buildNotificationItem(
            icon: Icons.star,
            title: 'new_loyalty_points'.tr(),
            message: 'earned_150_points'.tr(),
            time: '2 ${'days_ago'.tr()}',
            isRead: true,
            isTablet: isTablet,
            primaryColor: primaryColor,
          ),
          SizedBox(height: 16),

          _buildNotificationItem(
            icon: Icons.location_on,
            title: 'new_destination'.tr(),
            message: 'explore_alexandria_hotels'.tr(),
            time: '3 ${'days_ago'.tr()}',
            isRead: true,
            isTablet: isTablet,
            primaryColor: primaryColor,
          ),
          SizedBox(height: 16),

          _buildNotificationItem(
            icon: Icons.payment,
            title: 'payment_successful'.tr(),
            message: 'payment_processed'.tr(),
            time: '1 ${'week_ago'.tr()}',
            isRead: true,
            isTablet: isTablet,
            primaryColor: primaryColor,
          ),
          SizedBox(height: 16),

          _buildNotificationItem(
            icon: Icons.support_agent,
            title: 'support_ticket'.tr(),
            message: 'support_request_resolved'.tr(),
            time: '1 ${'week_ago'.tr()}',
            isRead: true,
            isTablet: isTablet,
            primaryColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String message,
    required String time,
    required bool isRead,
    required bool isTablet,
    required Color primaryColor,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: isRead ? Colors.grey[50] : primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? Colors.grey[300]! : primaryColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isRead ? Colors.grey[200] : primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isRead ? Colors.grey[600] : Colors.white,
              size: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: isRead ? Colors.grey[700] : Colors.black,
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: isRead ? Colors.grey[600] : Colors.black87,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
