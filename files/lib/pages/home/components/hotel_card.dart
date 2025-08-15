import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/dynamic_config.dart';
import '../../../config/wp_config.dart';
import '../../../controllers/location_controller.dart';
import '../../../core/constants/assets.dart';
import '../../../models/hotel.dart';
import '../../../widgets/AppWidgets.dart';
import '../../../core/utils/app_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../models/location.dart' as location_model;
import '../../booking/book_now_page.dart' as booking;
import '../../hotel_details/hotel_details_page.dart';
import '../../favorites/favorites_page.dart';
import 'package:easy_localization/easy_localization.dart';

class HotelCardModern extends ConsumerWidget {
  final Hotel hotel;
  final int bookingType; // 0: يومي، 1: شهري
  
  const HotelCardModern({required this.hotel, this.bookingType = 0});

  String getBookingPrice() {
    double? price;
    try {
      price = hotel.priceRange != null ? double.tryParse(hotel.priceRange!) : null;
    } catch (_) {
      price = null;
    }
    if (bookingType == 1 && price != null) {
      return '4${(price * 30 * 0.7).toStringAsFixed(0)} / شهر';
    } else if (price != null) {
      return '4${price.toStringAsFixed(0)} / يوم';
    }
    return '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = WPConfig.navbarColor; // Use constant color directly
    final screenWidth = MediaQuery.of(context).size.width;

    final isTablet = screenWidth >= 768;

    double cardWidth = (screenWidth - 24) / 2;
    // Slightly larger image as requested
    double imageHeight = cardWidth * (isTablet ? 0.50 : 0.56);
    
    // Different paddings and spacings based on device
    final contentPadding = EdgeInsets.all(isTablet ? 10 : 8);
    final cardMargin = EdgeInsets.only(bottom: isTablet ? 6 : 4, right: isTablet ? 6 : 2);
    final borderRadius = isTablet ? 12.0 : 20.0;
    final shadowBlur = isTablet ? 6.0 : 20.0;
    final shadowOffset = isTablet ? 2.0 : 8.0;
    
    // Font sizes - smaller on mobile
    final titleFontSize = isTablet ? 14.0 : 13.0;
    final subtitleFontSize = isTablet ? 12.0 : 12.0;
    final smallFontSize = isTablet ? 11.0 : 11.0;
    final microFontSize = isTablet ? 10.0 : 9.0;
    
    // Icon sizes
    final smallIconSize = isTablet ? 14.0 : 14.0;
    
    // Spacings
    final smallSpacing = isTablet ? 4.0 : 4.0;

    return GestureDetector(
      onTap: () { 
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HotelDetailsPage(hotel: hotel),
          ),
        );
      },
      child: Container(
        width: cardWidth,
        margin: cardMargin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: shadowBlur,
              offset: Offset(0, shadowOffset),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: shadowBlur * 0.5,
              offset: Offset(0, shadowOffset * 0.5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image section with favorite button overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
                  child: SizedBox(
                    width: cardWidth,
                    height: imageHeight,
                     child: hotel.imageUrl != null && hotel.imageUrl!.isNotEmpty
                        ? Image.network(
                            hotel.imageUrl!, 
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey[200],
                              child: Icon(Icons.hotel, color: Colors.grey[400], size: isTablet ? 50 : 58),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.hotel, color: Colors.grey[400], size: isTablet ? 50 : 58),
                          ),
                  ),

                ),
                SizedBox(height: smallSpacing),
                // Rating only
                if (hotel.rate != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 4 : 4, vertical: isTablet ? 2 : 1),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      hotel.rate!.toStringAsFixed(1),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: microFontSize,
                      ),
                    ),
                  ),
                SizedBox(height: smallSpacing),
                // Favorite button
                Positioned(
                  top: isTablet ? 8 : 8,
                  right: isTablet ? 8 : 8,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final favoritesNotifier = ref.watch(favoritesProvider.notifier);
                      final isFavorite = favoritesNotifier.isFavorite(hotel);

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            if (isFavorite) {
                              favoritesNotifier.removeHotel(hotel);
                              // Small delay to ensure widget is still mounted
                              await Future.delayed(Duration(milliseconds: 100));

                              if (context.mounted) {
                                  AppUtil.showSafeSnackBar(
                                  context,
                                    message: 'removed_from_favorites'.tr(),
                                    actionLabel: 'view_favorites'.tr(),
                                  onActionPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => FavoritesPage()),
                                    );
                                  },
                                );
                              }
                            } else {
                              favoritesNotifier.addHotel(hotel);
                              // Small delay to ensure widget is still mounted
                              await Future.delayed(Duration(milliseconds: 100));
                              if (context.mounted) {
                                  AppUtil.showSafeSnackBar(
                                  context,
                                    message: 'added_to_favorites'.tr(),
                                    actionLabel: 'view_favorites'.tr(),
                                  onActionPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => FavoritesPage()),
                                    );
                                  },
                                );
                              }
                            }
                          },

                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: EdgeInsets.all(isTablet ? 6 : 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : primaryColor,
                              size: isTablet ? 18 : 18,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

            ),

            // Content section
            Flexible(
              child: Padding(
                padding: contentPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hotel name
                    Text(
                      hotel.name ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: titleFontSize,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Location with city and country from location data
                    Consumer(
                      builder: (context, ref, child) {
                        final locationResponse = ref.watch(locationProvider);
                        return locationResponse.when(
                          data: (locationData) {
                            String locationText = '';
                            
                            // Get city name from city ID
                            if (hotel.cityId != null) {
                              final city = locationData.cities?.firstWhere(
                                (c) => c.id == hotel.cityId,
                                orElse: () => location_model.City(),
                              );
                              if (city?.name != null) {
                                locationText = city!.name!;
                              }
                            }
                            
                            // Get country name from country ID
                            if (hotel.countryId != null) {
                              final country = locationData.countries?.firstWhere(
                                (c) => c.id == hotel.countryId,
                                orElse: () => location_model.Country(),
                              );
                              if (country?.name != null) {
                                locationText = locationText.isNotEmpty 
                                    ? '$locationText, ${country!.name}'
                                    : country!.name!;
                              }
                            }
                            
                            // Fallback to existing data if location lookup fails
                            if (locationText.isEmpty) {
                              locationText = '${hotel.country ?? ''}${hotel.city != null ? ', ${hotel.city}' : ''}';
                            }
                            
                                                              return Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.black,
                                        size: smallIconSize,
                                      ),
                                       SizedBox(width: smallSpacing),
                                      Expanded(
                                        child: Text(
                                          locationText,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: smallFontSize,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  );
                          },
                    loading: () => Row(

                        ),
                        error: (e, _) => Row(
                          children: [

                            SizedBox(width: smallSpacing),
                            Expanded(
                              child: Text(
                                '${hotel.country ?? ''}${hotel.city != null ? ', ${hotel.city}' : ''}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: smallFontSize,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        );
                      }, 
                    ),   
                    // Deal label
                    if (hotel.dealLabel != null && hotel.dealLabel!.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 6 : 4,
                          vertical: isTablet ? 3 : 4
                        ), 
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          hotel.dealLabel!, 
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: microFontSize,
                          ),
                        ),
                      ),
                    SizedBox(height: smallSpacing),
                    // Price row enhanced
                    Row(
                      children: [
                        if (hotel.oldPrice != null && hotel.oldPrice != hotel.priceRange) ...[
                          Text(
                            hotel.oldPrice!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: smallFontSize,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          SizedBox(width: smallSpacing),
                        ],
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.attach_money, size: smallIconSize, color: Colors.black),
                              SizedBox(width: 2),
                              Text(
                                hotel.priceRange ?? '',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: smallFontSize,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HotelCardVertical extends ConsumerWidget {
  final Hotel hotel;
  final int bookingType; // 0: يومي، 1: شهري
  final DateTimeRange? dateRangeFromSearch;
  final TimeOfDay? startTimeFromSearch;
  final TimeOfDay? endTimeFromSearch;
  final bool isSearchContext;
  final bool showBookNowButton;
  
  const HotelCardVertical({
    required this.hotel,
    this.bookingType = 0,
    this.dateRangeFromSearch,
    this.startTimeFromSearch,
    this.endTimeFromSearch,
    this.isSearchContext = false,
    this.showBookNowButton = true,
  });

  String getBookingPrice() {
    double? price;
    try {
      price = hotel.priceRange != null ? double.tryParse(hotel.priceRange!) : null;
    } catch (_) {
      price = null;
    }
    if (bookingType == 1 && price != null) {
      return '4${(price * 30 * 0.7).toStringAsFixed(0)} / شهر';
    } else if (price != null) {
      return '4${price.toStringAsFixed(0)} / يوم';
    }
    return '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = WPConfig.navbarColor;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return GestureDetector(
      onTap: () { 
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HotelDetailsPage(hotel: hotel),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with favorite button overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    width: double.infinity,
                    height: 200,
                     child: hotel.imageUrl != null && hotel.imageUrl!.isNotEmpty
                        ? Image.network(
                            hotel.imageUrl!, 
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey[200],
                              child: Icon(Icons.hotel, color: Colors.grey[400], size: 48),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.hotel, color: Colors.grey[400], size: 48),
                          ),
                  ),
                ),
                // Favorite button
                Positioned(
                  top: 12,
                  right: 12,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final favoritesNotifier = ref.watch(favoritesProvider.notifier);
                      final isFavorite = favoritesNotifier.isFavorite(hotel);
                      
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            if (isFavorite) {
                              favoritesNotifier.removeHotel(hotel);
                              // Small delay to ensure widget is still mounted
                              await Future.delayed(Duration(milliseconds: 100));
                              if (context.mounted) {
                                AppUtil.showSafeSnackBar(
                                  context,
                                  message: 'Removed from favorites',
                                  actionLabel: 'View Favorites',
                                  onActionPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => FavoritesPage()),
                                    );
                                  },
                                );
                              }
                            } else {
                              favoritesNotifier.addHotel(hotel);
                              // Small delay to ensure widget is still mounted
                              await Future.delayed(Duration(milliseconds: 100));
                              if (context.mounted) {
                                AppUtil.showSafeSnackBar(
                                  context,
                                  message: 'Added to favorites!',
                                  actionLabel: 'View Favorites',
                                  onActionPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => FavoritesPage()),
                                    );
                                  },
                                );
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : primaryColor,
                              size: 20,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            // Content section
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    // Hotel name and optional rating badge (enhanced on search)
                    Row(
                    children: [
                      Expanded(
                        child: Text(
                          hotel.name ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                        if (hotel.rate != null)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  hotel.rate!.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                                if (isSearchContext && (hotel.reviews?.isNotEmpty ?? false)) ...[
                                  SizedBox(width: 6),
                                  Text(
                                    '(${hotel.reviews!.length})',
                                    style: TextStyle(color: Colors.black54, fontSize: 11),
                                  ),
                                ],
                              ],
                            ),
                          ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Location
                  Consumer(
                    builder: (context, ref, child) {
                      final locationResponse = ref.watch(locationProvider);
                      return locationResponse.when(
                        data: (locationData) {
                          String locationText = '';
                          
                          if (hotel.cityId != null) {
                            final city = locationData.cities?.firstWhere(
                              (c) => c.id == hotel.cityId,
                              orElse: () => location_model.City(),
                            );
                            if (city?.name != null) {
                              locationText = city!.name!;
                            }
                          }
                          
                          if (hotel.countryId != null) {
                            final country = locationData.countries?.firstWhere(
                              (c) => c.id == hotel.countryId,
                              orElse: () => location_model.Country(),
                            );
                            if (country?.name != null) {
                              locationText = locationText.isNotEmpty 
                                  ? '$locationText, ${country!.name}'
                                  : country!.name!;
                            }
                          }
                          
                          if (locationText.isEmpty) {
                            locationText = '${hotel.country ?? ''}${hotel.city != null ? ', ${hotel.city}' : ''}';
                          }
                          
                          return Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.grey[600],
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  locationText,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => Row(
                          children: [ 
                            Icon(
                              Icons.location_on,
                              color: Colors.grey[600],
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${hotel.country ?? ''}${hotel.city != null ? ', ${hotel.city}' : ''}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        error: (e, _) => Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.grey[600],
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${hotel.country ?? ''}${hotel.city != null ? ', ${hotel.city}' : ''}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }, 
                  ),
                   SizedBox(height: 8),
                   // Facilities chips (enhanced for search context)
                   if (isSearchContext && (hotel.facilities?.isNotEmpty ?? false)) ...[
                     Wrap(
                       spacing: 6,
                       runSpacing: -6,
                       children: hotel.facilities!
                           .take(4)
                           .map((f) => Chip(
                                 label: Text(
                                   f,
                                   style: TextStyle(fontSize: 10),
                                 ),
                                 visualDensity: VisualDensity.compact,
                                 materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                               ))
                           .toList(),
                     ),
                     SizedBox(height: 10),
                   ],
                  // Deal label
                  if (hotel.dealLabel != null && hotel.dealLabel!.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        hotel.dealLabel!, 
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                   SizedBox(height: 12),
                   // Price and action button
                   Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hotel.oldPrice != null && hotel.oldPrice != hotel.priceRange)
                              Text(
                                hotel.oldPrice!,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                             if (isSearchContext)
                               Row(
                                 children: [
                                   Container(
                                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                     decoration: BoxDecoration(
                                       color: Colors.blueGrey.withOpacity(0.08),
                                       borderRadius: BorderRadius.circular(8),
                                     ),
                                     child: Text(
                                       bookingType == 1 ? 'per month' : 'per day',
                                       style: TextStyle(fontSize: 10, color: Colors.black87),
                                     ),
                                   ),
                                 ],
                               ),
                          ],
                        ),
                      ),
                        Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.attach_money, size: 14, color: Colors.black),
                                  SizedBox(width: 2),
                                  Text(
                                    hotel.priceRange ?? '',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                        SizedBox(width: 12),
                        if (showBookNowButton)
                        ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => booking.BookNowPage(
                                hotel: hotel,
                                bookingType: bookingType,
                                dateRangeFromSearch: dateRangeFromSearch,
                                startTimeFromSearch: startTimeFromSearch,
                                endTimeFromSearch: endTimeFromSearch,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: Text(
                          'book_now'.tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
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
      ),
    );
  }
}

