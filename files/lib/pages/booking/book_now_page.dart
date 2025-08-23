import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../config/dynamic_config.dart';
import '../../models/hotel.dart';
import '../../models/location.dart' as location_model;

class BookNowPage extends ConsumerStatefulWidget {
  final Hotel hotel;
  final DateTimeRange? dateRange;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final int adults;
  final int children;
  final int rooms;

  const BookNowPage({
    Key? key,
    required this.hotel,
    this.dateRange,
    this.startTime,
    this.endTime,
    this.adults = 2,
    this.children = 0,
    this.rooms = 1,
  }) : super(key: key);

  @override
  ConsumerState<BookNowPage> createState() => _BookNowPageState();
}

class _BookNowPageState extends ConsumerState<BookNowPage> {
  int selectedRoomIndex = 0;

  @override
  Widget build(BuildContext context) {
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final primaryColor = dynamicConfig.primaryColor;
    final isTablet = MediaQuery.of(context).size.width >= 768;

    // Mock room data - replace with your dynamic data
    final rooms = [
      {
        'name': 'Deluxe Queen Room',
        'beds': '1 queen bed',
        'size': '40 m²',
        'amenities': ['Air conditioning', 'Private bathroom', 'Internet', 'Balcony', 'Flat-screen TV', 'View'],
        'image': widget.hotel.images?.isNotEmpty == true ? widget.hotel.images!.first : null,
        'originalPrice': 30.0,
        'discountedPrice': 26.0,
        'taxes': 3.87,
        'availability': 2,
        'cancellationDate': '23 Aug 2025',
        'mealPlan': 'Breakfast included',
        'lunchPrice': 10.0,
        'dinnerPrice': 10.0,
        'discount': 14,
      },
      {
        'name': 'Double Room',
        'beds': '2 twin beds',
        'size': '45 m²',
        'amenities': ['Air conditioning', 'Private bathroom', 'Internet', 'Balcony', 'Flat-screen TV', 'View'],
        'image': widget.hotel.images?.isNotEmpty == true ? widget.hotel.images!.first : null,
        'originalPrice': 32.0,
        'discountedPrice': 28.0,
        'taxes': 4.13,
        'availability': 1,
        'cancellationDate': '23 Aug 2025',
        'mealPlan': 'Half board included',
        'lunchPrice': 10.0,
        'dinnerPrice': 10.0,
        'discount': 14,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Column(
          children: [
            Text(
              widget.hotel.name ?? 'Hotel Name',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 18 : 16,
              ),
            ),
            if (widget.dateRange != null)
              Text(
                '${DateFormat('dd MMM').format(widget.dateRange!.start)} - ${DateFormat('dd MMM').format(widget.dateRange!.end)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 14 : 12,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.currency_exchange),
            onPressed: () {
              // Handle currency exchange
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Handle share
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Availability banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: Colors.red,
              child: Text(
                'Only ${rooms[0]['availability']} rooms left on RealInn',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Rooms list
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: rooms.asMap().entries.map((entry) {
                  final index = entry.key;
                  final room = entry.value;
                  final isSelected = index == selectedRoomIndex;
                  
    return Container(
                    margin: EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
        boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                        // Room header
          Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                                    Text(
                                      room['name'] as String,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isTablet ? 18 : 16,
                                        color: primaryColor,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.bed, color: Colors.grey[600], size: 16),
                                        SizedBox(width: 4),
                                        Text(
                                          room['beds'] as String,
                                          style: TextStyle(
                                            fontSize: isTablet ? 14 : 12,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Icon(Icons.aspect_ratio, color: Colors.grey[600], size: 16),
                                        SizedBox(width: 4),
                                        Text(
                                          'Room size: ${room['size']}',
                                          style: TextStyle(
                                            fontSize: isTablet ? 14 : 12,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Room image
                              Container(
                                width: isTablet ? 100 : 80,
                                height: isTablet ? 100 : 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                ),
                                child: room['image'] != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          room['image'] as String,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return _buildPlaceholderImage();
                                          },
                                        ),
                                      )
                                    : _buildPlaceholderImage(),
                              ),
                            ],
                          ),
                        ),
                        
                        // Amenities
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (room['amenities'] as List<String>).map((amenity) {
                        return Row(
                                mainAxisSize: MainAxisSize.min,
                          children: [
                                  Icon(
                                    _getAmenityIcon(amenity),
                                    color: Colors.grey[600],
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    amenity,
                                    style: TextStyle(
                                      fontSize: isTablet ? 14 : 12,
                                      color: Colors.black87,
                              ),
                            ),
                          ],
                        );
                            }).toList(),
                          ),
                        ),
                        
                        SizedBox(height: 12),
                        
                        // Booking details
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.people, color: Colors.grey[600], size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Price for ${widget.adults} adults',
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              
                              SizedBox(height: 12),
                              
                              // Booking policies
                              _buildPolicyRow('Free cancellation before 6:00 PM on ${room['cancellationDate']}'),
                              _buildPolicyRow('No prepayment needed - pay at the property'),
                              _buildPolicyRow('No credit card needed'),
                              
                              SizedBox(height: 12),
                              
                              // Meal plan
                              Row(
                        children: [
                                  Icon(Icons.coffee, color: Colors.grey[600], size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    room['mealPlan'] as String,
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              
                              if (room['lunchPrice'] != null)
                                Padding(
                                  padding: EdgeInsets.only(left: 28, top: 4),
                                  child: Text(
                                    'Lunch US\$${room['lunchPrice']}',
                                    style: TextStyle(
                                      fontSize: isTablet ? 14 : 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              
                              if (room['dinnerPrice'] != null)
                                Padding(
                                  padding: EdgeInsets.only(left: 28, top: 4),
                            child: Text(
                                    'Dinner US\$${room['dinnerPrice']}',
                                    style: TextStyle(
                                      fontSize: isTablet ? 14 : 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              
                              SizedBox(height: 12),
                              
                              // Discount information
                              Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.amber, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Genius ${room['discount']}% discount',
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                      color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                              
                              Padding(
                                padding: EdgeInsets.only(left: 28, top: 4),
                                child: Text(
                                  'Applied to the price before taxes and fees',
                                  style: TextStyle(
                                    fontSize: isTablet ? 12 : 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              
                              SizedBox(height: 12),
                              
                              // Discount badges
                              Row(
                        children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${room['discount']}% off',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                            child: Text(
                                      'Genius Discount',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                            ),
                          ),
                        ],
                      ),
                              
                              SizedBox(height: 12),
                              
                              // Pricing
                              Text(
                                'Price for 1 night (${DateFormat('dd MMM').format(widget.dateRange?.start ?? DateTime.now())} - ${DateFormat('dd MMM').format(widget.dateRange?.end ?? DateTime.now().add(Duration(days: 1)))})',
                                style: TextStyle(
                                  fontSize: isTablet ? 14 : 12,
                                  color: Colors.black87,
                                ),
                              ),
                              
                              SizedBox(height: 8),
                              
                              Row(
                                children: [
                                  Text(
                                    'US\$${room['originalPrice']}',
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                      color: Colors.red,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'US\$${room['discountedPrice']}',
                                    style: TextStyle(
                                      fontSize: isTablet ? 18 : 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.info, color: Colors.blue, size: 16),
                                ],
                              ),
                              
                              SizedBox(height: 4),
                              
                              Text(
                                '+US\$${room['taxes']} taxes and fees',
                                style: TextStyle(
                                  fontSize: isTablet ? 12 : 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                              
                              SizedBox(height: 20),
                              
                              // Select button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedRoomIndex = index;
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: isSelected ? primaryColor : Colors.grey.shade300),
                                    backgroundColor: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    isSelected ? 'Selected' : 'Select',
                                    style: TextStyle(
                                      color: isSelected ? primaryColor : Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              
                              SizedBox(height: 8),
                              
                              // Availability warning
                              Text(
                                'Only ${room['availability']} rooms left on RealInn',
                                style: TextStyle(
                                  fontSize: isTablet ? 12 : 10,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
                }).toList(),
              ),
            ),
            
            SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
      
      // Bottom action button
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
        ],
      ),
      child: Column(
          mainAxisSize: MainAxisSize.min,
        children: [
            Text(
              'You won\'t be charged yet',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedRoomIndex >= 0 ? () => _proceedToBooking() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Continue to booking',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                      ),
                    ),
                  ],
                ),
              ),
            );
  }

  Widget _buildPolicyRow(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'air conditioning':
        return Icons.ac_unit;
      case 'private bathroom':
        return Icons.bathtub;
      case 'internet':
        return Icons.wifi;
      case 'balcony':
        return Icons.check_circle;
      case 'flat-screen tv':
        return Icons.tv;
      case 'view':
        return Icons.landscape;
      default:
        return Icons.check_circle;
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.hotel,
        color: Colors.grey[600],
        size: 32,
      ),
    );
  }

  void _proceedToBooking() {
    // Navigate to final booking confirmation page
    // This should integrate with your booking system
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking process initiated!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}


