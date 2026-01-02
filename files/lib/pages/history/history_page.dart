import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/constants/app_colors.dart';
import '../../services/waiting_list_provider.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = AppColors.primary(context);
    final isTablet = MediaQuery.of(context).size.width >= 768;
    final waitingList = ref.watch(waitingListProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.h),
        child: _buildCustomAppBar(context, primaryColor, isTablet, ref),
      ),
      body: waitingList.isEmpty
          ? _buildEmptyState(primaryColor, isTablet)
          : _buildHistoryList(waitingList, primaryColor, isTablet, ref),
    );
  }

  Widget _buildCustomAppBar(
      BuildContext context, Color primaryColor, bool isTablet, WidgetRef ref) {
    final waitingList = ref.watch(waitingListProvider);

    return Container(
      color: primaryColor,
      child: SafeArea(
        child: Container(
          height: 80.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              // Title
              Expanded(
                child: Center(
                  child: Text(
                    'history'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 24.sp : 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Clear all button
              if (waitingList.isNotEmpty)
                TextButton(
                  onPressed: () => _showClearAllDialog(context, ref),
                  child: Text(
                    'clear_all'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 16.sp : 14.sp,
                      fontWeight: FontWeight.bold,
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
              Icons.history,
              size: isTablet ? 80.sp : 60.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: isTablet ? 24.h : 16.h),
            Text(
              'no_history_yet'.tr(),
              style: TextStyle(
                fontSize: isTablet ? 24.sp : 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: isTablet ? 12.h : 8.h),
            Text(
              'completed_past_bookings'.tr(),
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

  Widget _buildHistoryList(
      List waitingList, Color primaryColor, bool isTablet, WidgetRef ref) {
    // Filter for completed and cancelled items (history)
    final historyItems = waitingList
        .where(
            (item) => item.status == 'confirmed' || item.status == 'cancelled')
        .toList();

    if (historyItems.isEmpty) {
      return _buildEmptyState(primaryColor, isTablet);
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: historyItems.length,
      itemBuilder: (context, index) {
        final item = historyItems[index];
        return _buildHistoryItem(item, primaryColor, isTablet, ref);
      },
    );
  }

  Widget _buildHistoryItem(
      dynamic item, Color primaryColor, bool isTablet, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
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
                image: NetworkImage(item.hotel.imageUrl ??
                    'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=300&fit=crop'),
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
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
                // Date badge
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      _formatDate(item.addedAt),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
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
                  item.hotel.name ?? 'Hotel Name',
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
                    Icon(Icons.calendar_today,
                        size: 16.sp, color: Colors.grey[600]),
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
                      '${item.quantity} room(s)',
                      style: TextStyle(
                        fontSize: isTablet ? 14.sp : 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Spacer(),
                    Text(
                      '\$${item.room.pricePerNight.toStringAsFixed(0)}/night',
                      style: TextStyle(
                        fontSize: isTablet ? 16.sp : 14.sp,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
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

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'confirmed'.tr();
      case 'cancelled':
        return 'cancelled'.tr();
      default:
        return 'pending'.tr();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showBookingDetails(dynamic item) {
    // Show booking details dialog
    // This would show receipt, booking reference, etc.
  }

  void _rebookItem(dynamic item, WidgetRef ref) {
    // Add item back to waiting list for rebooking
    ref.read(waitingListProvider.notifier).addToWaitingList(
          hotel: item.hotel,
          room: item.room,
          checkInDate: item.checkInDate,
          checkOutDate: item.checkOutDate,
          quantity: item.quantity,
        );
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('clear_all_items'.tr()),
        content: Text('are_you_sure_clear_all'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(waitingListProvider.notifier).clearWaitingList();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                Text('clear_all'.tr(), style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
