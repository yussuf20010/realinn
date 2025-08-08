import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:realinn/pages/hotel_details/service_detail_page.dart';
import '../../config/image_cache_config.dart';
import '../../config/wp_config.dart';
import '../../controllers/location_controller.dart';
import '../../models/hotel.dart';
import '../../models/location.dart' as location_model;
import '../../core/utils/app_utils.dart';
import '../booking/booking_page.dart';
import '../service_providers/service_providers_page.dart';
import '../favorites/favorites_page.dart';

class HotelDetailsPage extends ConsumerStatefulWidget {
  final Hotel hotel;

  const HotelDetailsPage({
    Key? key,
    required this.hotel,
  }) : super(key: key);

  @override
  ConsumerState<HotelDetailsPage> createState() => _HotelDetailsPageState();
}

class _HotelDetailsPageState extends ConsumerState<HotelDetailsPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Enhanced SliverAppBar with modern design
          SliverAppBar(
            expandedHeight: screenHeight * 0.4,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: WPConfig.primaryColor, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Consumer(
                builder: (context, ref, child) {
                  final favoritesNotifier = ref.watch(favoritesProvider.notifier);
                  final isFavorite = favoritesNotifier.isFavorite(widget.hotel);
                  
                  return Container(
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 14,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey(isFavorite),
                          color: isFavorite ? Colors.red : WPConfig.primaryColor,
                          size: 24,
                        ),
                      ),
                      onPressed: () {
                        if (isFavorite) {
                          favoritesNotifier.removeHotel(widget.hotel);
                          // Small delay to ensure widget is still mounted
                          Future.delayed(Duration(milliseconds: 100)).then((_) {
                            if (context.mounted) {
                              AppUtil.showSafeSnackBar(
                                context,
                                message: 'Removed from favorites',
                                actionLabel: 'View Favorites',
                                onActionPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => FavoritesPage()),
                                  );
                                },
                              );
                            }
                          });
                        } else {
                          favoritesNotifier.addHotel(widget.hotel);
                          // Small delay to ensure widget is still mounted
                          Future.delayed(Duration(milliseconds: 100)).then((_) {
                            if (context.mounted) {
                              AppUtil.showSafeSnackBar(
                                context,
                                message: 'Added to favorites!',
                                actionLabel: 'View Favorites',
                                onActionPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => FavoritesPage()),
                                  );
                                },
                              );
                            }
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Enhanced image with shimmer loading and rounded corners
                  Container(
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        widget.hotel.images?.first ?? widget.hotel.imageUrl ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                WPConfig.primaryColor.withOpacity(0.1),
                                WPConfig.primaryColor.withOpacity(0.3),
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.image,
                            size: screenWidth * 0.25,
                            color: WPConfig.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Enhanced gradient overlay
                  Container(
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.6),
                          Colors.black.withOpacity(0.8),
                        ],
                        stops: [0.0, 0.4, 0.7, 1.0],
                      ),
                    ),
                  ),
                  // Hotel name and location overlay at bottom
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hotel name
                        Text(
                          widget.hotel.name ?? '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 6,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        // Clickable location with city and country
                        Consumer(
                          builder: (context, ref, child) {
                            final locationResponse = ref.watch(locationProvider);
                            return locationResponse.when(
                              data: (locationData) {
                                String locationText = '';
                                
                                // Get city name from city ID
                                if (widget.hotel.cityId != null) {
                                  final city = locationData.cities?.firstWhere(
                                    (c) => c.id == widget.hotel.cityId,
                                    orElse: () => location_model.City(),
                                  );
                                  if (city?.name != null) {
                                    locationText = city!.name!;
                                  }
                                }
                                
                                // Get country name from country ID
                                if (widget.hotel.countryId != null) {
                                  final country = locationData.countries?.firstWhere(
                                    (c) => c.id == widget.hotel.countryId,
                                    orElse: () => location_model.Country(),
                                  );
                                  if (country?.name != null) {
                                    locationText = locationText.isNotEmpty 
                                        ? '$locationText, ${country!.name}'
                                        : country!.name!;
                                  }
                                }
                                
                                // Fallback to existing data if location lookup fails
                                if (locationText.isEmpty) {
                                  locationText = '${widget.hotel.city ?? ''}${widget.hotel.country != null ? ', ${widget.hotel.country}' : ''}';
                                }
                                
                                return GestureDetector(
                                  onTap: () => _openGoogleMaps(),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            locationText,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.open_in_new,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              loading: () => Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.location_on, color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Loading location...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              error: (e, _) => Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.location_on, color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      '${widget.hotel.city ?? ''}${widget.hotel.country != null ? ', ${widget.hotel.country}' : ''}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Enhanced content section
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: Offset(0, -20),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Enhanced rating and price section
                          _buildRatingSection(),
                          SizedBox(height: 20),
                          
                          // Enhanced description section
                          _buildDescriptionSection(),
                          SizedBox(height: 20),
                          
                          // Enhanced amenities section
                          _buildAmenitiesSection(),
                          SizedBox(height: 20),
                          
                          // Enhanced services section
                          _buildServicesSection(),
                          SizedBox(height: 100), // Space for bottom navigation
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // Enhanced bottom navigation
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Starting from',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatPrice(widget.hotel.priceRange),
                    style: TextStyle(
                      color: WPConfig.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 20),
              Expanded(
                child: Container(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _showBookingDialog(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WPConfig.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      shadowColor: WPConfig.primaryColor.withOpacity(0.3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Book Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rating badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [WPConfig.primaryColor, WPConfig.primaryColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text(
                  widget.hotel.rate?.toStringAsFixed(1) ?? '4.5',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          // Price info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Per Night',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatPrice(widget.hotel.priceRange),
                  style: TextStyle(
                    color: WPConfig.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          // Location button
          GestureDetector(
            onTap: () => _showLocationDetails(context),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Icon(Icons.location_on, color: WPConfig.primaryColor, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: WPConfig.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.description, color: WPConfig.primaryColor, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'About This Hotel',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            widget.hotel.description ?? 'Experience luxury and comfort in this beautiful hotel. Our dedicated staff ensures your stay is memorable with world-class amenities and exceptional service.',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: WPConfig.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.accessibility, color: WPConfig.primaryColor, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'Amenities',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildAmenity(Icons.wifi, 'Free WiFi'),
              _buildAmenity(Icons.pool, 'Swimming Pool'),
              _buildAmenity(Icons.restaurant, 'Restaurant'),
              _buildAmenity(Icons.fitness_center, 'Fitness Center'),
              _buildAmenity(Icons.local_parking, 'Free Parking'),
              _buildAmenity(Icons.room_service, 'Room Service'),
              _buildAmenity(Icons.ac_unit, 'Air Conditioning'),
              _buildAmenity(Icons.tv, 'TV'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmenity(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: WPConfig.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: WPConfig.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: WPConfig.primaryColor,
              size: 16,
            ),
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: WPConfig.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.hotel, color: WPConfig.primaryColor, size: 20),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Hotel Services',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ServiceProvidersPage(),
                    ),
                  );
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: WPConfig.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildServiceCard(
                  'Spa & Wellness',
                  'Relax and rejuvenate with our premium spa services',
                ),
                _buildServiceCard(
                  'Fine Dining',
                  'Experience exquisite cuisine prepared by master chefs',
                ),
                _buildServiceCard(
                  'Fitness Center',
                  'Stay active with state-of-the-art equipment',
                ),
                _buildServiceCard(
                  'Car Service',
                  'Luxury car rental and chauffeur services available',
                ),
                _buildServiceCard(
                  'Airport Transfer',
                  'Comfortable and reliable airport transportation',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String title, String subtitle) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Map of service titles to their corresponding icons and details
    final Map<String, Map<String, dynamic>> serviceDetails = {
      'Spa & Wellness': {
        'icon': Icons.spa,
        'features': [
          'Professional massage therapists',
          'Various treatment options',
          'Private treatment rooms',
          'Relaxation area',
          'Premium spa products',
        ],
        'price': 150.0,
      },
      'Fine Dining': {
        'icon': Icons.restaurant,
        'features': [
          'International cuisine',
          'Expert chefs',
          'Elegant atmosphere',
          'Wine selection',
          'Private dining rooms',
        ],
        'price': 200.0,
      },
      'Fitness Center': {
        'icon': Icons.fitness_center,
        'features': [
          'Modern equipment',
          'Personal trainers',
          'Group classes',
          'Yoga studio',
          'Locker rooms',
        ],
        'price': 50.0,
      },
      'Car Service': {
        'icon': Icons.directions_car,
        'features': [
          'Luxury vehicles',
          'Professional chauffeurs',
          '24/7 availability',
          'Airport transfers',
          'City tours',
        ],
        'price': 100.0,
      },
      'Airport Transfer': {
        'icon': Icons.flight,
        'features': [
          'Comfortable vehicles',
          'Meet and greet service',
          'Flight tracking',
          'Luggage assistance',
          'Fixed rates',
        ],
        'price': 80.0,
      },
    };

    final serviceInfo = serviceDetails[title] ?? {
      'icon': Icons.hotel,
      'features': ['Service features coming soon'],
      'price': 0.0,
    };

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailPage(
              title: title,
              description: subtitle,
              icon: serviceInfo['icon'],
              features: List<String>.from(serviceInfo['features']),
              price: serviceInfo['price'],
            ),
          ),
        );
      },
      child: Container(
        width: screenWidth * 0.4,
        margin: EdgeInsets.only(right: 16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 90,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    WPConfig.primaryColor.withOpacity(0.1),
                    WPConfig.primaryColor.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Icon(
                serviceInfo['icon'],
                size: 36,
                color: WPConfig.primaryColor,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
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

  void _showBookingDialog(BuildContext context, WidgetRef ref) {
    DateTime checkIn = DateTime.now();
    DateTime checkOut = DateTime.now().add(Duration(days: 1));
    int adults = 1;
    int children = 0;
    int rooms = 1;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext dialogContext, StateSetter setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: WPConfig.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.calendar_today, color: WPConfig.primaryColor, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'Book Now', 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                )
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDatePicker(
                  dialogContext,
                  'Check-in Date',
                  checkIn,
                  (date) => setState(() => checkIn = date),
                ),
                SizedBox(height: 16),
                _buildDatePicker(
                  dialogContext,
                  'Check-out Date',
                  checkOut,
                  (date) => setState(() => checkOut = date),
                ),
                SizedBox(height: 16),
                _buildCounter(
                  'Adults',
                  adults,
                  (value) => setState(() => adults = value),
                ),
                SizedBox(height: 16),
                _buildCounter(
                  'Children',
                  children,
                  (value) => setState(() => children = value),
                ),
                SizedBox(height: 16),
                _buildCounter(
                  'Rooms',
                  rooms,
                  (value) => setState(() => rooms = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel', 
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                )
              ),
            ),
            Container(
              height: 45,
              child: ElevatedButton(
                onPressed: () async {
                  ref.read(bookingsProvider.notifier).addBooking(
                    Booking(
                      hotel: widget.hotel,
                      checkIn: checkIn,
                      checkOut: checkOut,
                      adults: adults,
                      children: children,
                      rooms: rooms,
                    ),
                  );
                  Navigator.pop(dialogContext);
                  // Small delay to ensure widget is still mounted
                  await Future.delayed(Duration(milliseconds: 100));
                  if (context.mounted) {
                    AppUtil.showSafeSnackBar(
                      context,
                      message: 'Booking added successfully!',
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: WPConfig.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Confirm Booking',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, String label, DateTime date, ValueChanged<DateTime> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          )
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: WPConfig.primaryColor,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black87,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(Icons.calendar_today, size: 18, color: WPConfig.primaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCounter(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          )
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: value > 1 ? WPConfig.primaryColor : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.remove,
                    color: value > 1 ? Colors.white : Colors.grey[500],
                    size: 18,
                  ),
                  onPressed: value > 1 ? () => onChanged(value - 1) : null,
                ),
              ),
              Text(
                '$value', 
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                )
              ),
              Container(
                decoration: BoxDecoration(
                  color: WPConfig.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () => onChanged(value + 1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatPrice(String? priceRange) {
    if (priceRange == null || priceRange.isEmpty) {
      return 'Price not available';
    }
    
    // If it's already formatted with currency symbol, return as is
    if (priceRange.startsWith('\$') || priceRange.startsWith('€') || priceRange.startsWith('£')) {
      return priceRange;
    }
    
    // If it contains a range (e.g., "100 - 200")
    if (priceRange.contains(' - ')) {
      return '\$$priceRange';
    }
    
    // If it's just a number, add currency symbol
    if (double.tryParse(priceRange) != null) {
      return '\$$priceRange';
    }
    
    // If it's already a formatted string, return as is
    return priceRange;
  }

  void _openGoogleMaps() {
    if (widget.hotel.latitude != null && widget.hotel.longitude != null) {
      final url = 'https://www.google.com/maps/search/?api=1&query=${widget.hotel.latitude},${widget.hotel.longitude}';
      _launchUrl(url);
    } else {
      // Fallback: try to open with hotel name and location
      final locationText = '${widget.hotel.name ?? 'Hotel'}, ${widget.hotel.city ?? ''}${widget.hotel.country != null ? ', ${widget.hotel.country}' : ''}';
      final encodedLocation = Uri.encodeComponent(locationText);
      final url = 'https://www.google.com/maps/search/?api=1&query=$encodedLocation';
      _launchUrl(url);
    }
  }

  void _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Show error message
        if (context.mounted) {
          AppUtil.showSafeSnackBar(
            context,
            message: 'Could not open Google Maps',
          );
        }
      }
    } catch (e) {
      // Show error message
      if (context.mounted) {
        AppUtil.showSafeSnackBar(
          context,
          message: 'Error opening Google Maps',
        );
      }
    }
  }

  void _showLocationDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: WPConfig.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.location_on, color: WPConfig.primaryColor, size: 20),
            ),
            SizedBox(width: 12),
            Text(
              'Location Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.hotel.country != null)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.flag, color: WPConfig.primaryColor, size: 18),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Country',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              widget.hotel.country!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (widget.hotel.city != null)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_city, color: WPConfig.primaryColor, size: 18),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'City',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              widget.hotel.city!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (widget.hotel.location != null)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.home, color: WPConfig.primaryColor, size: 18),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Address',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              widget.hotel.location!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              // Add coordinates if available
              if (widget.hotel.latitude != null && widget.hotel.longitude != null)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.gps_fixed, color: WPConfig.primaryColor, size: 18),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Coordinates',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${widget.hotel.latitude!.toStringAsFixed(6)}, ${widget.hotel.longitude!.toStringAsFixed(6)}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          if (widget.hotel.latitude != null && widget.hotel.longitude != null)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                _openGoogleMaps();
              },
              icon: Icon(Icons.map, color: WPConfig.primaryColor),
              label: Text(
                'Open in Maps',
                style: TextStyle(
                  color: WPConfig.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Close',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 