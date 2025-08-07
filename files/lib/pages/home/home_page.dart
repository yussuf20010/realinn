import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/hotel_controller.dart';
import '../../controllers/location_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../models/hotel.dart';
import '../../models/location.dart' as location_model;
import 'package:flutter/material.dart' hide State;
import '../../widgets/CustomBottomNavBar.dart';
import '../../widgets/custom_app_bar.dart';
import '../booking/booking_page.dart';
import '../favorites/favorites_page.dart';
import '../hotel_details/hotel_details_page.dart';
import '../notifications/notifications_page.dart';
import '../settings/pages/customer_support_page.dart';
import '../../config/dynamic_config.dart';
import 'package:easy_localization/easy_localization.dart';
import '../history/history_page.dart';

final selectedBookingTypeProvider = StateProvider<int>((ref) => 0);
final selectedLocationsProvider = StateProvider<List<String>>((ref) => []);


class HomePage extends ConsumerWidget {
  HomePage({Key? key}) : super(key: key);

  void _showDailyBookingModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet( 
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DailyBookingModal(),
    );
  }

  void _showMonthlyBookingModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MonthlyBookingModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final primaryColor = dynamicConfig.primaryColor ?? Color(0xFF895ffc);
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: CustomAppBar(
        title: dynamicConfig.appName ?? 'RealInn',
        showBackButton: false,
        onNotificationPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsPage()));
        },

      ),
      body: ListView(
        padding: EdgeInsets.zero, 
        children: [
          // Booking type selector with primary color focus
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showDailyBookingModal(context, ref),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: primaryColor, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'daily_booking'.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showMonthlyBookingModal(context, ref),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: primaryColor, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'monthly_booking'.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Hotels section with primary color accent
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Hotels',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                Spacer(),
                Row(
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        final selectedLocations = ref.watch(selectedLocationsProvider);
                        return ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedLocations.isNotEmpty ? Colors.orange : primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: Size(0, 36),
                          ),
                          icon: Icon(Icons.filter_list, size: 18),
                          label: Text(
                            selectedLocations.isNotEmpty ? 'Filtered (${selectedLocations.length})' : 'Filter',
                            style: TextStyle(fontSize: 12),
                          ),
                          onPressed: () async {
                            final selected = await showModalBottomSheet<List<String>>(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => _LocationFilterModal(),
                            );
                            if (selected != null) {
                              ref.read(selectedLocationsProvider.notifier).state = selected;
                            }
                          },
                        );
                      },
                    ),
                    SizedBox(width: 8),
                    Consumer(
                      builder: (context, ref, child) {
                        final selectedLocations = ref.watch(selectedLocationsProvider);
                        return selectedLocations.isNotEmpty
                            ? ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  minimumSize: Size(0, 36),
                                ),
                                icon: Icon(Icons.clear, size: 18),
                                label: Text('Clear', style: TextStyle(fontSize: 12)),
                                onPressed: () {
                                  ref.read(selectedLocationsProvider.notifier).state = [];
                                },
                              )
                            : SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Hotel categories with their hotels
          Consumer(
              builder: (context, ref, _) {
                final hotelsAsync = ref.watch(hotelProvider);
                final bookingType = ref.watch(selectedBookingTypeProvider);
                final selectedLocations = ref.watch(selectedLocationsProvider);
                return hotelsAsync.when(
                  data: (hotels) {
                    List<Hotel> filteredHotels = hotels;
                    if (selectedLocations.isNotEmpty) {
                      print('Filtering hotels for locations: $selectedLocations');

                      // Get location data to map IDs to names
                      final locationResponse = ref.read(locationProvider).value;
                      final countries = locationResponse?.countries ?? [];
                      final cities = locationResponse?.cities ?? [];
                      final states = locationResponse?.states ?? [];

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
                          amenities: hotel.amenities,
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
                          bool locationMatch = (hotel.location?.toLowerCase() ?? '').contains(loc.toLowerCase());
                          bool categoryMatch = (hotel.category?.toLowerCase() ?? '').contains(loc.toLowerCase());

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

                    // If filtered, show vertical cards in a single list
                    if (selectedLocations.isNotEmpty) {
                      if (filteredHotels.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.hotel_outlined, size: 64, color: Colors.grey[400]),
                              SizedBox(height: 16),
                              Text(
                                'No hotels found for selected locations',
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Try selecting different locations',
                                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        );
                      }

                      // Responsive layout for tablets
                      if (screenWidth > 768) {
                        // Grid layout for tablets - only 2 cards per row
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemCount: filteredHotels.length,
                          itemBuilder: (context, index) {
                            final hotel = filteredHotels[index];
                            return _HotelCardModern(hotel: hotel, bookingType: bookingType);
                          },
                        );
                      } else {
                        // List layout for phones
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          itemCount: filteredHotels.length,
                          separatorBuilder: (_, __) => SizedBox(height: 2),
                          itemBuilder: (context, index) {
                            final hotel = filteredHotels[index];
                            return _HotelCardVertical(hotel: hotel, bookingType: bookingType);
                          },
                        );
                      }
                    }

                    // If not filtered, show horizontal cards grouped by category
                    Map<String, List<Hotel>> hotelsByCategory = {};
                    for (var hotel in filteredHotels) {
                      String category = hotel.category ?? 'Other';
                      if (!hotelsByCategory.containsKey(category)) {
                        hotelsByCategory[category] = [];
                      }
                      hotelsByCategory[category]!.add(hotel);
                    }
                    return Column(
                      children: hotelsByCategory.entries.map((entry) {
                        String category = entry.key;
                        List<Hotel> categoryHotels = entry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category title
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: screenWidth > 768 ? 2 : 4),
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16, 
                                  color: Colors.black,
                                ),
                              ),      
                            ),

                            // Hotels in this category - responsive layout 
                            screenWidth > 768
                                ? GridView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.symmetric(horizontal: 4),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.85,
                                      crossAxisSpacing: 4,
                                      mainAxisSpacing: 4,
                                    ),
                                    itemCount: categoryHotels.length > 2 ? 2 : categoryHotels.length,
                                    itemBuilder: (context, index) {
                                      final hotel = categoryHotels[index];
                                      return _HotelCardModern(hotel: hotel, bookingType: bookingType);
                                    },
                                  )
                                : SizedBox(
                                    height: screenHeight * 0.32,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      itemCount: categoryHotels.length > 4 ? 4 : categoryHotels.length,
                                      separatorBuilder: (_, __) => SizedBox(width: 8),
                                      itemBuilder: (context, index) {
                                        final hotel = categoryHotels[index];
                                        return _HotelCardModern(hotel: hotel, bookingType: bookingType);
                                      },
                                    ),
                                  ),
                            SizedBox(height: screenWidth > 768 ? 4 : 8),
                          ],
                        );
                      }).toList(),
                    );
                  },
                  loading: () => Center(child: CircularProgressIndicator(color: primaryColor)),
                  error: (e, _) => Center(child: Text('Error loading hotels', style: TextStyle(color: Colors.black))),
                );
              },
            ),

          SizedBox(height: screenWidth > 768 ? 10 : 20),
        ],
      ),
    );
  } 
} 
class _HotelCardModern extends ConsumerWidget {
  final Hotel hotel;
  final int bookingType; // 0: يومي، 1: شهري
  const _HotelCardModern({required this.hotel, this.bookingType = 0});

