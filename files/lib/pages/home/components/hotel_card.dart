import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/dynamic_config.dart';
import '../../../../services/favorites_provider.dart';
import '../../../models/hotel.dart';

class HotelCard extends ConsumerWidget {
  final Hotel hotel;
  final CityModel? city;
  final CountryModel? country;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;

  const HotelCard({
    Key? key,
    required this.hotel,
    this.city,
    this.country,
    this.onFavoriteTap,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final primaryColor = dynamicConfig.primaryColor;
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _navigateToHotelDetails(context),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: 0, vertical: isTablet ? 12 : 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 40,
                          offset: Offset(0, 16),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ClipRect(
                      child: isTablet
                          ? _buildTabletLayout(primaryColor, isTablet, context)
                          : _buildMobileLayout(primaryColor, isTablet, context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(
      Color primaryColor, bool isTablet, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hotel Image Section (Left - 40% width)
        Expanded(
          flex: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: AspectRatio(
              aspectRatio: 1.2,
              child: _buildHotelImage(),
            ),
          ),
        ),

        // Hotel Details Section (Right - 60% width)
        Expanded(
          flex: 6,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and favorite button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hotel.name ?? 'Hotel Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (city?.name != null)
                            Text(
                              '- ${city!.name}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        final favorites = ref.watch(favoritesProvider);
                        final isFavorite =
                            favorites.any((h) => h.id == hotel.id);
                        return GestureDetector(
                          onTap: () {
                            ref
                                .read(favoritesProvider.notifier)
                                .toggleFavorite(hotel, context);
                          },
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 200),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              key: ValueKey(isFavorite),
                              color: isFavorite ? Colors.red : Colors.blue[400],
                              size: 20.sp,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                // Rating Section (Compact for mobile)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    // Stars
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        if (index < (hotel.rate ?? 0).floor()) {
                          return Icon(Icons.star,
                              color: Colors.amber, size: 14.sp);
                        } else if (index == (hotel.rate ?? 0).floor() &&
                            (hotel.rate ?? 0) % 1 > 0) {
                          return Icon(Icons.star_half,
                              color: Colors.amber, size: 14.sp);
                        } else {
                          return Icon(Icons.star_border,
                              color: Colors.amber, size: 14.sp);
                        }
                      }),
                    ),
                  ],
                ),

                SizedBox(height: 6.h),

                // Review Score (Compact)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${hotel.rate?.toStringAsFixed(1) ?? "N/A"}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                    Text(
                      _getRatingText(hotel.rate),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      hotel.reviews != null && hotel.reviews!.isNotEmpty
                          ? ' · ${hotel.reviews!.length} reviews'
                          : '',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                // Location Details (Compact)
                if (hotel.latitude != null && hotel.longitude != null) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on,
                          color: Colors.blue[600], size: 12.sp),
                      SizedBox(width: 2.w),
                      Flexible(
                        child: Text(
                          '${_calculateDistance(hotel.latitude!, hotel.longitude!)} km from downtown',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.beach_access,
                          color: Colors.blue[600], size: 12.sp),
                      SizedBox(width: 2.w),
                      Flexible(
                        child: Text(
                          '${_calculateBeachDistance(hotel.latitude!, hotel.longitude!)} m from beach',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                ],

                // Room Type
                Text(
                  'Hotel room: ${_getBedInfo()}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 8.h),

                // Pricing Section (Compact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            'US\$${hotel.oldPrice ?? hotel.priceRange ?? "0"}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.red,
                              decoration: TextDecoration.lineThrough,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            'US\$${hotel.priceRange ?? "0"}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '+US\$${_calculateTaxes(hotel.priceRange)} taxes and fees',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),

                SizedBox(height: 6.h),

                // Availability removed - use API data only
                GestureDetector(
                  onTap: () => _navigateToHotelDetails(context),
                  child: Text(
                    'RealN',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(
      Color primaryColor, bool isTablet, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hotel Image Section (Full width for tablet)
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          child: AspectRatio(
            aspectRatio: 2.5,
            child: _buildHotelImage(),
          ),
        ),

        // Hotel Details Section (Below image for tablet)
        Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and favorite button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hotel.name ?? 'Hotel Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24.sp,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (city?.name != null)
                          Text(
                            '- ${city!.name}',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final isFavorite = ref
                          .watch(favoritesProvider.notifier)
                          .isFavorite(hotel);
                      return GestureDetector(
                        onTap: () {
                          ref
                              .read(favoritesProvider.notifier)
                              .toggleFavorite(hotel, context);
                        },
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            key: ValueKey(isFavorite),
                            color: isFavorite ? Colors.red : Colors.blue[400],
                            size: 28.sp,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Rating Section (Expanded for tablet)
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  // Stars
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      if (index < (hotel.rate ?? 0).floor()) {
                        return Icon(Icons.star, color: Colors.amber, size: 20);
                      } else if (index == (hotel.rate ?? 0).floor() &&
                          (hotel.rate ?? 0) % 1 > 0) {
                        return Icon(Icons.star_half,
                            color: Colors.amber, size: 20);
                      } else {
                        return Icon(Icons.star_border,
                            color: Colors.amber, size: 20);
                      }
                    }),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Review Score (Expanded)
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      '${hotel.rate?.toStringAsFixed(1) ?? "N/A"}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  Text(
                    _getRatingText(hotel.rate),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  hotel.reviews != null && hotel.reviews!.isNotEmpty
                      ? Text(
                          ' · ${hotel.reviews!.length} reviews',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        )
                      : SizedBox.shrink(),
                ],
              ),

              SizedBox(height: 20),

              // Location Details (Expanded)
              if (hotel.latitude != null && hotel.longitude != null) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, color: Colors.blue[600], size: 20),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        '${_calculateDistance(hotel.latitude!, hotel.longitude!)} km from downtown',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.beach_access, color: Colors.blue[600], size: 20),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        '${_calculateBeachDistance(hotel.latitude!, hotel.longitude!)} m from beach',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
              ],

