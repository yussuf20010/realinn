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
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: screenHeight * 0.35,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
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
                child: Icon(Icons.arrow_back, color: WPConfig.primaryColor, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8),
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
                  child: Icon(Icons.share, color: WPConfig.primaryColor, size: 18),
                ),
                onPressed: () {
                  // Handle share
                },
              ),
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8),
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
                  child: Icon(Icons.favorite_border, color: WPConfig.primaryColor, size: 18),
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
                        size: screenWidth * 0.25,
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
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: Offset(0, -20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hotel name and rating section
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
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
                                        fontSize: 20,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () {
                                        _showLocationDetails(context);
                                      },
                                      child: Row(
                                        children: [
                                          Icon(Icons.location_on,
                                              color: Colors.grey[600],
                                              size: 16),
                                          SizedBox(width: 4),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if (hotel.country != null)
                                                  Text(
                                                    hotel.country!,
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                if (hotel.city != null)
                                                  Text(
                                                    hotel.city!,
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 13,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                if (hotel.country == null && hotel.city == null)
                                                  Text(
                                                    hotel.location ?? 'Location',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 13,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.info_outline,
                                            color: Colors.grey[400],
                                            size: 14,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: WPConfig.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star,
                                        color: Color(0xFFFFC107),
                                        size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      hotel.rate?.toStringAsFixed(1) ?? '',
                                      style: TextStyle(
                                        color: WPConfig.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Description section
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.description, color: WPConfig.primaryColor, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Description',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            hotel.description ?? '',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Amenities section
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.accessibility, color: WPConfig.primaryColor, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Amenities',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildAmenity(context, Icons.wifi, 'Free WiFi'),
                              _buildAmenity(context, Icons.pool, 'Swimming Pool'),
                              _buildAmenity(context, Icons.restaurant, 'Restaurant'),
                              _buildAmenity(context, Icons.fitness_center, 'Fitness Center'),
                              _buildAmenity(context, Icons.local_parking, 'Free Parking'),
                              _buildAmenity(context, Icons.room_service, 'Room Service'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Hotel Services section
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
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
                                  Icon(Icons.hotel, color: WPConfig.primaryColor, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Hotel Services',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
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
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Container(
                            height: 140,
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
                    
                    SizedBox(height: 80), // Space for bottom navigation
                  ],
                ),
              ),
            ),
          ),
          )],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, -3),
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
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatPrice(hotel.priceRange),
                    style: TextStyle(
                      color: WPConfig.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showBookingDialog(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WPConfig.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    elevation: 2,
                  ),
                  child: Text(
                    'Book Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
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
              size: 14,
            ),
          ),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 11,
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
        width: screenWidth * 0.35,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Icon(
                serviceInfo['icon'],
                size: 32,
                color: WPConfig.primaryColor,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                          height: 1.3,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Book Now', 
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            )
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
                SizedBox(height: 12),
                _buildDatePicker(
                  dialogContext,
                  'Check-out Date',
                  checkOut,
                  (date) => setState(() => checkOut = date),
                ),
                SizedBox(height: 12),
                _buildCounter(
                  'Adults',
                  adults,
                  (value) => setState(() => adults = value),
                ),
                SizedBox(height: 12),
                _buildCounter(
                  'Children',
                  children,
                  (value) => setState(() => children = value),
                ),
                SizedBox(height: 12),
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
                  fontSize: 14,
                )
              ),
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
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Confirm Booking',
                style: TextStyle(fontSize: 14),
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
            fontSize: 13,
            color: Colors.black87,
          )
        ),
        SizedBox(height: 6),
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
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                ),
                Icon(Icons.calendar_today, size: 16, color: WPConfig.primaryColor),
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
            fontSize: 13,
            color: Colors.black87,
          )
        ),
        SizedBox(height: 6),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove_circle_outline, size: 20),
              onPressed: value > 1 ? () => onChanged(value - 1) : null,
            ),
            Text(
              '$value', 
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              )
            ),
            IconButton(
              icon: Icon(Icons.add_circle_outline, size: 20),
              onPressed: () => onChanged(value + 1),
            ),
          ],
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

  void _showLocationDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Location Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hotel.country != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Country: ${hotel.country!}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              if (hotel.city != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'City: ${hotel.city!}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              if (hotel.location != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Address: ${hotel.location!}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Close',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 