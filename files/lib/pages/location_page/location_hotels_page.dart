import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/image_cache_config.dart';
import '../../config/wp_config.dart';
import '../../controllers/hotel_controller.dart';
import '../../models/hotel.dart';
import '../../models/location.dart';
import '../../widgets/custom_app_bar.dart';
import '../home/components/hotel_card.dart';
import '../home/home_page.dart'; // Import to use _HotelCardModern

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
              return HotelCardModern(hotel: hotel, bookingType: 0);
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading hotels')),
      ),
    );
  }
}

 