import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/service_provider.dart';
import '../../../services/service_provider_service.dart';
import '../../../config/wp_config.dart';
import '../../../config/components/network_image.dart';
import '../../../models/hotel.dart';
import '../../../models/selected_room.dart';
import '../../../services/waiting_list_provider.dart';

class ProviderDetailsPage extends StatefulWidget {
  final int providerId;
  final int? categoryId;

  const ProviderDetailsPage({
    Key? key,
    required this.providerId,
    this.categoryId,
  }) : super(key: key);

  @override
  State<ProviderDetailsPage> createState() => _ProviderDetailsPageState();
}

class _ProviderDetailsPageState extends State<ProviderDetailsPage> {
  ServiceProvider? _provider;
  bool _isLoading = true;
  String? _error;
  bool _descExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadProvider();
  }

  Future<void> _loadProvider() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Always use service-based endpoint per API change
      final provider =
          await ServiceProviderService.fetchProviderDetailsByServiceId(
              widget.providerId);
      setState(() {
        _provider = provider;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: WPConfig.primaryColor),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'provider.error_loading_provider'.tr(),
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadProvider,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WPConfig.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('retry'.tr()),
                      ),
                    ],
                  ),
                )
              : _provider == null
                  ? Center(
                      child: Text(
                        'provider.not_found'.tr(),
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    )
                  : CustomScrollView(
                      slivers: [
                        _buildSliverAppBar(isTablet),
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileSection(isTablet),
                              if (_provider!.description != null &&
                                  _provider!.description!.isNotEmpty)
                                _buildDescriptionSection(isTablet),
                              _buildOverviewSection(isTablet),
                              _buildStatsSection(isTablet),
                              if (_provider!.skills != null &&
                                  _provider!.skills!.isNotEmpty)
                                _buildSkillsSection(isTablet),
                              _buildLocationSection(isTablet),
                              _buildBookingActions(isTablet),
                              SizedBox(height: 32.h),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildSliverAppBar(bool isTablet) {
    return SliverAppBar(
      expandedHeight: isTablet ? 180.h : 120.h,
      pinned: true,
      backgroundColor: WPConfig.primaryColor,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            _provider!.coverImage != null && _provider!.coverImage!.isNotEmpty
                ? NetworkImageWithLoader(
                    _provider!.coverImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          WPConfig.primaryColor,
                          WPConfig.primaryColor.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _provider!.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isTablet ? 20.sp : 18.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_provider!.rating > 0) ...[
                                    Icon(Icons.star,
                                        color: Colors.amber, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      _provider!.rating.toStringAsFixed(1),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    SizedBox(width: 8),
                                  ],
                                  if (_provider!.isVerified) ...[
                                    Icon(Icons.verified,
                                        color: Colors.lightBlueAccent,
                                        size: 16),
                                    SizedBox(width: 4),
                                    Text('provider.verified'.tr(),
                                        style: TextStyle(color: Colors.white)),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (_provider!.availableForWork)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.greenAccent.withOpacity(0.6)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.work_outline_rounded,
                                    color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text('provider.available'.tr(),
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(bool isTablet) {
    return Container(
      margin: EdgeInsets.all(isTablet ? 20.w : 16.w),
      padding: EdgeInsets.all(isTablet ? 24.w : 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Image
          Container(
            width: isTablet ? 120.w : 100.w,
            height: isTablet ? 80.w : 70.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: WPConfig.primaryColor, width: 4),
              color: Colors.grey[300],
            ),
            clipBehavior: Clip.antiAlias,
            child: _provider!.imageUrl.isNotEmpty
                ? NetworkImageWithLoader(
                    _provider!.imageUrl,
                    fit: BoxFit.cover,
                    width: isTablet ? 120.w : 100.w,
                    height: isTablet ? 80.w : 70.w,
                  )
                : Icon(Icons.person, size: 50, color: Colors.grey[600]),
          ), // Name and Verified Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _provider!.name,
                style: TextStyle(
                  fontSize: isTablet ? 28.sp : 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (_provider!.isVerified) ...[
                SizedBox(width: 8.w),
                Icon(Icons.verified, color: Colors.blue, size: 28),
              ],
            ],
          ),
          if (_provider!.tagline != null && _provider!.tagline!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              _provider!.tagline!,
              style: TextStyle(
                fontSize: isTablet ? 16.sp : 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
          SizedBox(height: 16.h),
          // Quick badges
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            alignment: WrapAlignment.center,
            children: [
              if (_provider!.availableForWork)
                _buildChip(
                  icon: Icons.work_outline_rounded,
                  label: 'provider.available'.tr(),
                  color: Colors.green,
                  isTablet: isTablet,
                ),
              if (_provider!.responseRate > 0)
                _buildChip(
                  icon: Icons.reply_rounded,
                  label:
                      '${_provider!.responseRate.toStringAsFixed(0)}% ${'provider.response'.tr()}',
                  color: Colors.blue,
                  isTablet: isTablet,
                ),
              if (_provider!.onTimeDeliveryRate > 0)
                _buildChip(
                  icon: Icons.schedule_rounded,
                  label:
                      '${_provider!.onTimeDeliveryRate.toStringAsFixed(0)}% ${'provider.on_time'.tr()}',
                  color: Colors.teal,
                  isTablet: isTablet,
                ),
              _buildChip(
                icon: Icons.check_circle_rounded,
                label:
                    '${_provider!.completedOrders} ${'provider.orders'.tr()}',
                color: Colors.green,
                isTablet: isTablet,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Category Badge
          if (_provider!.mainCategory != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: WPConfig.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                _provider!.mainCategory!.name,
                style: TextStyle(
                  fontSize: isTablet ? 14.sp : 12.sp,
                  color: WPConfig.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 20.w : 16.w),
      padding: EdgeInsets.all(isTablet ? 24.w : 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'provider.overview'.tr(),
            style: TextStyle(
              fontSize: isTablet ? 20.sp : 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          // Price Range
          _buildInfoRow(
            icon: Icons.attach_money,
            label: 'provider.price_range'.tr(),
            value:
                '${_provider!.currency} ${_provider!.minPrice}${_provider!.maxPrice > _provider!.minPrice ? ' - ${_provider!.maxPrice}' : ''}',
            isTablet: isTablet,
          ),
          Divider(height: 24.h),
          // Availability
          _buildInfoRow(
            icon:
                _provider!.availableForWork ? Icons.check_circle : Icons.cancel,
            label: 'provider.availability'.tr(),
            value: _provider!.availableForWork
                ? 'provider.available_for_work'.tr()
                : 'provider.not_available'.tr(),
            isTablet: isTablet,
            iconColor: _provider!.availableForWork ? Colors.green : Colors.red,
          ),
          Divider(height: 24.h),
          // Status
          _buildInfoRow(
            icon: Icons.info_outline,
            label: 'provider.status'.tr(),
            value: _provider!.status.toUpperCase(),
            isTablet: isTablet,
          ),
          if (_provider!.joinedAt != null &&
              _provider!.joinedAt!.isNotEmpty) ...[
            Divider(height: 24.h),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'provider.joined'.tr(),
              value: _formatDate(_provider!.joinedAt!),
              isTablet: isTablet,
              iconColor: Colors.purple,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isTablet) {
    return Container(
      margin: EdgeInsets.all(isTablet ? 20.w : 16.w),
      padding: EdgeInsets.all(isTablet ? 24.w : 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'provider.statistics'.tr(),
            style: TextStyle(
              fontSize: isTablet ? 20.sp : 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.star,
                  label: 'provider.rating'.tr(),
                  value: (_provider!.rating).toStringAsFixed(1),
                  color: Colors.amber,
                  isTablet: isTablet,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.reviews,
                  label: 'provider.reviews'.tr(),
                  value: '${_provider!.reviewCount}',
                  color: Colors.blue,
                  isTablet: isTablet,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle,
                  label: 'provider.completed_orders'.tr(),
                  value: '${_provider!.completedOrders}',
                  color: Colors.green,
                  isTablet: isTablet,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.timer,
                  label: 'provider.response_rate'.tr(),
                  value: '${_provider!.responseRate.toStringAsFixed(0)}%',
                  color: Colors.orange,
                  isTablet: isTablet,
                ),
              ),
            ],
          ),
          if (_provider!.onTimeDeliveryRate > 0) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.local_shipping,
                    label: 'provider.on_time_delivery'.tr(),
                    value:
                        '${_provider!.onTimeDeliveryRate.toStringAsFixed(0)}%',
                    color: Colors.purple,
                    isTablet: isTablet,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isTablet,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.12), color.withOpacity(0.06)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 18.w : 16.w),
        child: Column(
          children: [
            Icon(icon, color: color, size: isTablet ? 28.sp : 24.sp),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 18.sp : 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 12.sp : 10.sp,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(bool isTablet) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 16.h),
      padding: EdgeInsets.all(isTablet ? 24.w : 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textStyle = TextStyle(
            fontSize: isTablet ? 16.sp : 14.sp,
            color: Colors.grey[700],
            height: 1.6,
          );
          final span =
              TextSpan(text: _provider!.description!, style: textStyle);
          final tp = TextPainter(
            text: span,
            maxLines: 5,
            ellipsis: '…',
            textDirection: Directionality.of(context),
          );
          tp.layout(maxWidth: constraints.maxWidth);
          final isOverflowing = tp.didExceedMaxLines;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'provider.about'.tr(),
                style: TextStyle(
                  fontSize: isTablet ? 20.sp : 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                _provider!.description!,
                maxLines: _descExpanded ? null : 5,
                overflow: _descExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: textStyle,
              ),
              if (isOverflowing) ...[
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () =>
                        setState(() => _descExpanded = !_descExpanded),
                    child: Text(_descExpanded
                        ? 'provider.show_less'.tr()
                        : 'provider.read_more'.tr()),
                    style: TextButton.styleFrom(
                      foregroundColor: WPConfig.primaryColor,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSkillsSection(bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 20.w : 16.w),
      padding: EdgeInsets.all(isTablet ? 24.w : 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'provider.skills'.tr(),
            style: TextStyle(
              fontSize: isTablet ? 20.sp : 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _provider!.skills!
                .split(',')
                .map((skill) => Chip(
                      label: Text(
                        skill.trim(),
                        style: TextStyle(fontSize: isTablet ? 14.sp : 12.sp),
                      ),
                      backgroundColor: WPConfig.primaryColor.withOpacity(0.1),
                      labelStyle: TextStyle(color: WPConfig.primaryColor),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(bool isTablet) {
    if (_provider!.city == null &&
        _provider!.country == null &&
        _provider!.latitude == null &&
        _provider!.longitude == null) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 20.w : 16.w),
      padding: EdgeInsets.all(isTablet ? 24.w : 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'location'.tr(),
            style: TextStyle(
              fontSize: isTablet ? 20.sp : 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          if (_provider!.city != null || _provider!.country != null)
            _buildInfoRow(
              icon: Icons.location_on,
              label: 'address'.tr(),
              value:
                  '${_provider!.city ?? ''}${_provider!.city != null && _provider!.country != null ? ', ' : ''}${_provider!.country ?? ''}',
              isTablet: isTablet,
              iconColor: Colors.red,
            ),
          if (_provider!.latitude != null && _provider!.longitude != null) ...[
            SizedBox(height: 12.h),
            _buildInfoRow(
              icon: Icons.map,
              label: 'coordinates'.tr(),
              value:
                  'Lat: ${_provider!.latitude!.toStringAsFixed(6)}, Lng: ${_provider!.longitude!.toStringAsFixed(6)}',
              isTablet: isTablet,
              iconColor: Colors.blue,
            ),
          ],
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _openMaps,
              icon:
                  Icon(Icons.directions_outlined, color: WPConfig.primaryColor),
              label: Text('open_in_maps'.tr(),
                  style: TextStyle(color: WPConfig.primaryColor)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: WPConfig.primaryColor.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isTablet,
    Color? iconColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor ?? WPConfig.primaryColor,
          size: isTablet ? 24.sp : 20.sp,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isTablet ? 12.sp : 10.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: isTablet ? 16.sp : 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
    required bool isTablet,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: isTablet ? 16 : 14),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 12.sp : 11.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingActions(bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: isTablet ? 20.w : 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: _bookNow,
            style: ElevatedButton.styleFrom(
              backgroundColor: WPConfig.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: isTablet ? 14.h : 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text('book_now'.tr()),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      final m = months[dt.month - 1];
      return '$m ${dt.day}, ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  Future<void> _openMaps() async {
    final hasCoords =
        _provider!.latitude != null && _provider!.longitude != null;
    final uri = hasCoords
        ? Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${_provider!.latitude},${_provider!.longitude}')
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('${_provider!.city ?? ''} ${_provider!.country ?? ''}')}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('could_not_open_maps'.tr())),
      );
    }
  }

  void _bookNow() {
    _joinWaitingList();
  }

  void _joinWaitingList() {
    try {
      // Create a minimal hotel-like entry for the waiting list using provider data
      final image = _provider!.imageUrl.isNotEmpty
          ? _provider!.imageUrl
          : (_provider!.coverImage ?? '');

      final hotel = Hotel(
        id: _provider!.id,
        name: _provider!.name,
        imageUrl: image.isNotEmpty ? image : null,
        location: (_provider!.city != null || _provider!.country != null)
            ? '${_provider!.city ?? ''}${_provider!.city != null && _provider!.country != null ? ', ' : ''}${_provider!.country ?? ''}'
            : null,
      );

      final room = SelectedRoom(
        name:
            _provider!.mainCategory?.name ?? 'provider.service_providers'.tr(),
        pricePerNight: _provider!.minPrice > 0 ? _provider!.minPrice : 0,
        maxAdults: 1,
        maxChildren: 0,
        imageUrl: image.isNotEmpty
            ? image
            : 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=300&fit=crop',
        amenities: (_provider!.skills ?? '') 
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
      );

      final container = ProviderScope.containerOf(context);
      container.read(waitingListProvider.notifier).addToWaitingList(
            hotel: hotel,
            room: room,
            checkInDate: DateTime.now(),
            checkOutDate: DateTime.now().add(const Duration(days: 1)),
            quantity: 1,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('waiting_list'.tr())),
      );
      Navigator.pushNamed(context, '/waiting-list');
    } catch (_) {
      Navigator.pushNamed(context, '/waiting-list');
    }
  }
}
