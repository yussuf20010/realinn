import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../config/dynamic_config.dart';
import '../../../../controllers/location_controller.dart';
import '../../../../controllers/hotel_controller.dart';
import '../../../models/location.dart' as location_model;
import '../../../models/hotel.dart';
import '../search_results_page.dart';

class MoreForYouSection extends ConsumerWidget {
  const MoreForYouSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final primaryColor = dynamicConfig.primaryColor;
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: isTablet ? 8 : 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            'Explore Destinations',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 20 : 18,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'These popular destinations have a lot to offer',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 12),

          // Dynamic destination cards based on your data
          Consumer(
            builder: (context, ref, child) {
              final locationResponse = ref.watch(locationProvider);
              final hotelsResponse = ref.watch(hotelProvider);

              return locationResponse.when(
                data: (locationData) {
                  return hotelsResponse.when(
                    data: (hotels) {
                      // Get top countries with most hotels
                      final countries = locationData.countries ?? [];

                      // Count hotels per country
                      Map<String, int> countryHotelCounts = {};
                      for (var hotel in hotels) {
                        if (hotel.countryId != null) {
                          final country = countries.firstWhere(
                            (c) => c.id == hotel.countryId,
                            orElse: () => location_model.Country(),
                          );
                          if (country.name != null) {
                            countryHotelCounts[country.name!] =
                                (countryHotelCounts[country.name!] ?? 0) + 1;
                          }
                        }
                      }

                      // Sort countries by hotel count and take top 2
                      final topCountries = countryHotelCounts.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value));

                      if (topCountries.isEmpty) {
                        return _buildPlaceholderCards(isTablet);
                      }

                      // Take top 2 countries or use available ones
                      final displayCountries = topCountries.take(2).toList();

                      return Row(
                        children: [
                          // First country card
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _navigateToDestination(
                                  context, displayCountries[0].key),
                              child: Container(
                                height: isTablet ? 120 : 100,
                                margin: EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.orange[100],
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.orange[100]!,
                                        Colors.orange[300]!,
                                      ],
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          displayCountries[0].key,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: isTablet ? 18 : 16,
                                          ),
                                        ),
                                        Text(
                                          '${displayCountries[0].value} properties',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isTablet ? 14 : 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Second country card (if available)
                          if (displayCountries.length > 1)
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _navigateToDestination(
                                    context, displayCountries[1].key),
                                child: Container(
                                  height: isTablet ? 120 : 100,
                                  margin: EdgeInsets.only(left: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.blue[100],
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.blue[100]!,
                                          Colors.blue[300]!,
                                        ],
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            displayCountries[1].key,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: isTablet ? 18 : 16,
                                            ),
                                          ),
                                          Text(
                                            '${displayCountries[1].value} properties',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isTablet ? 14 : 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            // If only one country, show a placeholder or expand the first card
                            Expanded(
                              child: Container(
                                height: isTablet ? 120 : 100,
                                margin: EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey[100],
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.grey[100]!,
                                        Colors.grey[300]!,
                                      ],
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'More destinations',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: isTablet ? 18 : 16,
                                          ),
                                        ),
                                        Text(
                                          'Coming soon',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isTablet ? 14 : 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                    loading: () => _buildPlaceholderCards(isTablet),
                    error: (e, _) => _buildPlaceholderCards(isTablet),
                  );
                },
                loading: () => _buildPlaceholderCards(isTablet),
                error: (e, _) => _buildPlaceholderCards(isTablet),
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
          hotels: [], // Empty list for now, will be loaded by the page
          searchQuery: destination,
        ),
      ),
    );
  }

  Widget _buildPlaceholderCards(bool isTablet) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: isTablet ? 120 : 100,
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, color: Colors.grey[400], size: 24),
                  SizedBox(height: 8),
                  Text(
                    'Loading destinations...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isTablet ? 14 : 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: isTablet ? 120 : 100,
            margin: EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, color: Colors.grey[400], size: 24),
                  SizedBox(height: 8),
                  Text(
                    'Loading destinations...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isTablet ? 14 : 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
