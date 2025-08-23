import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../config/dynamic_config.dart';
import '../../../../controllers/hotel_controller.dart';
import '../../../../controllers/location_controller.dart';
import '../../../models/hotel.dart';
import '../../../models/location.dart' as location_model;

import 'hotel_card.dart';

class HotelsList extends ConsumerWidget {
  const HotelsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final primaryColor = dynamicConfig.primaryColor;
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 16),
            child: Text(
              'Hotels',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 24 : 18,
                color: Colors.black,
              ),
            ),
          ),
          
          SizedBox(height: isTablet ? 24 : 16),
          
          // Hotels list with different layouts for mobile and tablet
          Consumer(
            builder: (context, ref, child) {
              final hotelsResponse = ref.watch(hotelProvider);
              final locationResponse = ref.watch(locationProvider);
              
              return locationResponse.when(
                data: (locationData) {
                  return hotelsResponse.when(
          data: (hotels) {
                      if (hotels.isEmpty) {
                        return _buildEmptyState(isTablet);
                      }
                      
                      // Show all hotels on home page
                      final displayHotels = hotels;
                      
                      if (isTablet) {
                        return _buildTabletLayout(displayHotels, locationData, primaryColor);
                      } else {
                        return _buildMobileLayout(displayHotels, locationData, primaryColor);
                      }
                    },
                    loading: () => _buildLoadingState(isTablet),
                    error: (e, _) => _buildErrorState(isTablet, e.toString()),
                  );
                },
                loading: () => _buildLoadingState(isTablet),
                error: (e, _) => _buildErrorState(isTablet, e.toString()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(List<Hotel> hotels, dynamic locationData, Color primaryColor) {
    return Column(
      children: hotels.map((hotel) {
        // Find location data for this hotel
        location_model.City? hotelCity;
        location_model.Country? hotelCountry;
        
        if (hotel.cityId != null) {
          hotelCity = locationData.cities?.firstWhere(
            (c) => c.id == hotel.cityId,
            orElse: () => location_model.City(),
          );
        }

                if (hotel.countryId != null) {
          hotelCountry = locationData.countries?.firstWhere(
                    (c) => c.id == hotel.countryId,
                    orElse: () => location_model.Country(),
                  );
        }
        
        return HotelCard(
          hotel: hotel,
          city: hotelCity,
          country: hotelCountry,
          onFavoriteTap: () {
            // Handle favorite toggle
          },
          isFavorite: false, // This should come from your favorites provider
        );
      }).toList(),
    );
  }

  Widget _buildTabletLayout(List<Hotel> hotels, dynamic locationData, Color primaryColor) {
    // For tablet, show hotels in a grid layout
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.8, // Wider cards for tablet
      ),
      itemCount: hotels.length,
      itemBuilder: (context, index) {
        final hotel = hotels[index];
        location_model.City? hotelCity;
        location_model.Country? hotelCountry;

                if (hotel.cityId != null) {
          hotelCity = locationData.cities?.firstWhere(
                    (c) => c.id == hotel.cityId,
                    orElse: () => location_model.City(),
                  );
        }
        
        if (hotel.countryId != null) {
          hotelCountry = locationData.countries?.firstWhere(
            (c) => c.id == hotel.countryId,
            orElse: () => location_model.Country(),
          );
        }
        
        return HotelCard(
          hotel: hotel,
          city: hotelCity,
          country: hotelCountry,
          onFavoriteTap: () {
            // Handle favorite toggle
          },
          isFavorite: false, // This should come from your favorites provider
        );
      },
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 48 : 32),
                   child: Column(
                     children: [
          Icon(
            Icons.hotel_outlined,
            size: isTablet ? 80 : 48,
            color: Colors.grey[400],
          ),
          SizedBox(height: isTablet ? 24 : 16),
                        Text(
            'No hotels available',
            style: TextStyle(
              fontSize: isTablet ? 22 : 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
                        Text(
            'Check back later for new listings',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
                       ),
                     ],
                   ),
                 );
               }

  Widget _buildLoadingState(bool isTablet) {
    if (isTablet) {
      // Tablet loading state - grid layout
      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.8,
        ),
        itemCount: 3,
        itemBuilder: (context, index) => _buildTabletLoadingCard(),
      );
    } else {
      // Mobile loading state - column layout
      return Column(
        children: List.generate(3, (index) => _buildMobileLoadingCard()),
      );
    }
  }

  Widget _buildMobileLoadingCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
                   child: Row(
                     children: [
          // Image placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(width: 16),
          // Content placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
                     ],
                   ),
                 );
               }

  Widget _buildTabletLoadingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          // Content placeholder
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  width: 150,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  width: 100,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
                 ),
               );
             }

  Widget _buildErrorState(bool isTablet, String error) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 48 : 32),
      child: Column(
                  children: [
          Icon(
            Icons.error_outline,
            size: isTablet ? 80 : 48,
            color: Colors.red[400],
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            'Error loading hotels',
                        style: TextStyle(
              fontSize: isTablet ? 22 : 18,
              color: Colors.red[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            error,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
                                       ),
                                   ],
                                 ),
    );
  }
}