              // Room Type
              Text(
                'Hotel room: ${_getBedInfo()}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 20),

              // Pricing Section (Expanded)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'US\$${hotel.oldPrice ?? hotel.priceRange ?? "0"}',
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.red,
                            decoration: TextDecoration.lineThrough,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Flexible(
                        child: Text(
                          'US\$${hotel.priceRange ?? "0"}',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '+US\$${_calculateTaxes(hotel.priceRange)} taxes and fees',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Availability removed - use API data only
              GestureDetector(
                onTap: () => _navigateToHotelDetails(context),
                child: Text(
                  'RealN',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHotelImage() {
    // Use API images only - no fallbacks
    String? imageUrl;

    // Try hotel.images first (list)
    if (hotel.images != null && hotel.images!.isNotEmpty) {
      imageUrl = hotel.images!.first;
    }
    // Then try hotel.imageUrl (single image)
    else if (hotel.imageUrl != null && hotel.imageUrl!.isNotEmpty) {
      imageUrl = hotel.imageUrl;
    }

    // If no API image available, show placeholder
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildPlaceholderImage();
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildPlaceholderImage();
          },
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: Duration(milliseconds: 300),
              child: child,
            );
          },
        ),
      ),
    );
  }

  // Removed _getHotelCategoryImage - no fallback to Unsplash images

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[50]!,
            Colors.blue[100]!,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(50.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.hotel,
                color: Colors.blue[600],
                size: 32,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                hotel.name?.split(' ').take(2).join(' ') ?? 'Hotel',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(double? rating) {
    if (rating == null) return 'N/A';
    if (rating >= 9.0) return 'Exceptional';
    if (rating >= 8.0) return 'Excellent';
    if (rating >= 7.0) return 'Very Good';
    if (rating >= 6.0) return 'Good';
    if (rating >= 5.0) return 'Average';
    return 'Below Average';
  }

  String _getBedInfo() {
    // This should come from your dynamic data
    return '1 bed';
  }

  double _calculateDistance(double lat, double lng) {
    // This should calculate actual distance from your data
    // Placeholder calculation - replace with actual logic
    return ((lat * 100) % 10).roundToDouble();
  }

  double _calculateBeachDistance(double lat, double lng) {
    // This should calculate actual beach distance from your data
    // Placeholder calculation - replace with actual logic
    return ((lng * 1000) % 2000).roundToDouble();
  }

  double _calculateTaxes(String? price) {
    if (price == null) return 0.0;
    final basePrice = double.tryParse(price) ?? 0.0;
    return (basePrice * 0.15).roundToDouble(); // 15% taxes
  }

  // Removed _getRandomAvailability - static/mock data

  // Removed _getReviewCount - use hotel.reviews?.length ?? 0 instead

  void _navigateToHotelDetails(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/hotel-details',
      arguments: {
        'hotel': hotel,
        'checkInDate': null,
        'checkOutDate': null,
        'rooms': null,
      },
    );
  }
}

