import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/dynamic_config.dart';
import '../../../../providers/favorites_provider.dart';

import '../../../models/hotel.dart';
import '../../../models/location.dart' as location_model;

class HotelCard extends ConsumerWidget {
  final Hotel hotel;
  final location_model.City? city;
  final location_model.Country? country;
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
                      ' · ${_getReviewCount()} reviews',
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

                // Availability Warning (Compact)
                Text(
                  'Only ${_getRandomAvailability()} left at this price on',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                GestureDetector(
                  onTap: () => _navigateToHotelDetails(context),
                  child: Text(
                    'RealInn',
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
                  Text(
                    ' · ${_getReviewCount()} reviews',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
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

              // Availability Warning (Expanded)
              Text(
                'Only ${_getRandomAvailability()} left at this price on',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              GestureDetector(
                onTap: () => _navigateToHotelDetails(context),
                child: Text(
                  'RealInn',
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
    // Use beautiful hotel images from Unsplash if no hotel images available
    final imageUrl = hotel.images?.isNotEmpty == true
        ? hotel.images!.first
        : _getHotelCategoryImage(hotel.name ?? 'Hotel');

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

  String _getHotelCategoryImage(String hotelName) {
    final name = hotelName.toLowerCase();

    // Create a hash-based selection to ensure different hotels get different images
    final hash = hotelName.hashCode;
    final imageIndex = (hash % 20).abs(); // Use 20 different images

    // Luxury hotels
    if (name.contains('luxury') ||
        name.contains('premium') ||
        name.contains('elite') ||
        name.contains('royal') ||
        name.contains('grand') ||
        name.contains('palace')) {
      final luxuryImages = [
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&h=300&fit=crop',
      ];
      return luxuryImages[imageIndex % luxuryImages.length];
    }

    // Beach resorts
    if (name.contains('beach') ||
        name.contains('resort') ||
        name.contains('coastal') ||
        name.contains('ocean') ||
        name.contains('seaside')) {
      final beachImages = [
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=300&fit=crop',
      ];
      return beachImages[imageIndex % beachImages.length];
    }

    // Mountain hotels
    if (name.contains('mountain') ||
        name.contains('alpine') ||
        name.contains('ski') ||
        name.contains('lodge') ||
        name.contains('cabin')) {
      final mountainImages = [
        'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=300&fit=crop',
      ];
      return mountainImages[imageIndex % mountainImages.length];
    }

    // City hotels
    if (name.contains('city') ||
        name.contains('urban') ||
        name.contains('downtown') ||
        name.contains('center') ||
        name.contains('plaza')) {
      final cityImages = [
        'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=300&fit=crop',
      ];
      return cityImages[imageIndex % cityImages.length];
    }

    // Boutique hotels
    if (name.contains('boutique') ||
        name.contains('charm') ||
        name.contains('vintage') ||
        name.contains('heritage') ||
        name.contains('classic')) {
      final boutiqueImages = [
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=300&fit=crop',
      ];
      return boutiqueImages[imageIndex % boutiqueImages.length];
    }

    // Business hotels
    if (name.contains('business') ||
        name.contains('corporate') ||
        name.contains('executive') ||
        name.contains('suite') ||
        name.contains('conference')) {
      final businessImages = [
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=300&fit=crop',
      ];
      return businessImages[imageIndex % businessImages.length];
    }

    // Default diverse hotel images based on hash
    final defaultImages = [
      'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop',
    ];

    return defaultImages[imageIndex];
  }

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

  int _getRandomAvailability() {
    // This should come from your dynamic data
    final hotelId = int.tryParse(hotel.id ?? '0') ?? 0;
    return 2 + (hotelId % 4); // Random number between 2-5
  }

  int _getReviewCount() {
    // This should come from your dynamic data
    final hotelId = int.tryParse(hotel.id ?? '0') ?? 0;
    return 100 + (hotelId % 500); // Random number between 100-600
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
    if (hotel.images != null && hotel.imageUrl!.isNotEmpty) {
      return Image.network(
        hotel.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }
    return _buildPlaceholderImage();
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
