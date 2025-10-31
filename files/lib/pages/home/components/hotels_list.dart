import 'package:flutter/material.dart';
import '../../../../services/hotel_service.dart';
import '../../../models/hotel.dart';
import 'hotel_card.dart';

class HotelsList extends StatelessWidget {
  const HotelsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          FutureBuilder(
            future: Future.wait([
              HotelService.fetchHotels(),
              HotelService.fetchMeta(),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState(isTablet);
              }
              if (snapshot.hasError) {
                return _buildErrorState(isTablet, snapshot.error.toString());
              }
              final results = snapshot.data as List<dynamic>?;
              if (results == null || results.length < 2) {
                return _buildEmptyState(isTablet);
              }
              final hotels = results[0] as List<Hotel>;
              final locationData = results[1] as LocationResponseModel;
              if (hotels.isEmpty) {
                return _buildEmptyState(isTablet);
              }
              final displayHotels = hotels;
              if (isTablet) {
                return _buildTabletLayout(
                    displayHotels, locationData, Colors.purple);
              } else {
                return _buildMobileLayout(
                    displayHotels, locationData, Colors.purple);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(List<Hotel> hotels,
      LocationResponseModel locationData, Color primaryColor) {
    return Column(
      children: hotels.map((hotel) {
        // Find location data for this hotel
        return HotelCard(
          hotel: hotel,
          city: null,
          country: null,
          onFavoriteTap: () {
            // Handle favorite toggle
          },
          isFavorite: false, // This should come from your favorites provider
        );
      }).toList(),
    );
  }

  Widget _buildTabletLayout(List<Hotel> hotels,
      LocationResponseModel locationData, Color primaryColor) {
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
        return HotelCard(
          hotel: hotel,
          city: null,
          country: null,
          onFavoriteTap: () {},
          isFavorite: false,
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
