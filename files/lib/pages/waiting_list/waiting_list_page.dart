import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/wp_config.dart';
import '../../providers/waiting_list_provider.dart';
import '../../models/selected_room.dart';

class WaitingListPage extends ConsumerWidget {
  const WaitingListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = WPConfig.navbarColor;
    final isTablet = MediaQuery.of(context).size.width >= 768;
    final waitingList = ref.watch(waitingListProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.h),
        child: _buildCustomAppBar(context, primaryColor, isTablet, waitingList, ref),
      ),
      body: waitingList.isEmpty
          ? _buildEmptyState(primaryColor, isTablet)
          : _buildWaitingList(waitingList, primaryColor, isTablet, ref),
    );
  }

  Widget _buildCustomAppBar(BuildContext context, Color primaryColor, bool isTablet, List waitingList, WidgetRef ref) {
    return Container(
      color: primaryColor,
      child: SafeArea(
        child: Container(
          height: 80.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                // Title - Centered
                Expanded(
                  child: Center(
                    child: Text(
                      'waiting_list'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 24.sp : 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color primaryColor, bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 32.w : 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: isTablet ? 80.sp : 60.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: isTablet ? 24.h : 16.h),
            Text(
              'no_waiting_list_yet'.tr(),
              style: TextStyle(
                fontSize: isTablet ? 24.sp : 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: isTablet ? 12.h : 8.h),
            Text(
              'pending_bookings_will_appear'.tr(),
              style: TextStyle(
                fontSize: isTablet ? 16.sp : 14.sp,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingList(List waitingList, Color primaryColor, bool isTablet, WidgetRef ref) {
    // Filter for pending items only (waiting list)
    final pendingItems = waitingList.where((item) => 
      item.status == 'pending'
    ).toList();

    if (pendingItems.isEmpty) {
      return _buildEmptyState(primaryColor, isTablet);
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: pendingItems.length,
      itemBuilder: (context, index) {
        final item = pendingItems[index];
        return _buildWaitingListItem(item, primaryColor, isTablet, ref);
      },
    );
  }

  Widget _buildWaitingListItem(dynamic item, Color primaryColor, bool isTablet, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hotel image and info
          Container(
            height: 200.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
              image: DecorationImage(
                image: NetworkImage(item.hotel.imageUrl ?? 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=300&fit=crop'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // Status badge
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: _getStatusColor(item.status),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      _getStatusText(item.status),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Remove button
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: GestureDetector(
                    onTap: () => _removeItem(ref, item.id),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hotel name
                Text(
                  item.hotel.name ?? 'hotel_name'.tr(),
                  style: TextStyle(
                    fontSize: isTablet ? 18.sp : 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                // Room name
                Text(
                  item.room.name,
                  style: TextStyle(
                    fontSize: isTablet ? 16.sp : 14.sp,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 8.h),
                // Dates and quantity
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16.sp, color: Colors.grey[600]),
                    SizedBox(width: 8.w),
                    Text(
                      '${_formatDate(item.checkInDate)} - ${_formatDate(item.checkOutDate)}',
                      style: TextStyle(
                        fontSize: isTablet ? 14.sp : 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.bed, size: 16.sp, color: Colors.grey[600]),
                    SizedBox(width: 8.w),
                    Text(
                      '${item.quantity} ${'room_s'.tr()}',
                      style: TextStyle(
                        fontSize: isTablet ? 14.sp : 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Spacer(),
                    Text(
                      '\$${item.room.pricePerNight.toStringAsFixed(0)}${'per_night'.tr()}',
                      style: TextStyle(
                        fontSize: isTablet ? 16.sp : 14.sp,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateStatus(ref, item.id, 'confirmed'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.green),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'confirm'.tr(),
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateStatus(ref, item.id, 'cancelled'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'cancel'.tr(),
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _removeItem(WidgetRef ref, String id) {
    ref.read(waitingListProvider.notifier).removeFromWaitingList(id);
  }

  void _updateStatus(WidgetRef ref, String id, String status) {
    ref.read(waitingListProvider.notifier).updateStatus(id, status);
  }



  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'pending'.tr();
      case 'confirmed':
        return 'confirmed'.tr();
      case 'cancelled':
        return 'cancelled'.tr();
      default:
        return status.toUpperCase();
    }
  }

}