  void _openMaps(double latitude, double longitude, String label) {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    // You can use url_launcher package to open the URL
    print('Opening maps for $label at $latitude, $longitude');
    // For now, just print the URL. You can implement url_launcher later
  }

  String _getImageUrl(Hotel hotel) {
    if (hotel.images?.isNotEmpty == true) {
      return hotel.images!.first;
    }
    return hotel.imageUrl ?? '';
  }

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
    final imageUrl = _getImageUrl(hotel);
    final isFavorite = ref.watch(favoritesProvider).any((h) => h.id == hotel.id);
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final primaryColor = dynamicConfig.primaryColor ?? Color(0xFF895ffc); // Dynamic color
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive card width calculation for tablets
    double cardWidth;
    double imageHeight;
    double cardHeight;
    
    if (screenWidth > 768) { // Tablet
      cardWidth = screenWidth * 0.48; // Two cards per row on tablets with less spacing
      imageHeight = cardWidth * 0.55;
      cardHeight = cardWidth * 1.1; // Reduced height for tablets
    } else if (screenWidth > 600) { // Large phone
      cardWidth = screenWidth * 0.6;
      imageHeight = cardWidth * 0.55;
      cardHeight = cardWidth * 1.3;
    } else { // Small phone
      cardWidth = screenWidth * 0.8;
      imageHeight = cardWidth * 0.6;
      cardHeight = cardWidth * 1.4;
    }
    
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
        height: cardHeight,
        margin: EdgeInsets.only(bottom: screenWidth > 768 ? 2 : 4, right: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Main image - responsive height
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: hotel.imageUrl != null && hotel.imageUrl!.isNotEmpty
                      ? Image.network(
                          hotel.imageUrl!,
                          height: imageHeight,
                          width: cardWidth,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: cardWidth,
                            height: imageHeight,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.hotel, color: Colors.grey[400], size: screenWidth > 768 ? 32 : 48),
                                SizedBox(height: 8),
                                Text(
                                  'Image not available',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: screenWidth > 768 ? 10 : 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: cardWidth,
                              height: imageHeight,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          width: cardWidth,
                          height: imageHeight,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.hotel, color: Colors.grey[400], size: screenWidth > 768 ? 32 : 48),
                              SizedBox(height: 8),
                              Text(
                                'No image available',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: screenWidth > 768 ? 10 : 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                // Gradient overlay for text readability
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ),
                // Hotel name over image
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 8,
                  child: Text(
                    hotel.name ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth > 768 ? 14 : 16,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Enhanced favorite button with primary color
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      if (isFavorite) {
                        ref.read(favoritesProvider.notifier).removeHotel(hotel);
                      } else {
                        ref.read(favoritesProvider.notifier).addHotel(hotel);
                      }
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.all(screenWidth > 768 ? 6 : 10),
                      decoration: BoxDecoration(
                        color: isFavorite ? primaryColor : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.white : primaryColor,
                        size: screenWidth > 768 ? 16 : 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(screenWidth > 768 ? 4 : 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge with primary color
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth > 768 ? 6 : 10, 
                        vertical: screenWidth > 768 ? 2 : 4
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: primaryColor.withOpacity(0.3)),
                      ),
                                              child: Text(
                          hotel.category ?? hotel.location ?? '',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth > 768 ? 11 : 13,
                          ),
                        ),
                    ),
                    SizedBox(height: screenWidth > 768 ? 4 : 6),
                    // Rating and price row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (hotel.rate != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth > 768 ? 6 : 10, 
                              vertical: screenWidth > 768 ? 2 : 4
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  hotel.rate!.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth > 768 ? 12 : 14,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Icon(Icons.star, color: Colors.white, size: screenWidth > 768 ? 12 : 14),
                              ],
                            ),
                          ),
                        Text(
                          getBookingPrice(),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth > 768 ? 14 : 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenWidth > 768 ? 3 : 4),
                    // Location with clickable icon
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (hotel.latitude != null && hotel.longitude != null) {
                              _openMaps(hotel.latitude!, hotel.longitude!, hotel.name ?? 'Hotel');
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: primaryColor,
                              size: screenWidth > 768 ? 10 : 12,
                            ),
                          ),
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hotel.country != null)
                                Text(
                                  hotel.country!,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: screenWidth > 768 ? 10 : 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (hotel.city != null)
                                Text(
                                  hotel.city!,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: screenWidth > 768 ? 11 : 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (hotel.country == null && hotel.city == null)
                                Text(
                                  hotel.location ?? 'Location',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: screenWidth > 768 ? 11 : 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
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

class _HotelCardVertical extends ConsumerWidget {
  final Hotel hotel;
  final int bookingType;
  const _HotelCardVertical({required this.hotel, this.bookingType = 0});

  void _openMaps(double latitude, double longitude, String label) {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    // You can use url_launcher package to open the URL
    print('Opening maps for $label at $latitude, $longitude');
    // For now, just print the URL. You can implement url_launcher later
  }

  String _getImageUrl(Hotel hotel) {
    if (hotel.images?.isNotEmpty == true) {
      return hotel.images!.first;
    }
    return hotel.imageUrl ?? '';
  }

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
    final imageUrl = _getImageUrl(hotel);
    final isFavorite = ref.watch(favoritesProvider).any((h) => h.id == hotel.id);
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final primaryColor = dynamicConfig.primaryColor ?? Color(0xFF895ffc);
    
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
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.hotel, size: 50, color: Colors.grey[600]),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.hotel, size: 50, color: Colors.grey[600]),
                      ),
              ),
            ),
            // Content section
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with name and favorite button
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hotel.name ?? 'Hotel Name',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (isFavorite) {
                            ref.read(favoritesProvider.notifier).removeHotel(hotel);
                          } else {
                            ref.read(favoritesProvider.notifier).addHotel(hotel);
                          }
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isFavorite ? primaryColor : Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.white : Colors.grey[600],
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                                     // Location with clickable icon
                   Row(
                     children: [
                       GestureDetector(
                         onTap: () {
                           if (hotel.latitude != null && hotel.longitude != null) {
                             // Open maps with hotel location
                             _openMaps(hotel.latitude!, hotel.longitude!, hotel.name ?? 'Hotel');
                           }
                         },
                         child: Container(
                           padding: EdgeInsets.all(4),
                           decoration: BoxDecoration(
                             color: primaryColor.withOpacity(0.1),
                             borderRadius: BorderRadius.circular(4),
                           ),
                           child: Icon(
                             Icons.location_on,
                             color: primaryColor,
                             size: 16,
                           ),
                         ),
                       ),
                       SizedBox(width: 8),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             if (hotel.country != null)
                               Text(
                                 hotel.country!,
                                 style: TextStyle(
                                   color: Colors.grey[800],
                                   fontSize: 12,
                                   fontWeight: FontWeight.w500,
                                 ),
                               ),
                             if (hotel.city != null)
                               Text(
                                 hotel.city!,
                                 style: TextStyle(
                                   color: Colors.grey[600],
                                   fontSize: 14,
                                 ),
                               ),
                             if (hotel.country == null && hotel.city == null)
                               Text(
                                 hotel.location ?? 'Location',
                                 style: TextStyle(
                                   color: Colors.grey[600],
                                   fontSize: 14,
                                 ),
                               ),
                           ],
                         ),
                       ),
                     ],
                   ),
                  SizedBox(height: 8),
                  // Category badge
                  if (hotel.category != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: primaryColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        hotel.category!,
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  SizedBox(height: 12),
                  // Bottom row with rating and price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (hotel.rate != null)
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            SizedBox(width: 4),
                            Text(
                              hotel.rate!.toStringAsFixed(1),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      Text(
                        getBookingPrice(),
                        style: TextStyle(
                          color: Colors.green[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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

class _SegmentedControl extends ConsumerStatefulWidget {
  @override
  ConsumerState<_SegmentedControl> createState() => _SegmentedControlState();
}

class _SegmentedControlState extends ConsumerState<_SegmentedControl> {
  int selected = 0;
  @override
  Widget build(BuildContext context) {
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    return Container(
      height: 48,
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: (dynamicConfig.primaryColor ?? Colors.grey).withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        children: [
          _buildTab('Daily', 0),
          SizedBox(width: 8),
          _buildTab('Monthly', 1),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final isSelected = selected == index;
    return Expanded(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
        decoration: BoxDecoration(
          color: isSelected ? (dynamicConfig.primaryColor ?? Colors.grey) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (dynamicConfig.primaryColor ?? Colors.grey).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() => selected = index),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : (dynamicConfig.primaryColor ?? Colors.grey),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchCardV2 extends ConsumerStatefulWidget {
  @override
  ConsumerState<_SearchCardV2> createState() => _SearchCardV2State();
}

class _SearchCardV2State extends ConsumerState<_SearchCardV2> {
  int expandedField = -1; // -1: none, 0: location, 1: checkin, 2: checkout, 3: guests
  String location = 'Abidjan';
  DateTime? checkIn;
  DateTime? checkOut;
  int adults = 0;
  int children = 0;
  int rooms = 0;
  String locationSearch = '';

  void _expandField(int field) {
    setState(() {
      expandedField = expandedField == field ? -1 : field;
    });
  }

  void _selectDate(DateTime date, bool isCheckIn) {
    setState(() {
      if (isCheckIn) {
        checkIn = date;
      } else {
        checkOut = date;
      }
      expandedField = -1;
    });
  }

  void _selectGuests(int a, int c, int r) {
    setState(() {
      adults = a;
      children = c;
      rooms = r;
      expandedField = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 12,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildField(
              icon: Icons.location_on,
              value: location,
              expanded: expandedField == 0,
              onTap: () => _expandField(0),
              child: expandedField == 0
                  ? _LocationDropdown(
                      onSelectLocation: (loc) => setState(() => location = loc.country ?? ''),
                      onSelectHotel: (hotel) => setState(() => location = hotel.location ?? ''),
                      onSearch: (s) => setState(() => locationSearch = s),
                      search: locationSearch,
                    )
                  : null,
            ),
            SizedBox(height: 16),
            _buildField(
              icon: Icons.calendar_today,
              value: checkIn != null ? _formatDate(checkIn!) : 'Checkin date & time',
              expanded: expandedField == 1,
              onTap: () => _expandField(1),
              child: expandedField == 1
                  ? Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ElevatedButton( 
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: checkIn ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(Duration(days: 365)),
                              );
                              if (date != null) {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(checkIn ?? DateTime.now()),
                                );
                                if (time != null) {
                                  final selectedDateTime = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                    time.minute,
                                  );
                                  _selectDate(selectedDateTime, true);
                                }
                              }
                            },
                            child: Text('Select Date & Time'),
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
            SizedBox(height: 16),
            _buildField(
              icon: Icons.calendar_today,
              value: checkOut != null ? _formatDate(checkOut!) : 'Checkout date & time',
              expanded: expandedField == 2,
              onTap: () => _expandField(2),
              child: expandedField == 2
                  ? Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: checkOut ?? DateTime.now().add(Duration(days: 1)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(Duration(days: 365)),
                              );
                              if (date != null) {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(checkOut ?? DateTime.now()),
                                );
                                if (time != null) {
                                  final selectedDateTime = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                    time.minute,
                                  );
                                  _selectDate(selectedDateTime, false);
                                }
                              }
                            },
                            child: Text('Select Date & Time'),
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
            SizedBox(height: 16),
            _buildField(
              icon: Icons.people,
              value: '${adults} Adults. ${children} Children. ${rooms} room',
              expanded: expandedField == 3,
              onTap: () => _expandField(3),
              child: expandedField == 3
                  ? _GuestsGridPicker(
                      adults: adults,
                      children: children,
                      rooms: rooms,
                      onChanged: _selectGuests,
                    )
                  : null,
            ),
            SizedBox(height: 24),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (dynamicConfig.primaryColor ?? Colors.grey),
                    (dynamicConfig.primaryColor ?? Colors.grey).withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (dynamicConfig.primaryColor ?? Colors.grey).withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Center(
                      child: Text(
                        'Search',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({required IconData icon, required String value, String? subtitle, required bool expanded, required VoidCallback onTap, Widget? child}) {
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            decoration: BoxDecoration(
              color: Color(0xFFF6F8FA),
              borderRadius: BorderRadius.circular(16),
              border: expanded ? Border.all(color: (dynamicConfig.primaryColor ?? Colors.grey), width: 1.5) : null,
              boxShadow: expanded ? [
                BoxShadow(
                  color: (dynamicConfig.primaryColor ?? Colors.grey).withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ] : null,
            ),
            child: Row(
              children: [
                Icon(icon, color: (dynamicConfig.primaryColor ?? Colors.grey), size: 22),
                SizedBox(width: 14),
                Expanded(
                  child: subtitle == null
                      ? Text(
                          value,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 2),
                                                            Text(subtitle, style: TextStyle(color: Colors.black, fontSize: 14)),
                          ],
                        ),
                ),
                Icon(expanded ? Icons.expand_less : Icons.expand_more, color: (dynamicConfig.primaryColor ?? Colors.grey)),
              ],
            ),
          ),
        ),
        if (expanded && child != null)
          Container(
            margin: EdgeInsets.only(top: 12),
            decoration: BoxDecoration( 
              color: Colors.white, 
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: child, 
          ),
      ],
    );
  }



  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _LocationDropdown extends ConsumerWidget {
  final void Function(location_model.LocationModel) onSelectLocation;
  final void Function(Hotel) onSelectHotel;
  final void Function(String) onSearch;
  final String search;
  const _LocationDropdown({required this.onSelectLocation, required this.onSelectHotel, required this.onSearch, required this.search});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(locationProvider);
    final hotelsAsync = ref.watch(hotelProvider);
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search country or city',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            onChanged: onSearch,
          ),
        ),
        locationsAsync.when(
          data: (locationResponse) {
            final countries = locationResponse.countries ?? [];
            final cities = locationResponse.cities ?? [];
            final hotels = locationResponse.hotels ?? [];
            
            // Filter countries and cities based on search
            final filteredCountries = countries.where((country) =>
              (country.name ?? '').toLowerCase().contains(search.toLowerCase())
            ).toList();
            
            final filteredCities = cities.where((city) =>
              (city.name ?? '').toLowerCase().contains(search.toLowerCase())
            ).toList();
            
            return Column(
              children: [
                if (filteredCountries.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text('Countries', style: TextStyle(fontWeight: FontWeight.bold, color: (dynamicConfig.primaryColor ?? Colors.grey))),
                  ),
                                     ...filteredCountries.map((country) {
                     // Count hotels in this country
                     final hotelCount = hotels.where((hotel) => 
                       hotel.countryId == country.id
                     ).length;
                    
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 40,
                          height: 40,
                          color: (dynamicConfig.primaryColor ?? Colors.grey).withOpacity(0.1),
                          child: Icon(Icons.location_on, color: (dynamicConfig.primaryColor ?? Colors.grey), size: 20),
                        ),
                      ),
                      title: Text(country.name ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Country'),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (dynamicConfig.primaryColor ?? Colors.grey).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.hotel, size: 14, color: (dynamicConfig.primaryColor ?? Colors.grey)),
                            SizedBox(width: 4),
                            Text(
                              '$hotelCount',
                              style: TextStyle(
                                color: (dynamicConfig.primaryColor ?? Colors.grey),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () => onSelectLocation(location_model.LocationModel(
                        country: country.name,
                        capital: 'Country',
                        numberOfHotels: hotelCount,
                        image: null,
                      )),
                    );
                  }).toList(),
                ],
                if (filteredCities.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text('Cities', style: TextStyle(fontWeight: FontWeight.bold, color: (dynamicConfig.primaryColor ?? Colors.grey))),
                  ),
                                     ...filteredCities.map((city) {
                     // Count hotels in this city
                     final hotelCount = hotels.where((hotel) => 
                       hotel.cityId == city.id
                     ).length;
                    
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 40,
                          height: 40,
                          color: (dynamicConfig.primaryColor ?? Colors.grey).withOpacity(0.1),
                          child: Icon(Icons.location_city, color: (dynamicConfig.primaryColor ?? Colors.grey), size: 20),
                        ),
                      ),
                      title: Text(city.name ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('City'),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (dynamicConfig.primaryColor ?? Colors.grey).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.hotel, size: 14, color: (dynamicConfig.primaryColor ?? Colors.grey)),
                            SizedBox(width: 4),
                            Text(
                              '$hotelCount',
                              style: TextStyle(
                                color: (dynamicConfig.primaryColor ?? Colors.grey),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () => onSelectLocation(location_model.LocationModel(
                        country: city.name,
                        capital: 'City',
                        numberOfHotels: hotelCount,
                        image: null,
                      )),
                    );
                  }).toList(),
                ],
              ],
            );
          },
          loading: () => Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading locations')),
        ),
      ],
    );
  }
}

