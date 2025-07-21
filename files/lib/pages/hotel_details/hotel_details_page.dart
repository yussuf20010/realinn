import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realinn/pages/hotel_details/service_detail_page.dart';
import '../../config/image_cache_config.dart';
import '../../config/wp_config.dart';
import '../../models/hotel.dart';
import '../booking/booking_page.dart';
import '../service_providers/service_providers_page.dart';

class HotelDetailsPage extends ConsumerWidget {
  final Hotel hotel;

  const HotelDetailsPage({
    Key? key,
    required this.hotel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: screenHeight * 0.4,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.arrow_back, color: WPConfig.primaryColor),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.share, color: WPConfig.primaryColor),
                ),
                onPressed: () {
                  // Handle share
                },
              ),
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.favorite_border, color: WPConfig.primaryColor),
                ),
                onPressed: () {
                  // Handle favorite
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    hotel.images?.first ?? hotel.imageUrl ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            WPConfig.primaryColor.withOpacity(0.1),
                            WPConfig.primaryColor.withOpacity(0.2),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.image,
                        size: screenWidth * 0.3,
                        color: WPConfig.primaryColor,
                      ),
                    ),
                  ),
                  Container(
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
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hotel.name ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.06,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    color: Colors.grey[600],
                                    size: screenWidth * 0.04),
                                SizedBox(width: screenWidth * 0.01),
                                Expanded(
                                  child: Text(
                                    hotel.location ?? '',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: screenWidth * 0.035,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenHeight * 0.005,
                        ),
                        decoration: BoxDecoration(
                          color: WPConfig.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: WPConfig.primaryColor.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star,
                                color: Color(0xFFFFC107),
                                size: screenWidth * 0.04),
                            SizedBox(width: screenWidth * 0.01),
                            Text(
                              hotel.rate?.toStringAsFixed(1) ?? '',
                              style: TextStyle(
                                color: WPConfig.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.045,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    hotel.description ?? '',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: screenWidth * 0.035,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    'Amenities',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.045,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Wrap(
                    spacing: screenWidth * 0.02,
                    runSpacing: screenHeight * 0.01,
                    children: [
                      _buildAmenity(context, Icons.wifi, 'Free WiFi'),
                      _buildAmenity(context, Icons.pool, 'Swimming Pool'),
                      _buildAmenity(context, Icons.restaurant, 'Restaurant'),
                      _buildAmenity(context, Icons.fitness_center, 'Fitness Center'),
                      _buildAmenity(context, Icons.local_parking, 'Free Parking'),
                      _buildAmenity(context, Icons.room_service, 'Room Service'),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hotel Services',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.045,
                        ),
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
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Container(
                    height: screenHeight * 0.18,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildServiceCard(
                          context,
                          'Spa & Wellness',
                          'Relax and rejuvenate with our premium spa services',
                        ),
                        _buildServiceCard(
                          context,
                          'Fine Dining',
                          'Experience exquisite cuisine prepared by master chefs',
                        ),
                        _buildServiceCard(
                          context,
                          'Fitness Center',
                          'Stay active with state-of-the-art equipment',
                        ),
                        _buildServiceCard(
                          context,
                          'Car Service',
                          'Luxury car rental and chauffeur services available',
                        ),
                        _buildServiceCard(
                          context,
                          'Airport Transfer',
                          'Comfortable and reliable airport transportation',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.015,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -2),
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
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                  Text(
                    '\$${hotel.priceRange ?? 0}',
                    style: TextStyle(
                      color: WPConfig.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.045,
                    ),
                  ),
                ],
              ),
              SizedBox(width: screenWidth * 0.05),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showBookingDialog(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WPConfig.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.015,
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Book Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.035,
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

  Widget _buildAmenity(BuildContext context, IconData icon, String label) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenHeight * 0.01,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: WPConfig.primaryColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.015),
            decoration: BoxDecoration(
              color: WPConfig.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: WPConfig.primaryColor,
              size: screenWidth * 0.04,
            ),
          ),
          SizedBox(width: screenWidth * 0.02),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: screenWidth * 0.03,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
      BuildContext context, String title, String subtitle) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
        margin: EdgeInsets.only(right: screenWidth * 0.03),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: screenHeight * 0.12,
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
                    size: screenWidth * 0.1,
                    color: WPConfig.primaryColor,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          serviceInfo['icon'],
                          size: screenWidth * 0.04,
                          color: WPConfig.primaryColor,
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.035,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Expanded(
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: screenWidth * 0.03,
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
          title: Text('Book Now', style: TextStyle(fontWeight: FontWeight.bold)),
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
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(bookingsProvider.notifier).addBooking(
                  Booking(
                    hotel: hotel,
                    checkIn: checkIn,
                    checkOut: checkOut,
                    adults: adults,
                    children: children,
                    rooms: rooms,
                  ),
                );
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Booking added successfully!'),
                    backgroundColor: WPConfig.primaryColor,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: WPConfig.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Confirm Booking'),
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
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Icon(Icons.calendar_today, size: 20, color: WPConfig.primaryColor),
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
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove_circle_outline),
              onPressed: value > 1 ? () => onChanged(value - 1) : null,
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