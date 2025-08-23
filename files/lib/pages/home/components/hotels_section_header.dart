import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../config/dynamic_config.dart';
import '../../../../controllers/hotel_controller.dart';
import '../../../models/hotel.dart';

class HotelsSectionHeader extends ConsumerWidget {
  const HotelsSectionHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final primaryColor = dynamicConfig.primaryColor;
    final isTablet = MediaQuery.of(context).size.width >= 768;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            'Why RealInn?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 20 : 18,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),
          
          // Dynamic loyalty cards based on your hotel data
          Consumer(
            builder: (context, ref, child) {
              final hotelsResponse = ref.watch(hotelProvider);
              
              return hotelsResponse.when(
                data: (hotels) {
                  if (hotels.isEmpty) {
                    return _buildPlaceholderCards(isTablet, primaryColor);
                  }
                  
                  // Calculate statistics from your hotel data
                  final totalHotels = hotels.length;
                  final averageRating = hotels
                      .where((h) => h.rate != null)
                      .map((h) => h.rate!)
                      .reduce((a, b) => a + b) / hotels.where((h) => h.rate != null).length;
                  final hasDiscounts = hotels.any((h) => h.oldPrice != null && h.oldPrice != h.priceRange);
                  
                  return Row(
        children: [
                      // Genius card
                      Expanded(
                        child: Container(
                          height: isTablet ? 100 : 80,
                          margin: EdgeInsets.only(right: 8),
                          padding: EdgeInsets.all(isTablet ? 16 : 12),
            decoration: BoxDecoration(
              color: primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.emoji_events,
                                    color: Colors.white,
                                    size: isTablet ? 24 : 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Genius',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isTablet ? 16 : 14,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'You\'re at Genius Level 1 in our loyalty program',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 14 : 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Statistics card
                      Expanded(
                        child: Container(
                          height: isTablet ? 100 : 80,
                          margin: EdgeInsets.only(left: 8),
                          padding: EdgeInsets.all(isTablet ? 16 : 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: primaryColor, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: primaryColor,
                                    size: isTablet ? 24 : 20,
                                  ),
                                  SizedBox(width: 8),
          Text(
                                    '${totalHotels} Hotels',
            style: TextStyle(
                                      color: Colors.black,
              fontWeight: FontWeight.bold,
                                      fontSize: isTablet ? 16 : 14,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Average rating: ${averageRating.isNaN ? "N/A" : averageRating.toStringAsFixed(1)}',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: isTablet ? 14 : 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => _buildPlaceholderCards(isTablet, primaryColor),
                error: (e, _) => _buildPlaceholderCards(isTablet, primaryColor),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCards(bool isTablet, Color? primaryColor) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: isTablet ? 100 : 80,
            margin: EdgeInsets.only(right: 8),
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Colors.grey[400],
                      size: isTablet ? 24 : 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 16 : 14,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Please wait',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: isTablet ? 14 : 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        Expanded(
          child: Container(
            height: isTablet ? 100 : 80,
            margin: EdgeInsets.only(left: 8),
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.grey[400],
                      size: isTablet ? 24 : 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 16 : 14,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Please wait',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: isTablet ? 14 : 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