// Remove the entire DateTimeGridPicker widget and replace with a simple date picker
class _GuestsGridPicker extends ConsumerStatefulWidget {
  final int adults;
  final int children;
  final int rooms;
  final void Function(int, int, int) onChanged;
  const _GuestsGridPicker({required this.adults, required this.children, required this.rooms, required this.onChanged});
  @override
  ConsumerState<_GuestsGridPicker> createState() => _GuestsGridPickerState();
}

class _GuestsGridPickerState extends ConsumerState<_GuestsGridPicker> {
  late int adults;
  late int children;
  late int rooms;
  @override
  void initState() {
    super.initState();
    adults = widget.adults;
    children = widget.children;
    rooms = widget.rooms;
  }
  @override
  Widget build(BuildContext context) {
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCounter('Adults', adults, (v) => setState(() => adults = v)),
              _buildCounter('Children', children, (v) => setState(() => children = v)),
              _buildCounter('Rooms', rooms, (v) => setState(() => rooms = v)),
            ],
          ),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => widget.onChanged(adults, children, rooms),
            child: Text('Done'),
            style: ElevatedButton.styleFrom(
              backgroundColor: (dynamicConfig.primaryColor ?? Colors.grey),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCounter(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove_circle_outline),
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
            ),
            Text('$value', style: TextStyle(fontSize: 16)),
            IconButton(
              icon: Icon(Icons.add_circle_outline),
              onPressed: () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }
}

