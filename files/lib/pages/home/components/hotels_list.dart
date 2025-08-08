import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../controllers/hotel_controller.dart';
import '../../../../controllers/location_controller.dart';
import '../../../../models/hotel.dart';
import '../../../../models/location.dart' as location_model;
import '../../../../config/dynamic_config.dart';
import '../home_page.dart';
import 'hotel_card.dart';
import 'hotels_section_header.dart';
import '../providers/home_providers.dart';

class HotelsList extends ConsumerWidget {
  const HotelsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('=== HOTELS LIST BUILD ===');
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final primaryColor = dynamicConfig.primaryColor ?? Color(0xFF895ffc);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bookingType = ref.watch(selectedBookingTypeProvider);
    final selectedLocations = ref.watch(selectedLocationsProvider);
    
    print('Screen dimensions: ${screenWidth}x${screenHeight}');
    print('Booking type: $bookingType');
    print('Selected locations: $selectedLocations');

    return Consumer(
      builder: (context, ref, _) {
        print('Consumer builder called');
        final hotelsAsync = ref.watch(hotelProvider);
        print('Hotels async state: ${hotelsAsync.toString()}');
        
        return hotelsAsync.when(
          data: (hotels) {
            print('Hotels data received: ${hotels.length} hotels');
            List<Hotel> filteredHotels = hotels;
            if (selectedLocations.isNotEmpty) {
              print('Filtering hotels for locations: $selectedLocations');

              // Get location data to map IDs to names
              final locationResponse = ref.read(locationProvider).value;
              print('Location response: $locationResponse');
              final countries = locationResponse?.countries ?? [];
              final cities = locationResponse?.cities ?? [];
              final states = locationResponse?.states ?? [];
              print('Location data - Countries: ${countries.length}, Cities: ${cities.length}, States: ${states.length}');

              // First, populate hotel location names from IDs
              filteredHotels = filteredHotels.map((hotel) {
                // Create a new hotel instance with populated location names
                String? countryName = hotel.country;
                String? cityName = hotel.city;
                String? stateName = hotel.state;

                if (hotel.countryId != null) {
                  final country = countries.firstWhere(
                    (c) => c.id == hotel.countryId,
                    orElse: () => location_model.Country(),
                  );
                  countryName = country.name;
                }

                if (hotel.cityId != null) {
                  final city = cities.firstWhere(
                    (c) => c.id == hotel.cityId,
                    orElse: () => location_model.City(),
                  );
                  cityName = city.name;
                }

                if (hotel.stateId != null) {
                  final state = states.firstWhere(
                    (s) => s.id == hotel.stateId,
                    orElse: () => location_model.State(),
                  );
                  stateName = state.name;
                }

                // Create new hotel with populated names
                return Hotel(
                  id: hotel.id,
                  name: hotel.name,
                  location: hotel.location,
                  imageUrl: hotel.imageUrl,
                  rate: hotel.rate,
                  isOccupied: hotel.isOccupied,
                  description: hotel.description,
                  facilities: hotel.facilities,
                  roomTypes: hotel.roomTypes,
                  checkInTime: hotel.checkInTime,
                  checkOutTime: hotel.checkOutTime,
                  priceRange: hotel.priceRange,
                  contact: hotel.contact,
                  reviews: hotel.reviews,
                  locationCoordinates: hotel.locationCoordinates,
                  bookingUrl: hotel.bookingUrl,
                  images: hotel.images,
                  category: hotel.category,
                  nearbyAttractions: hotel.nearbyAttractions,
                  availableDates: hotel.availableDates,
                  country: countryName,
                  state: stateName,
                  city: cityName,
                  countryId: hotel.countryId,
                  stateId: hotel.stateId,
                  cityId: hotel.cityId,
                  slug: hotel.slug,
                  stars: hotel.stars,
                  categorySlug: hotel.categorySlug,
                  latitude: hotel.latitude,
                  longitude: hotel.longitude,
                ); 
              }).toList();

              // Now filter by selected locations
              filteredHotels = filteredHotels.where((hotel) {
                bool matches = selectedLocations.any((loc) {
                  bool countryMatch = (hotel.country?.toLowerCase() ?? '').contains(loc.toLowerCase());
                  bool cityMatch = (hotel.city?.toLowerCase() ?? '').contains(loc.toLowerCase());
                  bool stateMatch = (hotel.state?.toLowerCase() ?? '').contains(loc.toLowerCase());
                  bool locationMatch = (hotel.location?.toLowerCase().trim() ?? '').contains(loc.toLowerCase());
                  bool categoryMatch = (hotel.category?.toLowerCase().trim() ?? '').contains(loc.toLowerCase());

                  print('Hotel: ${hotel.name}, Country: ${hotel.country}, City: ${hotel.city}, State: ${hotel.state}');
                  print('Location to match: $loc');
                  print('Matches: country=$countryMatch, city=$cityMatch, state=$stateMatch, location=$locationMatch, category=$categoryMatch');

                  return countryMatch || cityMatch || stateMatch || locationMatch || categoryMatch;
                });
                return matches;
              }).toList();
              print('After filtering: ${filteredHotels.length} hotels');
            }

             // Debug print
            print('Selected locations: $selectedLocations');
            print('Total hotels: ${hotels.length}');
            print('Filtered hotels: ${filteredHotels.length}');
            if (hotels.isNotEmpty) {
              print('Sample hotel data: ${hotels.first.toJson()}');
            }

             // If filtered
             if (selectedLocations.isNotEmpty) {
               print('Showing filtered hotels layout');
               if (filteredHotels.isEmpty) {
                 print('No hotels found for selected locations');
                  return Center(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Icon(Icons.hotel_outlined, size: 64, color: Colors.grey[400]),
                       SizedBox(height: 16),
                        Text(
                          'no_hotels_found'.tr(),
                         style: TextStyle(fontSize: 16, color: Colors.black),
                       ),
                       SizedBox(height: 8),
                        Text(
                          'try_selecting_different_locations'.tr(),
                         style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                       ),
                     ],
                   ),
                 );
               }
               // Tablet: show exactly two cards only
               if (screenWidth > 768) {
                 final toShow = filteredHotels.take(2).toList();
                 return Padding(
                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   child: Row(
                     children: [
                       Expanded(child: HotelCardModern(hotel: toShow[0], bookingType: bookingType)),
                       if (toShow.length > 1)
                         SizedBox(width: 6),
                       if (toShow.length > 1)
                         Expanded(child: HotelCardModern(hotel: toShow[1], bookingType: bookingType)),
                     ],
                   ),
                 );
               }
               // Mobile: keep horizontal scrollable layout
               return SizedBox(
                 height: screenHeight * 0.25,
                 child: ListView.separated(
                   scrollDirection: Axis.horizontal,
                   physics: BouncingScrollPhysics(),
                   padding: EdgeInsets.symmetric(horizontal: 8),
                   itemCount: filteredHotels.length,
                   separatorBuilder: (_, __) => SizedBox(width: 8),
                   itemBuilder: (context, index) { 
                     final hotel = filteredHotels[index];
                     return HotelCardModern(hotel: hotel, bookingType: bookingType);
                   },
                 ),
               );
             }

            // If not filtered, show horizontal cards grouped by category
            print('Showing unfiltered hotels grouped by category');
            Map<String, List<Hotel>> hotelsByCategory = {};
            for (var hotel in filteredHotels) {
              String category = hotel.category ?? 'Other';
              if (!hotelsByCategory.containsKey(category)) {
                hotelsByCategory[category] = [];
              }
              hotelsByCategory[category]!.add(hotel);
            }
            print('Hotels grouped by category: ${hotelsByCategory.keys.toList()}');
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: hotelsByCategory.entries.map((entry) {
                String category = entry.key;
                List<Hotel> categoryHotels = entry.value;
                print('Rendering category: $category with ${categoryHotels.length} hotels');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category title
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: screenWidth > 768 ? 0 : 2),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth > 768 ? 16 : 14, 
                          color: Colors.black,
                        ),
                      ),      
                    ),

