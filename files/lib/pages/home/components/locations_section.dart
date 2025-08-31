import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../config/wp_config.dart';
import '../../../controllers/location_controller.dart';
import '../../../models/location.dart' as location_model;

class LocationsSection extends ConsumerWidget {
  const LocationsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = MediaQuery.of(context).size.width >= 768;
    final primaryColor = WPConfig.navbarColor;

    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Locations',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 24 : 20,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Discover amazing destinations across Egypt',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20),
          Consumer(
            builder: (context, ref, child) {
              final locationsAsync = ref.watch(locationProvider);

              return locationsAsync.when(
                data: (locationData) {
                  final cities = locationData.cities ?? [];
                  final countries = locationData.countries ?? [];

                  if (cities.isEmpty && countries.isEmpty) {
                    return _buildPlaceholderLocations(isTablet);
                  }

                  // Show top cities and countries
                  final topCities = cities.take(6).toList();
                  final topCountries = countries.take(2).toList();

                  return Column(
                    children: [
                      // Cities Grid
                      if (topCities.isNotEmpty) ...[
                        Text(
                          'Cities',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 18 : 16,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isTablet ? 3 : 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: topCities.length,
                          itemBuilder: (context, index) {
                            final city = topCities[index];
                            return _buildLocationCard(
                              name: city.name ?? 'City',
                              subtitle: 'Explore hotels',
                              icon: Icons.location_city,
                              color: _getLocationColor(index),
                              isTablet: isTablet,
                              onTap: () => _navigateToLocation(
                                  context, city.name ?? 'City'),
                            );
                          },
                        ),
                        SizedBox(height: 24),
                      ],

                      // Countries Row
                      if (topCountries.isNotEmpty) ...[
                        Text(
                          'Countries',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 18 : 16,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: topCountries.map((country) {
                            final index = topCountries.indexOf(country);
                            return Expanded(
                              child: _buildLocationCard(
                                name: country.name ?? 'Country',
                                subtitle: 'Discover destinations',
                                icon: Icons.flag,
                                color: _getLocationColor(index + 6),
                                isTablet: isTablet,
                                onTap: () => _navigateToLocation(
                                    context, country.name ?? 'Country'),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  );
                },
                loading: () => _buildLoadingLocations(isTablet),
                error: (e, _) => _buildErrorLocations(isTablet, e.toString()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard({
    required String name,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isTablet,
    required VoidCallback onTap,
  }) {
    // Get category image based on location name or index
    final imageUrl = _getCategoryImage(name);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Background image
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Gradient overlay for better text readability
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.all(isTablet ? 16 : 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 16 : 14,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 2,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 10,
                        color: Colors.white.withOpacity(0.9),
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 2,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryImage(String locationName) {
    final name = locationName.toLowerCase();

    // Seas and beaches
    if (name.contains('sea') ||
        name.contains('beach') ||
        name.contains('coast') ||
        name.contains('ocean') ||
        name.contains('marina') ||
        name.contains('port')) {
      return 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&h=300&fit=crop';
    }

    // Deserts
    if (name.contains('desert') ||
        name.contains('sahara') ||
        name.contains('oasis')) {
      return 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop';
    }

    // Nature and mountains
    if (name.contains('mountain') ||
        name.contains('valley') ||
        name.contains('forest') ||
        name.contains('park') ||
        name.contains('garden') ||
        name.contains('nature')) {
      return 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop';
    }

    // Cities and urban
    if (name.contains('city') ||
        name.contains('town') ||
        name.contains('district') ||
        name.contains('street') ||
        name.contains('avenue')) {
      return 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=400&h=300&fit=crop';
    }

    // Historical and cultural
    if (name.contains('temple') ||
        name.contains('mosque') ||
        name.contains('church') ||
        name.contains('museum') ||
        name.contains('palace') ||
        name.contains('castle')) {
      return 'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=400&h=300&fit=crop';
    }

    // Rivers and lakes
    if (name.contains('river') ||
        name.contains('lake') ||
        name.contains('waterfall') ||
        name.contains('stream') ||
        name.contains('pond')) {
      return 'https://images.unsplash.com/photo-1439066615861-d1af74d74000?w=400&h=300&fit=crop';
    }

    // Default beautiful landscape
    return 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop';
  }

  Widget _buildPlaceholderLocations(bool isTablet) {
    // Beautiful placeholder images for different categories
    final placeholderImages = [
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&h=300&fit=crop', // Beach
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop', // Desert
      'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=400&h=300&fit=crop', // City
      'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=400&h=300&fit=crop', // Historical
      'https://images.unsplash.com/photo-1439066615861-d1af74d74000?w=400&h=300&fit=crop', // Nature
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop', // Landscape
    ];

    final placeholderNames = [
      'Beautiful Beaches',
      'Desert Adventures',
      'City Life',
      'Historical Sites',
      'Natural Wonders',
      'Amazing Views',
    ];

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 3 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // Background image
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(placeholderImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: EdgeInsets.all(isTablet ? 16 : 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            placeholderNames[index],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 16 : 14,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Explore hotels',
                            style: TextStyle(
                              fontSize: isTablet ? 12 : 10,
                              color: Colors.white.withOpacity(0.9),
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadingLocations(bool isTablet) {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 3 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildErrorLocations(bool isTablet, String error) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.grey[600],
            size: isTablet ? 48 : 40,
          ),
          SizedBox(height: 12),
          Text(
            'Failed to load locations',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 16 : 14,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getLocationColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
    ];
    return colors[index % colors.length];
  }

  void _navigateToLocation(BuildContext context, String locationName) {
    // TODO: Navigate to location-specific page or search results
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to $locationName...'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