// Helper function for hotel filtering
List<Hotel> _filterHotelsByLocation(List<Hotel> hotels, String? selectedLocation) {
  if (selectedLocation == null) return hotels;
  
  return hotels.where((hotel) {
    final location = selectedLocation.toLowerCase().trim();
    final hotelCountry = hotel.country?.toLowerCase().trim() ?? '';
    final hotelCity = hotel.city?.toLowerCase().trim() ?? '';
    final hotelState = hotel.state?.toLowerCase().trim() ?? '';
    final hotelLocation = hotel.location?.toLowerCase().trim() ?? '';
    final hotelCategory = hotel.category?.toLowerCase().trim() ?? '';
    
    // Debug logging
    print('Filtering hotel: ${hotel.name}');
    print('Selected location: $location');
    print('Hotel country: $hotelCountry');
    print('Hotel city: $hotelCity');
    print('Hotel state: $hotelState');
    print('Hotel location: $hotelLocation');
    print('Hotel category: $hotelCategory');
    
    return hotelCountry.contains(location) ||
           hotelCity.contains(location) ||
           hotelState.contains(location) ||
           hotelLocation.contains(location) ||
           hotelCategory.contains(location);
  }).toList();
}

// Helper function for Daily booking modal
List<Hotel> _filterHotelsForDailyBooking(List<Hotel> hotels, String? selectedCity, WidgetRef ref) {
  if (selectedCity == null) return hotels;
  
  print('Daily Booking - Total hotels before filtering: ${hotels.length}');
  print('Daily Booking - Selected city: $selectedCity');
  
  return hotels.where((hotel) {
    // Get city ID from location data
    final locationResponse = ref.read(locationProvider).value;
    final selectedCityData = locationResponse?.cities
        ?.firstWhere((c) => c.name == selectedCity, orElse: () => location_model.City());
    final selectedCityId = selectedCityData?.id;
    
    print('Daily Booking - Filtering hotel: ${hotel.name}');
    print('Daily Booking - Hotel city_id: ${hotel.cityId}');
    print('Daily Booking - Selected city_id: $selectedCityId');
    
    // Match by city_id first, then fallback to name matching
    final matches = (hotel.cityId == selectedCityId) ||
                   (hotel.city?.toLowerCase().trim() == selectedCity.toLowerCase().trim());
    
    print('Daily Booking - Hotel ${hotel.name} matches: $matches');
    return matches;
  }).toList();
}

