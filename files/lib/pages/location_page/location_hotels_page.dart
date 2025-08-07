import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/image_cache_config.dart';
import '../../config/wp_config.dart';
import '../../controllers/hotel_controller.dart';
import '../../models/hotel.dart';
import '../../models/location.dart';
import '../../widgets/custom_app_bar.dart';

class LocationHotelsPage extends ConsumerWidget {
  final LocationModel location;

  const LocationHotelsPage({Key? key, required this.location}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hotelsAsync = ref.watch(hotelProvider);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: location.country ?? 'Location Hotels',
        showBackButton: true,
      ),
      body: hotelsAsync.when(
        data: (hotels) {
          // Filter hotels based on the selected location
          final filteredHotels = hotels.where((hotel) => 
            hotel.country?.toLowerCase().contains((location.country ?? '').toLowerCase()) == true ||
            hotel.city?.toLowerCase().contains((location.country ?? '').toLowerCase()) == true ||
            hotel.state?.toLowerCase().contains((location.country ?? '').toLowerCase()) == true ||
            hotel.location?.toLowerCase().contains((location.country ?? '').toLowerCase()) == true ||
            hotel.category?.toLowerCase().contains((location.country ?? '').toLowerCase()) == true
          ).toList();
          
          if (filteredHotels.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hotel_outlined, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No hotels found in ${location.country}',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try selecting a different location',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredHotels.length,
            itemBuilder: (context, index) {
              final hotel = filteredHotels[index];
              return _HotelCard(hotel: hotel);
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading hotels')),
      ),
    );
  }
}

class _HotelCard extends StatelessWidget {
  final Hotel hotel;

  const _HotelCard({required this.hotel});

  String _getImageUrl(Hotel hotel) {
    if (hotel.images?.isNotEmpty == true) {
      return hotel.images!.first;
    }
    return hotel.imageUrl ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getImageUrl(hotel);
    
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.hotel, size: 50, color: Colors.grey[600]),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.hotel, size: 50, color: Colors.grey[600]),
                    ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel.name ?? 'Hotel Name',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  hotel.city ?? hotel.country ?? hotel.location ?? 'Location',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (hotel.category != null) ...[
                  SizedBox(height: 4),
                  Text(
                    hotel.category!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (hotel.priceRange != null) ...[
                  SizedBox(height: 8),
                  Text(
                    'Starting from ${hotel.priceRange}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
} 