class HotelCardModern extends ConsumerWidget {
  final Hotel hotel;
  final int bookingType; // 0: daily, 1: monthly

  const HotelCardModern({
    Key? key,
    required this.hotel,
    required this.bookingType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final primaryColor = dynamicConfig.primaryColor;
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _navigateToHotelDetails(context),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: 0, vertical: isTablet ? 12 : 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color:
                              primaryColor.withOpacity(isTablet ? 0.15 : 0.1),
                          blurRadius: isTablet ? 16 : 12,
                          offset: Offset(0, isTablet ? 6 : 4),
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: isTablet
                          ? _buildTabletLayout(primaryColor, isTablet, context)
                          : _buildMobileLayout(primaryColor, isTablet, context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(
      Color primaryColor, bool isTablet, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hotel Image Section (Left - 40% width)
        Expanded(
          flex: 4,
          child: AspectRatio(
            aspectRatio: 1.2,
            child: _buildHotelImage(),
          ),
        ),

        // Hotel Details Section (Right - 60% width)
        Expanded(
          flex: 6,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and booking type indicator
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        hotel.name ?? 'Hotel Name',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: bookingType == 0 ? Colors.blue : Colors.green,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        bookingType == 0 ? 'Daily' : 'Monthly',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                // Location
                if (hotel.city != null || hotel.country != null)
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 14, color: Colors.grey[600]),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          '${hotel.city ?? ''}${hotel.city != null && hotel.country != null ? ', ' : ''}${hotel.country ?? ''}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                SizedBox(height: 8.h),

                // Rating
                if (hotel.rate != null)
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber),
                      SizedBox(width: 4.w),
                      Text(
                        hotel.rate.toString(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _getRatingText(hotel.rate),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                SizedBox(height: 8.h),

                // Price
                if (hotel.priceRange != null)
                  Row(
                    children: [
                      Text(
                        '\$${hotel.priceRange}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        bookingType == 0 ? '/night' : '/month',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(
      Color primaryColor, bool isTablet, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hotel Image Section (Left - 35% width)
        Expanded(
          flex: 35,
          child: AspectRatio(
            aspectRatio: 1.3,
            child: _buildHotelImage(),
          ),
        ),

        // Hotel Details Section (Right - 65% width)
        Expanded(
          flex: 65,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and booking type indicator
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        hotel.name ?? 'Hotel Name',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: bookingType == 0 ? Colors.blue : Colors.green,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        bookingType == 0 ? 'Daily' : 'Monthly',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Location
                if (hotel.city != null || hotel.country != null)
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: Colors.grey[600]),
                      SizedBox(width: 6.w),
                      Text(
                        '${hotel.city ?? ''}${hotel.city != null && hotel.country != null ? ', ' : ''}${hotel.country ?? ''}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                SizedBox(height: 12.h),

                // Rating and additional info
                Row(
                  children: [
                    if (hotel.rate != null) ...[
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      SizedBox(width: 6.w),
                      Text(
                        hotel.rate.toString(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        _getRatingText(hotel.rate),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),

                SizedBox(height: 12.h),

                // Price
                if (hotel.priceRange != null)
                  Row(
                    children: [
                      Text(
                        '\$${hotel.priceRange}',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        bookingType == 0 ? '/night' : '/month',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHotelImage() {
    // Use API images only - no fallbacks
    String? imageUrl;

    // Try hotel.images first (list)
    if (hotel.images != null && hotel.images!.isNotEmpty) {
      imageUrl = hotel.images!.first;
    }
    // Then try hotel.imageUrl (single image)
    else if (hotel.imageUrl != null && hotel.imageUrl!.isNotEmpty) {
      imageUrl = hotel.imageUrl;
    }

    // If no API image available, show placeholder
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildPlaceholderImage();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholderImage();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildPlaceholderImage();
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.hotel,
          size: 32,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  String _getRatingText(double? rating) {
    if (rating == null) return 'N/A';
    if (rating >= 9.0) return 'Exceptional';
    if (rating >= 8.0) return 'Excellent';
    if (rating >= 7.0) return 'Very Good';
    if (rating >= 6.0) return 'Good';
    if (rating >= 5.0) return 'Average';
    return 'Below Average';
  }

  void _navigateToHotelDetails(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/hotel-details',
      arguments: {
        'hotel': hotel,
        'checkInDate': null,
        'checkOutDate': null,
        'rooms': null,
      },
    );
  }
}
