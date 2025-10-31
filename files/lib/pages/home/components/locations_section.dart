import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../services/hotel_service.dart';
import '../../../../models/hotel.dart';
import '../../../../config/wp_config.dart';

class LocationsSection extends StatelessWidget {
  const LocationsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768;
    // Using WPConfig.navbarColor directly where needed; no local assignment

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
          FutureBuilder(
            future: HotelService.fetchMeta(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingLocations(isTablet);
              }
              if (snapshot.hasError) {
                return _buildErrorLocations(
                    isTablet, snapshot.error.toString());
              }
              final locationData = snapshot.data as LocationResponseModel?;
              if (locationData == null) {
                return _buildErrorLocations(isTablet, 'No data');
              }

              final cities = locationData.cities ?? [];
              final countries = locationData.countries ?? [];

              if (cities.isEmpty && countries.isEmpty) {
                return _buildPlaceholderLocations(isTablet);
              }

              final topCities = cities.take(6).toList();
              final topCountries = countries.take(2).toList();

              return Column(
                children: [
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
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isTablet ? 3 : 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: topCities.length,
                      itemBuilder: (context, index) {
                        final city = topCities[index];
                        // Build image URL from city feature_image if available
                        String? cityImageUrl;
                        if (city.featureImage != null &&
                            city.featureImage!.isNotEmpty) {
                          // Construct full URL from feature_image
                          if (city.featureImage!.startsWith('http')) {
                            cityImageUrl = city.featureImage;
                          } else {
                            cityImageUrl =
                                '${WPConfig.imageBaseUrl}${city.featureImage}';
                          }
                        }
                        return _buildLocationCard(
                          name: city.name ?? 'City',
                          subtitle: 'Explore hotels',
                          icon: Icons.location_city,
                          color: _getLocationColor(index),
                          isTablet: isTablet,
                          imageUrl: cityImageUrl,
                          onTap: () =>
                              _navigateToLocation(context, city.name ?? 'City'),
                        );
                      },
                    ),
                    SizedBox(height: 24),
                  ],
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
    String? imageUrl,
  }) {
    // Use provided imageUrl if available and not empty, otherwise get category image based on location name
    String finalImageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      finalImageUrl = imageUrl;
    } else {
      finalImageUrl = _getCategoryImage(name);
    }

    // Final safety check - ensure we never pass empty string to NetworkImage
    if (finalImageUrl.isEmpty) {
      finalImageUrl =
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop';
    }

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
              Image.network(
                finalImageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Show placeholder with gradient if image fails
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withOpacity(0.6),
                          color.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 48,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
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
    // No static placeholder data - show empty message
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.location_off,
            size: isTablet ? 64 : 48,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No locations available',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please check your connection',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
                        fontSize: 12.sp,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to $locationName...'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
