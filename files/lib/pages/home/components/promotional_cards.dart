import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../config/dynamic_config.dart';
import '../../../../controllers/hotel_controller.dart';
import '../../../models/hotel.dart';

class PromotionalCards extends ConsumerWidget {
  const PromotionalCards({Key? key}) : super(key: key);

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
            'Hotel Offers',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 20 : 18,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Special deals and promotions for your next stay',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 12),
          
          // Dynamic promotional card based on your hotel data
          Consumer(
            builder: (context, ref, child) {
              final hotelsResponse = ref.watch(hotelProvider);
              
              return hotelsResponse.when(
                data: (hotels) {
                  if (hotels.isEmpty) {
                    return _buildPlaceholderCard(isTablet, primaryColor);
                  }
                  
                  // Get a sample hotel for promotional content
                  final sampleHotel = hotels.first;
                  final hotelName = sampleHotel.name ?? 'Amazing Hotel';
                  final hotelPrice = sampleHotel.priceRange ?? '100';
                  final originalPrice = double.tryParse(hotelPrice) ?? 100;
                  final discountedPrice = originalPrice * 0.8; // 20% off
                  
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isTablet ? 20 : 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick escape, quality time',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isTablet ? 18 : 16,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Save up to 20% with a Getaway Deal',
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 12),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        // Placeholder image
                        Container(
                          width: isTablet ? 80 : 60,
                          height: isTablet ? 80 : 60,
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.hotel,
                            color: Colors.blue[600],
                            size: isTablet ? 32 : 24,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => _buildPlaceholderCard(isTablet, primaryColor),
                error: (e, _) => _buildPlaceholderCard(isTablet, primaryColor),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCard(bool isTablet, Color? primaryColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loading offers...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 18 : 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please wait',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Container(
            width: isTablet ? 80 : 60,
            height: isTablet ? 80 : 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.hourglass_empty,
              color: Colors.grey[400],
              size: isTablet ? 32 : 24,
            ),
          ),
        ],
      ),
    );
  }
} 