// Helper function for Monthly booking modal
List<Hotel> _filterHotelsForMonthlyBooking(List<Hotel> hotels, String? selectedCity, WidgetRef ref) {
  if (selectedCity == null) return hotels;
  
  print('Monthly Booking - Total hotels before filtering: ${hotels.length}');
  print('Monthly Booking - Selected city: $selectedCity');
  
  return hotels.where((hotel) {
    // Get city ID from location data
    final locationResponse = ref.read(locationProvider).value;
    final selectedCityData = locationResponse?.cities
        ?.firstWhere((c) => c.name == selectedCity, orElse: () => location_model.City());
    final selectedCityId = selectedCityData?.id;
    
    print('Monthly Booking - Filtering hotel: ${hotel.name}');
    print('Monthly Booking - Hotel city_id: ${hotel.cityId}'); 
    print('Monthly Booking - Selected city_id: $selectedCityId');
    
    // Match by city_id first, then fallback to name matching
    final matches = (hotel.cityId == selectedCityId) ||
                   (hotel.city?.toLowerCase().trim() == selectedCity.toLowerCase().trim());
    
    print('Monthly Booking - Hotel ${hotel.name} matches: $matches');
    return matches;
  }).toList();
}

// Daily Booking Modal 
class _DailyBookingModal extends ConsumerStatefulWidget {
  @override
  ConsumerState<_DailyBookingModal> createState() => _DailyBookingModalState();
}

class _DailyBookingModalState extends ConsumerState<_DailyBookingModal> {
  int currentStep = 0;
  String? selectedCountry;
  String? selectedCity;
  String? selectedHotel;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String locationSearchQuery = '';

