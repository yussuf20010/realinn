import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realinn/pages/home/search_results_page.dart';
import '../../config/dynamic_config.dart';
import '../../controllers/hotel_controller.dart';
import '../../controllers/location_controller.dart';
import '../../widgets/custom_app_bar.dart';
import '../notifications/notifications_page.dart';
import 'components/promotional_cards.dart';
import 'components/more_for_you_section.dart';
import 'components/hotels_section_header.dart';
import 'components/hotels_list.dart';
import 'components/mobile_search_card.dart';
import 'components/tablet_search_card.dart';
import 'providers/home_providers.dart';
import '../../config/wp_config.dart';
import '../../models/hotel.dart';
import '../../models/location.dart' as location_model;

class HomePage extends ConsumerWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final primaryColor = WPConfig.navbarColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: dynamicConfig.appName ?? 'RealInn',
        showBackButton: false,
        onNotificationPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsPage()));
        },
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        child: _buildLayout(context, ref),
      ),
    );
  }

  Widget _buildLayout(BuildContext context, WidgetRef ref) {
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Column(
      children: [
        // Daily/Monthly booking selector

        if (isTablet)
          TabletSearchCard(
            onDailyBookingTap: () {
              ref.read(selectedBookingTypeProvider.notifier).state = 0;
            },
            onMonthlyBookingTap: () {
              ref.read(selectedBookingTypeProvider.notifier).state = 1;
            },
          )
        else
          MobileSearchCard(
            onDailyBookingTap: () {
              ref.read(selectedBookingTypeProvider.notifier).state = 0;
            },
            onMonthlyBookingTap: () {
              ref.read(selectedBookingTypeProvider.notifier).state = 1;
            },
          ),

        // Continue your search section
        _buildContinueYourSearch(context, isTablet),

        // Promotional offers section
        PromotionalCards(),

        // Destination cards section
        MoreForYouSection(),

        // Loyalty program section
        HotelsSectionHeader(),

        // Hotels section
        HotelsList(),

      ],
    );
  }

  Widget _buildContinueYourSearch(BuildContext context, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Continue your search',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 20 : 18,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),

          // Dynamic search card based on your data
          Consumer(
            builder: (context, ref, child) {
              final locationResponse = ref.watch(locationProvider);
              final hotelsResponse = ref.watch(hotelProvider);

              return locationResponse.when(
                data: (locationData) {
                  return hotelsResponse.when(
                    data: (hotels) {
                      if (hotels.isEmpty) {
                        return _buildPlaceholderSearchCard(isTablet);
                      }

                      // Get a popular destination (first hotel with location data)
                      Hotel? popularHotel;
                      String? destinationName;
                      String? countryName;

                      for (var hotel in hotels) {
                        if (hotel.cityId != null || hotel.countryId != null) {
                          popularHotel = hotel;

                          // Get city name
                          if (hotel.cityId != null) {
                            final city = locationData.cities?.firstWhere(
                              (c) => c.id == hotel.cityId,
                              orElse: () => location_model.City(),
                            );
                            if (city?.name != null) {
                              destinationName = city!.name;
                            }
                          }

                          // Get country name
                          if (hotel.countryId != null) {
                            final country = locationData.countries?.firstWhere(
                              (c) => c.id == hotel.countryId,
                              orElse: () => location_model.Country(),
                            );
                            if (country?.name != null) {
                              countryName = country!.name;
                            }
                          }

                          break;
                        }
                      }

                      if (popularHotel == null) {
                        return _buildPlaceholderSearchCard(isTablet);
                      }

                      final displayName = destinationName ?? countryName ?? 'Popular destination';

                      return GestureDetector(
                        onTap: () => _navigateToDestination(context, displayName),
                        child: Container(
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
                              // Placeholder image
                              Container(
                                width: isTablet ? 80 : 60,
                                height: isTablet ? 80 : 60,
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Stack(
                                  children: [
                                    Icon(
                                      Icons.water,
                                      color: Colors.blue[600],
                                      size: isTablet ? 32 : 24,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      child: Icon(
                                        Icons.bed,
                                        color: Colors.blue[800],
                                        size: isTablet ? 20 : 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isTablet ? 18 : 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      '${DateTime.now().day}-${DateTime.now().day + 1} ${_getMonthName(DateTime.now().month)}, 2 adults',
                                      style: TextStyle(
                                        fontSize: isTablet ? 16 : 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => _buildPlaceholderSearchCard(isTablet),
                    error: (e, _) => _buildPlaceholderSearchCard(isTablet),
                  );
                },
                loading: () => _buildPlaceholderSearchCard(isTablet),
                error: (e, _) => _buildPlaceholderSearchCard(isTablet),
              );
            },
          ),
        ],
      ),
    );
  }

  void _navigateToDestination(BuildContext context, String destination) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsPage(
          query: destination,
          adults: 2,
          children: 0,
          rooms: 1,
          dateRange: null,
          startTime: null,
          endTime: null,
        ),
      ),
    );
  }

  Widget _buildPlaceholderSearchCard(bool isTablet) {
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
          Container(
            width: isTablet ? 80 : 60,
            height: isTablet ? 80 : 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.search,
              color: Colors.grey[400],
              size: isTablet ? 32 : 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loading destination...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 18 : 16,
                    color: Colors.grey[600],
                  ),
                ),
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
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

}