                     // Hotels in this category - responsive layout 
                     screenWidth > 768
                         ? Builder(
                             builder: (_) {
                               final displayHotels = categoryHotels.take(2).toList();
                               return Padding(
                                 padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                 child: Row(
                                   children: [
                                     Expanded(
                                       child: HotelCardModern(hotel: displayHotels[0], bookingType: bookingType),
                                     ),
                                     if (displayHotels.length > 1) SizedBox(width: 6),
                                     if (displayHotels.length > 1)
                                       Expanded(
                                         child: HotelCardModern(hotel: displayHotels[1], bookingType: bookingType),
                                       ),
                                   ],
                                 ),
                               );
                             },
                           )
                         : SizedBox(
                             height: screenHeight * 0.25,
                             child: ListView.separated(
                               scrollDirection: Axis.horizontal,
                               physics: BouncingScrollPhysics(),
                               padding: EdgeInsets.symmetric(horizontal: 8),
                               itemCount: categoryHotels.length,
                               separatorBuilder: (_, __) => SizedBox(width: 8),
                               itemBuilder: (context, index) {
                                 final hotel = categoryHotels[index];
                                 return HotelCardModern(hotel: hotel, bookingType: bookingType);
                               },
                             ),
                           ),
                    SizedBox(height: screenWidth > 768 ? 0 : 4),
                  ],
                );
              }).toList(),
            );
          },
          loading: () { 
            print('Hotels loading state');
            return Center(child: CircularProgressIndicator(color: primaryColor));
          },
          error: (e, _) {
            print('Hotels error state: $e');
            return Center(child: Text('error_loading_hotels'.tr(), style: TextStyle(color: Colors.black)));
          },
        );
      },
    );
  }
}