  @override
  Widget build(BuildContext context) {
    final primaryColor = ref.watch(dynamicConfigProvider).primaryColor ?? Color(0xFF895ffc);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Text(
                  'Daily Booking',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Progress indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: List.generate(4, (index) => Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: index <= currentStep ? primaryColor : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              )),
            ),
          ),
          
          // Content
          Flexible(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: _buildStepContent(),
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                if (currentStep > 0)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => currentStep--),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                      ),
                      child: Text('Back'),
                    ),
                  ),
                if (currentStep > 0) SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canProceed() ? _nextStep : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(currentStep == 3 ? 'Finish' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case 0:
        return _buildCountryStep();
      case 1:
        return _buildCityStep();
      case 2:
        return _buildHotelStep();
      case 3:
        return _buildTimeStep();
      default:
        return Container();
    }
  }

  Widget _buildCountryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Country',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        SizedBox(height: 16),
        // Search field
        TextField(
          decoration: InputDecoration(
            hintText: 'Search for countries...',
            prefixIcon: Icon(Icons.search, color: Colors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) => setState(() => locationSearchQuery = value.toLowerCase()),
        ),
        SizedBox(height: 16),
        Flexible(
          child: Consumer(
            builder: (context, ref, child) {
              final locationResponseAsync = ref.watch(locationProvider);
              return locationResponseAsync.when(
                data: (locationResponse) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Show All Hotels option
                    ListTile(
                      leading: Icon(Icons.hotel, color: Colors.black),
                      title: Text('Show All Hotels', style: TextStyle(color: Colors.black)),
                      subtitle: Text('Skip location filtering'),
                      selected: selectedCountry == null,
                      selectedTileColor: selectedCountry == null ? Colors.blue.withOpacity(0.15) : Colors.grey[100],
                      onTap: () => setState(() => selectedCountry = null),
                    ),
                    Divider(),
                    // Countries list
                    if (locationResponse.countries?.isNotEmpty == true) ...[
                      Text(
                        'Countries',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 8),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: locationResponse.countries!.length,
                          itemBuilder: (context, index) {
                            final country = locationResponse.countries![index];
                            final countryName = country.name ?? '';
                            if (locationSearchQuery.isNotEmpty && 
                                !countryName.toLowerCase().contains(locationSearchQuery)) {
                              return SizedBox.shrink();
                            }
                            
                            // Count hotels in this country
                            final hotelCount = locationResponse.hotels?.where((hotel) => 
                              hotel.countryId == country.id
                            ).length ?? 0;
                            
                            return ListTile(
                              leading: Icon(Icons.location_on, color: Colors.black),
                              title: Text(countryName, style: TextStyle(color: Colors.black)),
                              subtitle: Text('Country'),
                              trailing: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.hotel, size: 14, color: Colors.blue),
                                    SizedBox(width: 4),
                                    Text(
                                      '$hotelCount',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              selected: selectedCountry == countryName,
                              selectedTileColor: selectedCountry == countryName ? Colors.blue.withOpacity(0.15) : Colors.grey[100],
                              onTap: () => setState(() => selectedCountry = countryName),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
                loading: () => Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error loading countries', style: TextStyle(color: Colors.black)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select City',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        if (selectedCountry != null)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Cities in $selectedCountry',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        SizedBox(height: 16),
        // Search field
        TextField(
          decoration: InputDecoration(
            hintText: 'Search for cities...',
            prefixIcon: Icon(Icons.search, color: Colors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) => setState(() => locationSearchQuery = value.toLowerCase()),
        ),
        SizedBox(height: 16),
        Flexible(
          child: Consumer(
            builder: (context, ref, child) {
              final locationResponseAsync = ref.watch(locationProvider);
              return locationResponseAsync.when(
                data: (locationResponse) {
                  // Find the selected country ID
                  final selectedCountryId = locationResponse.countries
                      ?.firstWhere((c) => c.name == selectedCountry, orElse: () => location_model.Country())
                      .id;
                  
                  // Filter cities by selected country
                  final citiesInCountry = locationResponse.cities
                      ?.where((city) => city.countryId == selectedCountryId)
                      .toList() ?? [];
                  
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Show All Hotels option
                      ListTile(
                        leading: Icon(Icons.hotel, color: Colors.black),
                        title: Text('Show All Hotels', style: TextStyle(color: Colors.black)),
                        subtitle: Text('Skip location filtering'),
                        selected: selectedCity == null,
                        selectedTileColor: selectedCity == null ? Colors.blue.withOpacity(0.15) : Colors.grey[100],
                        onTap: () => setState(() => selectedCity = null),
                      ),
                      Divider(),
                      // Cities list
                      if (citiesInCountry.isNotEmpty) ...[
                        Text(
                          'Cities in $selectedCountry',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        SizedBox(height: 8),
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: citiesInCountry.length,
                            itemBuilder: (context, index) {
                              final city = citiesInCountry[index];
                              final cityName = city.name ?? '';
                              if (locationSearchQuery.isNotEmpty && 
                                  !cityName.toLowerCase().contains(locationSearchQuery)) {
                                return SizedBox.shrink();
                              }
                              
                              // Count hotels in this city
                              final hotelCount = locationResponse.hotels?.where((hotel) => 
                                hotel.cityId == city.id
                              ).length ?? 0;
                              
                              return ListTile(
                                leading: Icon(Icons.location_city, color: Colors.black),
                                title: Text(cityName, style: TextStyle(color: Colors.black)),
                                subtitle: Text('City'),
                                trailing: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.hotel, size: 14, color: Colors.blue),
                                      SizedBox(width: 4),
                                      Text(
                                        '$hotelCount',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                selected: selectedCity == cityName,
                                selectedTileColor: selectedCity == cityName ? Colors.blue.withOpacity(0.15) : Colors.grey[100],
                                onTap: () => setState(() => selectedCity = cityName),
                              );
                            },
                          ),
                        ),
                      ] else ...[
                        Flexible(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_city_outlined, size: 64, color: Colors.grey[400]),
                                SizedBox(height: 16),
                                Text(
                                  'No cities found in $selectedCountry',
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Try selecting a different country',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
                loading: () => Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error loading cities', style: TextStyle(color: Colors.black)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHotelStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Hotel',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        if (selectedCity != null)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Hotels in $selectedCity',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        SizedBox(height: 16),
        Flexible(
          child: Consumer(
            builder: (context, ref, child) {
              final hotelsAsync = ref.watch(hotelProvider);
              return hotelsAsync.when(
                data: (hotels) {
                  // Filter hotels based on selected location using helper function
                  final filteredHotels = _filterHotelsForDailyBooking(hotels, selectedCity, ref);
                  
                  if (filteredHotels.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.hotel_outlined, size: 64, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text(
                            selectedCity != null 
                                ? 'No hotels found in $selectedCity'
                                : 'No hotels available',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Total hotels loaded: ${hotels.length}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          ),
                          if (selectedCity != null) ...[
                            SizedBox(height: 8),
                            Text(
                              'Try selecting a different city or check if hotels have location data',
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => setState(() => selectedCity = null),
                              child: Text('Show All Hotels'),
                            ),
                          ],
                        ],
                      ),
                    );
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary header
                      Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedCity != null 
                                    ? 'Found ${filteredHotels.length} hotels in "$selectedCity"'
                                    : 'Showing all ${filteredHotels.length} hotels',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredHotels.length,
                          itemBuilder: (context, index) {
                            final hotel = filteredHotels[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[200],
                                child: hotel.imageUrl != null && hotel.imageUrl!.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          hotel.imageUrl!,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Icon(
                                            Icons.hotel,
                                            color: Colors.black,
                                            size: 20,
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.hotel,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                              ),
                              title: Text(hotel.name ?? '', style: TextStyle(color: Colors.black)),
                              subtitle: Text(hotel.city ?? hotel.country ?? hotel.category ?? hotel.location ?? '', style: TextStyle(color: Colors.black)),
                              selected: selectedHotel == hotel.name,
                              selectedTileColor: Colors.grey[100],
                              onTap: () => setState(() => selectedHotel = hotel.name),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error loading hotels', style: TextStyle(color: Colors.black)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Time Range',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        SizedBox(height: 16),
        // Start Time Selection
        ListTile(
          leading: Icon(Icons.access_time, color: Colors.black),
          title: Text('Start Time', style: TextStyle(color: Colors.black)),
          subtitle: Text(
            startTime != null 
                ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}'
                : 'Select start time',
            style: TextStyle(color: Colors.grey[600]),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: startTime ?? TimeOfDay.now(),
            );
            if (time != null) {
              setState(() => startTime = time);
            }
          },
        ),
        Divider(),
        // End Time Selection
        ListTile(
          leading: Icon(Icons.access_time_filled, color: Colors.black),
          title: Text('End Time', style: TextStyle(color: Colors.black)),
          subtitle: Text(
            endTime != null 
                ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}'
                : 'Select end time',
            style: TextStyle(color: Colors.grey[600]),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: endTime ?? (startTime ?? TimeOfDay.now()),
            );
            if (time != null) {
              setState(() => endTime = time);
            }
          },
        ),
        SizedBox(height: 16),
        // Quick time presets
        Text(
          'Quick Presets',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTimePreset('Morning', TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 12, minute: 0)),
            _buildTimePreset('Afternoon', TimeOfDay(hour: 12, minute: 0), TimeOfDay(hour: 17, minute: 0)),
            _buildTimePreset('Evening', TimeOfDay(hour: 17, minute: 0), TimeOfDay(hour: 21, minute: 0)),
            _buildTimePreset('Night', TimeOfDay(hour: 21, minute: 0), TimeOfDay(hour: 23, minute: 0)),
          ],
        ),
      ],
    );
  }

  Widget _buildTimePreset(String label, TimeOfDay start, TimeOfDay end) {
    final isSelected = startTime == start && endTime == end;
    return GestureDetector(
      onTap: () => setState(() {
        startTime = start;
        endTime = end;
      }),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (currentStep) {
      case 0:
        return selectedCountry != null;
      case 1:
        return selectedCity != null;
      case 2:
        return selectedHotel != null;
      case 3:
        return startTime != null && endTime != null;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (currentStep < 3) {
      setState(() => currentStep++);
    } else {
      // Create booking and add to booking page
      _createBooking();
    }
  }

  void _createBooking() {
    // Find the selected hotel
    final hotelsAsync = ref.read(hotelProvider);
    hotelsAsync.whenData((hotels) {
      final selectedHotelData = hotels.firstWhere(
        (hotel) => hotel.name == selectedHotel,
        orElse: () => hotels.first,
      );

      // Create booking with time information
      final checkInDateTime = DateTime.now().copyWith(
        hour: startTime?.hour ?? 9,
        minute: startTime?.minute ?? 0,
      );
      
      final checkOutDateTime = DateTime.now().copyWith(
        hour: endTime?.hour ?? 17,
        minute: endTime?.minute ?? 0,
      );

      final booking = Booking(
        hotel: selectedHotelData,
        checkIn: checkInDateTime,
        checkOut: checkOutDateTime,
        adults: 1,
        children: 0,
        rooms: 1,
      );

      // Add to booking provider
      ref.read(bookingsProvider.notifier).addBooking(booking);

      // Show success message and navigate
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Daily booking added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }
}

// Monthly Booking Modal
class _MonthlyBookingModal extends ConsumerStatefulWidget {
  @override
  ConsumerState<_MonthlyBookingModal> createState() => _MonthlyBookingModalState();
}

class _MonthlyBookingModalState extends ConsumerState<_MonthlyBookingModal> {
  int currentStep = 0;
  DateTime? startDate;
  DateTime? endDate;
  String? selectedCountry;
  String? selectedCity;
  String? selectedHotel;
  String locationSearchQuery = '';

  @override
  Widget build(BuildContext context) {
    final primaryColor = ref.watch(dynamicConfigProvider).primaryColor ?? Color(0xFF895ffc);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Text(
                  'Monthly Booking',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Progress indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: List.generate(4, (index) => Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: index <= currentStep ? primaryColor : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              )),
            ),
          ),
          
          // Content
          Flexible(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: _buildStepContent(),
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                if (currentStep > 0)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => currentStep--),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                      ),
                      child: Text('Back'),
                    ),
                  ),
                if (currentStep > 0) SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canProceed() ? _nextStep : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(currentStep == 3 ? 'Finish' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case 0:
        return _buildDateStep();
      case 1:
        return _buildCountryStep();
      case 2:
        return _buildCityStep();
      case 3:
        return _buildHotelStep();
      default:
        return Container();
    }
  }

  Widget _buildDateStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Dates',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        SizedBox(height: 16),
        ListTile(
          leading: Icon(Icons.calendar_today, color: Colors.black),
          title: Text('Start Date', style: TextStyle(color: Colors.black)),
          subtitle: Text(startDate?.toString().split(' ')[0] ?? 'Select start date', style: TextStyle(color: Colors.black)),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );
            if (date != null) {
              setState(() => startDate = date);
            }
          },
        ),
        ListTile(
          leading: Icon(Icons.calendar_today, color: Colors.black),
          title: Text('End Date', style: TextStyle(color: Colors.black)),
          subtitle: Text(endDate?.toString().split(' ')[0] ?? 'Select end date', style: TextStyle(color: Colors.black)),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: startDate ?? DateTime.now(),
              firstDate: startDate ?? DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );
            if (date != null) {
              setState(() => endDate = date);
            }
          },
        ),
      ],
    );
  }

  Widget _buildCountryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Country',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        SizedBox(height: 16),
        // Search field
        TextField(
          decoration: InputDecoration(
            hintText: 'Search for countries...',
            prefixIcon: Icon(Icons.search, color: Colors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) => setState(() => locationSearchQuery = value.toLowerCase()),
        ),
        SizedBox(height: 16),
        Flexible(
          child: Consumer(
            builder: (context, ref, child) {
              final locationResponseAsync = ref.watch(locationProvider);
              return locationResponseAsync.when(
                data: (locationResponse) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Show All Hotels option
                    ListTile(
                      leading: Icon(Icons.hotel, color: Colors.black),
                      title: Text('Show All Hotels', style: TextStyle(color: Colors.black)),
                      subtitle: Text('Skip location filtering'),
                      selected: selectedCountry == null,
                      selectedTileColor: selectedCountry == null ? Colors.blue.withOpacity(0.15) : Colors.grey[100],
                      onTap: () => setState(() => selectedCountry = null),
                    ),
                    Divider(),
                    // Countries list
                    if (locationResponse.countries?.isNotEmpty == true) ...[
                      Text(
                        'Countries',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 8),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: locationResponse.countries!.length,
                          itemBuilder: (context, index) {
                            final country = locationResponse.countries![index];
                            final countryName = country.name ?? '';
                            if (locationSearchQuery.isNotEmpty && 
                                !countryName.toLowerCase().contains(locationSearchQuery)) {
                              return SizedBox.shrink();
                            }
                            
                            // Count hotels in this country
                            final hotelCount = locationResponse.hotels?.where((hotel) => 
                              hotel.countryId == country.id
                            ).length ?? 0;
                            
                            return ListTile(
                              leading: Icon(Icons.location_on, color: Colors.black),
                              title: Text(countryName, style: TextStyle(color: Colors.black)),
                              subtitle: Text('Country'),
                              trailing: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.hotel, size: 14, color: Colors.blue),
                                    SizedBox(width: 4),
                                    Text(
                                      '$hotelCount',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              selected: selectedCountry == countryName,
                              selectedTileColor: selectedCountry == countryName ? Colors.blue.withOpacity(0.15) : Colors.grey[100],
                              onTap: () => setState(() => selectedCountry = countryName),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
                loading: () => Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error loading countries', style: TextStyle(color: Colors.black)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select City',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        if (selectedCountry != null)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Cities in $selectedCountry',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        SizedBox(height: 16),
        // Search field
        TextField(
          decoration: InputDecoration( 
            hintText: 'Search for cities...',
            prefixIcon: Icon(Icons.search, color: Colors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) => setState(() => locationSearchQuery = value.toLowerCase()),
        ),
        SizedBox(height: 16),
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final locationResponseAsync = ref.watch(locationProvider);
              return locationResponseAsync.when(
                data: (locationResponse) {
                  // Find the selected country ID
                  final selectedCountryId = locationResponse.countries
                      ?.firstWhere((c) => c.name == selectedCountry, orElse: () => location_model.Country())
                      .id;
                  
                  // Filter cities by selected country
                  final citiesInCountry = locationResponse.cities
                      ?.where((city) => city.countryId == selectedCountryId)
                      .toList() ?? [];
                  
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Show All Hotels option
                      ListTile(
                        leading: Icon(Icons.hotel, color: Colors.black),
                        title: Text('Show All Hotels', style: TextStyle(color: Colors.black)),
                        subtitle: Text('Skip location filtering'),
                        selected: selectedCity == null,
                        selectedTileColor: selectedCity == null ? Colors.blue.withOpacity(0.15) : Colors.grey[100],
                        onTap: () => setState(() => selectedCity = null),
                      ),
                      Divider(),
                      // Cities list
                      if (citiesInCountry.isNotEmpty) ...[
                        Text(
                          'Cities in $selectedCountry',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        SizedBox(height: 8),
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: citiesInCountry.length,
                            itemBuilder: (context, index) {
                              final city = citiesInCountry[index];
                              final cityName = city.name ?? '';
                              if (locationSearchQuery.isNotEmpty && 
                                  !cityName.toLowerCase().contains(locationSearchQuery)) {
                                return SizedBox.shrink();
                              }
                              
                              // Count hotels in this city
                              final hotelCount = locationResponse.hotels?.where((hotel) => 
                                hotel.cityId == city.id
                              ).length ?? 0;
                              
                              return ListTile(
                                leading: Icon(Icons.location_city, color: Colors.black),
                                title: Text(cityName, style: TextStyle(color: Colors.black)),
                                subtitle: Text('City'),
                                trailing: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.hotel, size: 14, color: Colors.blue),
                                      SizedBox(width: 4),
                                      Text(
                                        '$hotelCount',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                selected: selectedCity == cityName,
                                selectedTileColor: selectedCity == cityName ? Colors.blue.withOpacity(0.15) : Colors.grey[100],
                                onTap: () => setState(() => selectedCity = cityName),
                              );
                            },
                          ),
                        ),
                      ] else ...[
                        Flexible(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_city_outlined, size: 64, color: Colors.grey[400]),
                                SizedBox(height: 16),
                                Text(
                                  'No cities found in $selectedCountry',
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Try selecting a different country',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
                loading: () => Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error loading cities', style: TextStyle(color: Colors.black)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHotelStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Hotel',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        if (selectedCity != null)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Hotels in $selectedCity',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        SizedBox(height: 16),
        Flexible(
          child: Consumer(
            builder: (context, ref, child) {
              final hotelsAsync = ref.watch(hotelProvider);
              return hotelsAsync.when(
                data: (hotels) {
                  // Filter hotels based on selected location using helper function
                  final filteredHotels = _filterHotelsForMonthlyBooking(hotels, selectedCity, ref);
                  
                  if (filteredHotels.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.hotel_outlined, size: 64, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text(
                            selectedCity != null 
                                ? 'No hotels found in $selectedCity'
                                : 'No hotels available',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Total hotels loaded: ${hotels.length}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          ),
                          if (selectedCity != null) ...[
                            SizedBox(height: 8),
                            Text(
                              'Try selecting a different city or check if hotels have location data',
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => setState(() => selectedCity = null),
                              child: Text('Show All Hotels'),
                            ),
                          ],
                        ],
                      ),
                    );
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary header
                      Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedCity != null 
                                    ? 'Found ${filteredHotels.length} hotels in "$selectedCity"'
                                    : 'Showing all ${filteredHotels.length} hotels',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredHotels.length,
                          itemBuilder: (context, index) {
                            final hotel = filteredHotels[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[200],
                                child: hotel.imageUrl != null && hotel.imageUrl!.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          hotel.imageUrl!,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Icon(
                                            Icons.hotel,
                                            color: Colors.black,
                                            size: 20,
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.hotel,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                              ),
                              title: Text(hotel.name ?? '', style: TextStyle(color: Colors.white)),
                              subtitle: Text(hotel.city ?? hotel.country ?? hotel.category ?? hotel.location ?? '', style: TextStyle(color: Colors.black)),
                              selected: selectedHotel == hotel.name,
                              selectedTileColor: Colors.grey[100],
                              onTap: () => setState(() => selectedHotel = hotel.name),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error loading hotels', style: TextStyle(color: Colors.black)),
              );
            },
          ),
        ),
      ],
    );
  }



  bool _canProceed() {
    switch (currentStep) {
      case 0:
        return startDate != null && endDate != null;
      case 1:
        return selectedCountry != null;
      case 2:
        return selectedCity != null;
      case 3:
        return selectedHotel != null;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (currentStep < 3) {
      setState(() => currentStep++);
    } else {
      // Create booking and add to booking page
      _createBooking();
    }
  }

  void _createBooking() {
    // Find the selected hotel
    final hotelsAsync = ref.read(hotelProvider);
    hotelsAsync.whenData((hotels) {
      final selectedHotelData = hotels.firstWhere(
        (hotel) => hotel.name == selectedHotel,
        orElse: () => hotels.first,
      );

      // Create booking with default values
      final booking = Booking(
        hotel: selectedHotelData,
        checkIn: startDate!,
        checkOut: endDate!,
        adults: 1,
        children: 0,
        rooms: 1,
      );

      // Add to booking provider
      ref.read(bookingsProvider.notifier).addBooking(booking);

      // Show success message and navigate
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Monthly booking added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }
}

class _LocationFilterModal extends ConsumerStatefulWidget {
  @override
  ConsumerState<_LocationFilterModal> createState() => _LocationFilterModalState();
}

class _LocationFilterModalState extends ConsumerState<_LocationFilterModal> {
  List<String> selected = [];
  String? selectedCountry;
  List<String> selectedCities = [];
  
  @override
  Widget build(BuildContext context) {
    final locationResponseAsync = ref.watch(locationProvider);
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (selectedCountry != null)
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => setState(() {
                      selectedCountry = null;
                      selectedCities.clear();
                    }),
                  ),
                Expanded(
                  child: Text(
                    selectedCountry != null ? 'Select Cities in $selectedCountry' : 'Filter by Location',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            locationResponseAsync.when(
              data: (locationResponse) {
                final countries = locationResponse.countries ?? [];
                final cities = locationResponse.cities ?? [];
                final hotels = locationResponse.hotels ?? [];
                
                // Debug prints
                print('Loaded data:');
                print('- Countries: ${countries.length}');
                print('- Cities: ${cities.length}');
                print('- Hotels: ${hotels.length}');
                
                if (countries.isNotEmpty) {
                  print('Sample country: ${countries.first.toJson()}');
                }
                if (cities.isNotEmpty) {
                  print('Sample city: ${cities.first.toJson()}');
                }
                if (hotels.isNotEmpty) {
                  print('Sample hotel: ${hotels.first.toJson()}');
                  print('Hotel fields:');
                  print('- countryId: ${hotels.first.countryId}');
                  print('- stateId: ${hotels.first.stateId}');
                  print('- cityId: ${hotels.first.cityId}');
                  print('- country: ${hotels.first.country}');
                  print('- state: ${hotels.first.state}');
                  print('- city: ${hotels.first.city}');
                }
                
                if (selectedCountry != null) {
                  // Show cities for selected country
                  final selectedCountryObj = countries.firstWhere(
                    (c) => c.name == selectedCountry,
                    orElse: () => location_model.Country(),
                  );
                  print('Selected country: ${selectedCountryObj.toJson()}');
                  
                  final countryCities = cities.where((city) {
                    print('Checking city: ${city.name} (countryId: ${city.countryId}) against selected country ID: ${selectedCountryObj.id}');
                    // Try exact match first
                    if (city.countryId == selectedCountryObj.id) return true;
                    // Fallback to name matching if IDs don't match
                    if (city.name != null && selectedCountryObj.name != null) {
                      // This is a fallback - cities don't typically have country names, but we can check
                      return false; // Skip this fallback for cities
                    }
                    return false;
                  }).toList();
                  
                  print('Found ${countryCities.length} cities for country ${selectedCountry}');
                  
                  return Expanded(
                    child: Column(
                      children: [
                        // Show selected country
                        Container(
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'Country: $selectedCountry',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: countryCities.length,
                            itemBuilder: (context, index) {
                              final city = countryCities[index];
                              final hotelCount = hotels.where((hotel) {
                                // Debug print to see the values
                                print('Comparing hotel.cityId: ${hotel.cityId} (${hotel.cityId.runtimeType}) with city.id: ${city.id} (${city.id.runtimeType})');
                                // Try exact match first
                                if (hotel.cityId == city.id) return true;
                                // Fallback to name matching if IDs don't match
                                if (hotel.city != null && city.name != null) {
                                  return hotel.city!.toLowerCase() == city.name!.toLowerCase();
                                }
                                return false;
                              }).length;
                              
                              final isSelected = selectedCities.contains(city.name ?? '');
                              return ListTile(
                                leading: Icon(Icons.location_city, color: Colors.black),
                                title: Text(city.name ?? ''),
                                subtitle: Text('$hotelCount hotels'),
                                trailing: isSelected
                                  ? Icon(Icons.check_box, color: Theme.of(context).primaryColor)
                                  : Icon(Icons.check_box_outline_blank),
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      selectedCities.remove(city.name ?? '');
                                    } else {
                                      selectedCities.add(city.name ?? '');
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Show countries
                  return Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: countries.length,
                      itemBuilder: (context, index) {
                        final country = countries[index];
                        final hotelCount = hotels.where((hotel) {
                          // Debug print to see the values
                          print('Comparing hotel.countryId: ${hotel.countryId} (${hotel.countryId.runtimeType}) with country.id: ${country.id} (${country.id.runtimeType})');
                          // Try exact match first
                          if (hotel.countryId == country.id) return true;
                          // Fallback to name matching if IDs don't match
                          if (hotel.country != null && country.name != null) {
                            return hotel.country!.toLowerCase() == country.name!.toLowerCase();
                          }
                          return false;
                        }).length;
                        
                        return ListTile(
                          leading: Icon(Icons.location_on, color: Colors.black),
                          title: Text(country.name ?? ''),
                          subtitle: Text('$hotelCount hotels'),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            setState(() {
                              selectedCountry = country.name;
                            });
                          },
                        );
                      },
                    ),
                  );
                }
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (e, _) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error loading locations: $e'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(locationProvider),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                    ),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final selectedLocations = selectedCountry != null 
                          ? selectedCities 
                          : selected;
                      Navigator.pop(context, selectedLocations);
                    },
                    child: Text('Apply Filter'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}







