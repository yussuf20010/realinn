import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/hotel.dart';
import '../../../../controllers/location_controller.dart';
import '../../../../config/dynamic_config.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../models/location.dart' as location_model;
import '../../hotel_details/hotel_details_page.dart';

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
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final primaryColor = dynamicConfig.primaryColor ?? Color(0xFF895ffc);
    final screenWidth = MediaQuery.of(context).size.width;

    final isTablet = screenWidth > 768;

    double cardWidth = (screenWidth - 24) / 2;
    double imageHeight = cardWidth * 0.6;
    
    // Different paddings and spacings based on device
    final contentPadding = EdgeInsets.all(isTablet ? 8 : 8);
    final cardMargin = EdgeInsets.only(bottom: isTablet ? 1 : 4, right: isTablet ? 1 : 2);
    final borderRadius = isTablet ? 8.0 : 20.0;
    final shadowBlur = isTablet ? 2.0 : 20.0;
    final shadowOffset = isTablet ? 0.5 : 8.0;
    
    // Font sizes - decreased
    final titleFontSize = isTablet ? 10.0 : 16.0;
    final subtitleFontSize = isTablet ? 8.0 : 14.0;
    final smallFontSize = isTablet ? 6.0 : 12.0;
    final microFontSize = isTablet ? 4.0 : 10.0;
    
    // Icon sizes
    final smallIconSize = isTablet ? 4.0 : 14.0;
    
    // Spacings
    final smallSpacing = isTablet ? 2.0 : 4.0;

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
            // Image section
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
                          child: Icon(Icons.hotel, color: Colors.grey[400], size: isTablet ? 16 : 48),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.hotel, color: Colors.grey[400], size: isTablet ? 16 : 48),
                      ),
              ),
            ),
            // Content section
            Expanded(
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
                    SizedBox(height: 1),
                    // Rating only
                    if (hotel.rate != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: isTablet ? 2 : 4, vertical: isTablet ? 1 : 1),
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
                    SizedBox(height: 1),
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
                                      SizedBox(width: 2),
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
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.black,
                              size: smallIconSize,
                            ),
                            SizedBox(width: 2),
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
                        error: (e, _) => Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.black,
                              size: smallIconSize,
                            ),
                            SizedBox(width: 2),
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
                          horizontal: isTablet ? 3 : 4,
                          vertical: isTablet ? 2 : 4
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
                    // Price section
                   
                    Row(
                      children: [
                        if (hotel.oldPrice != null && hotel.oldPrice != hotel.priceRange)
                          Text(
                            hotel.oldPrice!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: smallFontSize,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        if (hotel.oldPrice != null && hotel.oldPrice != hotel.priceRange) SizedBox(width: smallSpacing),
                        Text(
                          hotel.priceRange ?? '',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: subtitleFontSize,
                          ),
                        ),
                      ],
                    ),
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

