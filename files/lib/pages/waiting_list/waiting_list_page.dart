import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/wp_config.dart';
import '../../services/waiting_list_provider.dart';
import '../../services/bookings_service.dart';
import '../../config/constants/assets.dart';

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
        child: _buildCustomAppBar(
            context, primaryColor, isTablet, waitingList, ref),
      ),
      body: waitingList.isEmpty
          ? _buildEmptyState(primaryColor, isTablet)
          : _buildWaitingList(waitingList, primaryColor, isTablet, ref),
    );
  }

  Widget _buildCustomAppBar(BuildContext context, Color primaryColor,
      bool isTablet, List waitingList, WidgetRef ref) {
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
            SvgPicture.asset(
              AssetsManager.pin_hotel,
              width: isTablet ? 80.w : 60.w,
              height: isTablet ? 80.h : 60.h,
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

  Widget _buildWaitingList(
      List waitingList, Color primaryColor, bool isTablet, WidgetRef ref) {
    // Filter for pending items only (waiting list)
    final pendingItems =
        waitingList.where((item) => item.status == 'pending').toList();

    if (pendingItems.isEmpty) {
      return _buildEmptyState(primaryColor, isTablet);
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: pendingItems.length,
      itemBuilder: (context, index) {
        final item = pendingItems[index];
        return _buildWaitingListItem(
            context, item, primaryColor, isTablet, ref);
      },
    );
  }

  Widget _buildWaitingListItem(BuildContext context, dynamic item,
      Color primaryColor, bool isTablet, WidgetRef ref) {
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
                // Coupon section
                _buildCouponSection(context, item, isTablet),
                SizedBox(height: 16.h),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _confirmBooking(context, ref, item),
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
                        onPressed: () =>
                            _updateStatus(context, ref, item.id, 'cancelled'),
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

  Widget _buildCouponSection(
      BuildContext context, dynamic item, bool isTablet) {
    return _CouponSectionWidget(item: item, isTablet: isTablet);
  }
}

class _CouponSectionWidget extends StatefulWidget {
  final dynamic item;
  final bool isTablet;

  const _CouponSectionWidget({
    required this.item,
    required this.isTablet,
  });

  @override
  State<_CouponSectionWidget> createState() => _CouponSectionWidgetState();
}

class _CouponSectionWidgetState extends State<_CouponSectionWidget> {
  final TextEditingController _couponController = TextEditingController();
  Map<String, dynamic>? _couponData;
  bool _isApplyingCoupon = false;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon() async {
    final couponCode = _couponController.text.trim();
    if (couponCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a coupon code')),
      );
      return;
    }

    setState(() {
      _isApplyingCoupon = true;
    });

    try {
      // Get room ID from item (you may need to adjust this based on your model)
      final roomId = 1; // TODO: Get actual room ID from item
      final checkIn = widget.item.checkInDate.toString().split(' ')[0];
      final checkOut = widget.item.checkOutDate.toString().split(' ')[0];

      final result = await BookingsService.applyCoupon(
        roomId: roomId,
        couponCode: couponCode,
        checkIn: checkIn,
        checkOut: checkOut,
      );

      setState(() {
        _couponData = result;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Coupon applied! Discount: \$${result['discount'] ?? 0}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isApplyingCoupon = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Coupon Code',
          style: TextStyle(
            fontSize: widget.isTablet ? 14.sp : 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _couponController,
                decoration: InputDecoration(
                  hintText: 'Enter coupon code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            ElevatedButton(
              onPressed: _isApplyingCoupon ? null : _applyCoupon,
              style: ElevatedButton.styleFrom(
                backgroundColor: WPConfig.navbarColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: _isApplyingCoupon
                  ? SizedBox(
                      width: 16.w,
                      height: 16.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('Apply'),
            ),
          ],
        ),
        if (_couponData != null) ...[
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coupon Applied!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Original: \$${_couponData!['original_price'] ?? 0}',
                  style: TextStyle(fontSize: 12.sp),
                ),
                Text(
                  'Discount: \$${_couponData!['discount'] ?? 0}',
                  style:
                      TextStyle(fontSize: 12.sp, color: Colors.green.shade700),
                ),
                Text(
                  'Final: \$${_couponData!['final_price'] ?? 0}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

extension WaitingListPageExtension on WaitingListPage {
  Future<void> _confirmBooking(
      BuildContext context, WidgetRef ref, dynamic item) async {
    try {
      // Get room ID from item (you may need to adjust this based on your model)
      final roomId = 1; // TODO: Get actual room ID from item
      final checkIn = item.checkInDate.toString().split(' ')[0];
      final checkOut = item.checkOutDate.toString().split(' ')[0];
      final guests = 2; // TODO: Get actual guests count
      final paymentMethod = 'paypal'; // TODO: Get from user selection

      final result = await BookingsService.createBooking(
        roomId: roomId,
        checkIn: checkIn,
        checkOut: checkOut,
        guests: guests,
        paymentMethod: paymentMethod,
        couponCode: null, // TODO: Get from coupon section if applied
      );

      // Update status and navigate
      ref.read(waitingListProvider.notifier).updateStatus(item.id, 'confirmed');

      if (result['payment_required'] == true) {
        // Navigate to payment page if needed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment required. Redirecting...')),
        );
      } else {
        Navigator.pushNamed(context, '/history');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateStatus(
      BuildContext context, WidgetRef ref, String id, String status) {
    ref.read(waitingListProvider.notifier).updateStatus(id, status);
    if (status == 'confirmed') {
      // Navigate to history after confirming
      Navigator.pushNamed(context, '/history');
    }
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
