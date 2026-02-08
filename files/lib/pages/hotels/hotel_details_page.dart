import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/constants/app_colors.dart';
import '../../models/hotel.dart';
import '../../models/selected_room.dart';
import '../../services/favorites_provider.dart';
import '../../services/waiting_list_provider.dart';

import '../service_providers/pages/categories_page.dart';

class HotelDetailsPage extends ConsumerStatefulWidget {
  final Hotel hotel;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int? rooms;

  const HotelDetailsPage({
    Key? key,
    required this.hotel,
    this.checkInDate,
    this.checkOutDate,
    this.rooms,
  }) : super(key: key);

  @override
  ConsumerState<HotelDetailsPage> createState() => _HotelDetailsPageState();
}

class _HotelDetailsPageState extends ConsumerState<HotelDetailsPage> {
  Set<String> _selectedRooms = {};
  Map<String, int> _roomQuantities = {};

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primary(context);
    final isTablet = MediaQuery.of(context).size.width > 600;


    return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.h),
          child: _buildCustomAppBar(primaryColor, isTablet),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildPropertiesSection(primaryColor, isTablet), // Images first
              _buildHotelInfo(primaryColor,
                  isTablet), // Description second with service provider icon
              _buildLocationSection(primaryColor, isTablet), // Maps section
              _buildAmenitiesSection(primaryColor, isTablet),
              _buildReviewsSection(primaryColor, isTablet),
              _buildPropertyInfoSection(primaryColor, isTablet),
              SizedBox(height: 100.h), // Space for bottom bar
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(primaryColor, isTablet),
        floatingActionButton: _selectedRooms.isNotEmpty
            ? _buildBookNowButton(primaryColor, isTablet)
            : null,
      );
  }

  Widget _buildCustomAppBar(Color primaryColor, bool isTablet) {
    return Container(
      color: primaryColor,
      child: SafeArea(
        child: Container(
          height: 80,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Back button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              // Hotel name (centered)
              Expanded(
                child: Center(
                  child: Text(
                    widget.hotel.name ?? 'hotel_name'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              // Favorite button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Consumer(
                  builder: (context, ref, child) {
                    final favorites = ref.watch(favoritesProvider);
                    // Generate a fallback ID if hotel doesn't have one
                    final hotelId =
                        widget.hotel.id ?? widget.hotel.name ?? 'unknown';
                    final isFavorite = favorites
                        .any((h) => (h.id ?? h.name ?? 'unknown') == hotelId);

                    return IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () {
                        // Create a hotel with ID if it doesn't have one
                        final hotelToAdd = widget.hotel.id == null
                            ? Hotel(
                                id: hotelId,
                                name: widget.hotel.name,
                                location: widget.hotel.location,
                                imageUrl: widget.hotel.imageUrl,
                                rate: widget.hotel.rate,
                                city: widget.hotel.city,
                                country: widget.hotel.country,
                                state: widget.hotel.state,
                              )
                            : widget.hotel;

                        ref
                            .read(favoritesProvider.notifier)
                            .toggleFavorite(hotelToAdd, context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHotelInfo(Color primaryColor, bool isTablet) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20.w),
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
                      'Cairo Plaza, INN Hotel',
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '18 BANK MISR STREET ABDEEN SQUARE, DOWNTOWN, 4280143 Cairo, Egypt',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '4.5',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              // Service Provider icon button at first position - bigger and more related
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoriesPage(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(isTablet ? 14 : 12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: primaryColor.withOpacity(0.3), width: 1.5),
                  ),
                  child: Icon(
                    Icons
                        .room_service, // More related icon for service providers
                    color: primaryColor,
                    size: isTablet ? 32 : 28,
                  ),
                ),
              ),
              SizedBox(width: 8),
              _buildInfoChip(Icons.wifi, 'free_wifi'.tr(), isTablet),
              SizedBox(width: 8),
              _buildInfoChip(Icons.local_parking, 'parking'.tr(), isTablet),
              SizedBox(width: 8),
              _buildInfoChip(Icons.restaurant, 'restaurant'.tr(), isTablet),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 12 : 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(Color primaryColor, bool isTablet) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image first
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(
                    'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=800&h=400&fit=crop'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 16),
          // Title
          Text(
            'location'.tr(),
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),
          // Address
          Text(
            widget.hotel.location ??
                '18 BANK MISR STREET ABDEEN SQUARE, DOWNTOWN, 4280143 Cairo, Egypt',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          // Distance
          Row(
            children: [
              Icon(Icons.directions, color: Colors.black, size: 16),
              SizedBox(width: 8),
              Text(
                'km_from_city_center'.tr(args: ['1.2']),
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection(Color primaryColor, bool isTablet) {
    final facilities = [
      {'icon': Icons.smoke_free, 'name': 'non_smoking_rooms'.tr()},
      {'icon': Icons.wifi, 'name': 'internet'.tr()},
      {'icon': Icons.local_bar, 'name': 'bar'.tr()},
      {'icon': Icons.room_service, 'name': 'room_service'.tr()},
      {'icon': Icons.family_restroom, 'name': 'family_rooms'.tr()},
      {'icon': Icons.balcony, 'name': 'terrace'.tr()},
      {'icon': Icons.support_agent, 'name': '24_hour_front_desk'.tr()},
    ];

    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Providers button at start
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoriesPage(),
                      ),
                    );
                  },
                  icon: Icon(Icons.design_services, color: Colors.white),
                  label: Text(
                    'hotel.service_providers'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 14 : 12,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Title
          Text(
            'most_popular_facilities'.tr(),
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),
          // Facilities List
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: facilities.map((facility) {
              return Container(
                width: (MediaQuery.of(context).size.width - 72) / 2,
                child: Row(
                  children: [
                    Icon(
                      facility['icon'] as IconData,
                      color: Colors.black,
                      size: isTablet ? 20 : 18,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        facility['name'] as String,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          Text(
            'see_all_facilities'.tr(),
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesSection(Color primaryColor, bool isTablet) {
    final List<String> hotelImages = [
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=300&fit=crop',
    ];

    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photos Grid first
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.2,
            ),
            itemCount: hotelImages.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(hotelImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    if (index == 8)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black.withOpacity(0.3),
                        ),
                        child: Center(
                          child: Text(
                            '+0',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 16),
          // Title
          Text(
            'properties'.tr(),
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(Color primaryColor, bool isTablet) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Rating Section
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '10',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'exceptional'.tr(),
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'see_detailed_reviews'.tr(args: ['4']),
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
          SizedBox(height: 20),
          // Rating Breakdown
          _buildRatingBar('cleanliness'.tr(), 10.0, true, isTablet),
          SizedBox(height: 12),
          _buildRatingBar('comfort'.tr(), 9.6, false, isTablet),
          SizedBox(height: 12),
          _buildRatingBar('facilities'.tr(), 10.0, true, isTablet),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.trending_up, color: Colors.green, size: 16),
              SizedBox(width: 4),
              Text(
                'high_score_for'.tr(args: ['Cairo']),
                style: TextStyle(
                  fontSize: isTablet ? 12 : 10,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'show_more'.tr(),
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 20),
          // Guest Reviews Section
          Text(
            'guests_who_stayed_here_loved'.tr(),
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),
          // Individual Reviews
          _buildGuestReview(
            'Pavel',
            'Croatia',
            'The room had a comfortable bed, and the curtains blocked out the noise. The location was very close to Tahrir Square, which made it easy for me to get anywhere',
            Colors.red,
            isTablet,
          ),
          SizedBox(height: 16),
          _buildGuestReview(
            'Christian',
            'Germany',
            'The hotel is located right in downtown, with everything just steps away. The room is small but well organized, and the bed is comfortable',
            Colors.blue,
            isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(
      String label, double score, bool hasArrow, bool isTablet) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        if (hasArrow) ...[
          SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_up, color: Colors.green, size: 16),
        ],
        Expanded(
          child: Container(
            height: 8,
            margin: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: score / 10.0,
              child: Container(
                decoration: BoxDecoration(
                  color: score >= 10.0 ? Colors.green : Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildGuestReview(String name, String country, String review,
      Color avatarColor, bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: avatarColor,
          child: Text(
            name[0],
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 16 : 14,
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Center(
                      child: Text(
                        '🏳️',
                        style: TextStyle(fontSize: 8),
                      ),
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    country,
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 10,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '"$review"',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyInfoSection(Color primaryColor, bool isTablet) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Need more info section
          Text(
            'Need more info to decide?',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Ask the property anything beforehand, like hygiene measures or parking details.',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: primaryColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Ask the property directly',
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24),
          // Description section
          Text(
            'Description',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Cairo Plaza, INN Hotel in Cairo features 4-star accommodations with a shared lounge, a terrace and a bar. Among the facilities at this property are an ATM and a concierge service, along with free WiFi throughout the property. The property provides a shared kitchen, room service and currency exchange...',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Color primaryColor, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'US\$21',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'per night',
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            child: ElevatedButton(
              onPressed: () {
                _showRoomSelection();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Select Rooms',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookNowButton(Color primaryColor, bool isTablet) {
    return FloatingActionButton.extended(
      onPressed: () {
        _showMultipleRoomBookingDialog(primaryColor, isTablet);
      },
      backgroundColor: primaryColor,
      icon: Icon(Icons.book_online, color: Colors.white),
      label: Text(
        'Book ${_selectedRooms.length} Rooms',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: isTablet ? 16 : 14,
        ),
      ),
    );
  }

  void _showRoomSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header with hotel info
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.hotel.name ?? 'Hotel Name',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '4 Sep - 5 Sep',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: Colors.black),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Selected rooms count
                    if (_selectedRooms.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          '${_selectedRooms.length} room(s) selected',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary(context),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
              // Alert banner
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Only 1 room left on Booking.com',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Rooms list
              Expanded(
                child: _buildModalRoomsList(
                    AppColors.primary(context), false, setModalState),
              ),
              // Bottom action bar
              if (_selectedRooms.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_selectedRooms.length} room(s) selected',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _navigateToBooking();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary(context),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Continue with ${_selectedRooms.length} room(s)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
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

  Widget _buildModalRoomsList(
      Color primaryColor, bool isTablet, StateSetter setModalState) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildModalRoomCard(
          'Deluxe Double Room with Two Double Beds',
          '1 twin bed, 1 full bed',
          'Room size: 25 m²',
          [
            'Free WiFi',
            'Attached bathroom',
            'Air conditioning',
            'Balcony',
            'City view',
            'Flat-screen TV',
            'Soundproof',
            'Minibar'
          ],
          'Price for 2 adults',
          [
            'Free cancellation anytime',
            'No prepayment needed - pay at the property',
            'No credit card needed'
          ],
          'Breakfast included',
          'Includes late check-in + high-speed internet',
          '52% off',
          'Limited-time Deal',
          'Price for 1 night (4 Sep - 5 Sep)',
          'US\$43',
          'US\$21',
          '+US\$3.10 taxes and fees',
          isTablet,
          setModalState,
        ),
        SizedBox(height: 16),
        _buildModalRoomCard(
          'Comfort Triple Room',
          'Option 1: 1 twin bed, 1 queen bed\nOption 2: 3 twin beds',
          'Room size: 26 m²',
          [
            'Free WiFi',
            'Attached bathroom',
            'Air conditioning',
            'Balcony',
            'City view',
            'Flat-screen TV',
            'Soundproof'
          ],
          'Price for 2 adults',
          [
            'Free cancellation anytime',
            'No prepayment needed - pay at the property',
            'No credit card needed'
          ],
          'Breakfast included',
          'Includes late check-in + high-speed internet',
          '50% off',
          'Limited-time Deal',
          'Price for 1 night (4 Sep - 5 Sep)',
          'US\$50',
          'US\$25',
          '+US\$3.10 taxes and fees',
          isTablet,
          setModalState,
        ),
      ],
    );
  }

  Widget _buildModalRoomCard(
    String title,
    String bedType,
    String roomSize,
    List<String> amenities,
    String priceFor,
    List<String> policies,
    String breakfast,
    String includes,
    String discount,
    String deal,
    String priceLabel,
    String originalPrice,
    String currentPrice,
    String taxes,
    bool isTablet,
    StateSetter setModalState,
  ) {
    String roomId = title.toLowerCase().replaceAll(' ', '_');
    bool isSelected = _selectedRooms.contains(roomId);
    return GestureDetector(
        onTap: () {
          setModalState(() {
            setState(() {
              if (isSelected) {
                _selectedRooms.remove(roomId);
              } else {
                _selectedRooms.add(roomId);
              }
            });
          });
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey[300]!,
                width: isSelected ? 2 : 1),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 12),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side - Details
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bed type
                          Row(
                            children: [
                              Icon(Icons.bed,
                                  size: 16, color: Colors.grey[600]),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  bedType,
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          // Room size
                          Row(
                            children: [
                              Icon(Icons.aspect_ratio,
                                  size: 16, color: Colors.grey[600]),
                              SizedBox(width: 8),
                              Text(
                                roomSize,
                                style: TextStyle(
                                  fontSize: isTablet ? 14 : 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          // Amenities
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: amenities.take(4).map((amenity) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check,
                                      size: 12, color: Colors.green),
                                  SizedBox(width: 4),
                                  Text(
                                    amenity,
                                    style: TextStyle(
                                      fontSize: isTablet ? 12 : 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 16),

                    // Right side - Room image
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(
                              'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400&h=300&fit=crop'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Price for adults
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Text(
                      priceFor,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Policies
                Column(
                  children: policies.map((policy) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.check, size: 12, color: Colors.green),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              policy,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 8),

                // Breakfast and includes
                Row(
                  children: [
                    Icon(Icons.coffee, size: 12, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      breakfast,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.check, size: 12, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        includes,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Icon(Icons.info_outline, size: 12, color: Colors.blue),
                  ],
                ),

                SizedBox(height: 12),

                // Deal badges
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        discount,
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        deal,
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Price breakdown
                Text(
                  priceLabel,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      originalPrice,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      currentPrice,
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Icon(Icons.info_outline, size: 12, color: Colors.blue),
                  ],
                ),
                Text(
                  taxes,
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),

                SizedBox(height: 16),

                // Select button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      setModalState(() {
                        setState(() {
                          if (isSelected) {
                            _selectedRooms.remove(roomId);
                          } else {
                            _selectedRooms.add(roomId);
                          }
                        });
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: isSelected ? Colors.red : Colors.blue,
                          width: 2),
                      backgroundColor: isSelected
                          ? Colors.red.withOpacity(0.1)
                          : Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isSelected ? 'Remove' : 'Select',
                      style: TextStyle(
                        color: isSelected ? Colors.red : Colors.blue,
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void _showMultipleRoomBookingDialog(Color primaryColor, bool isTablet) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Book Multiple Rooms',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Rooms:',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                ..._selectedRooms
                    .map((room) => _buildSelectedRoomItem(room, isTablet))
                    .toList(),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Rooms: ${_selectedRooms.length}',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Check-in: Thu, 4 Sep',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        'Check-out: Fri, 5 Sep',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToBooking();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Book All Rooms',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedRoomItem(String roomName, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              roomName,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  void _navigateToBooking() {
    if (_selectedRooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('please_select_at_least_one_room'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create SelectedRoom objects from selected room IDs
    List<SelectedRoom> selectedRoomObjects = [];

    for (String roomId in _selectedRooms) {
      // Map room IDs to room data
      if (roomId == 'deluxe_double_room_with_two_double_beds') {
        selectedRoomObjects.add(SelectedRoom(
          name: 'deluxe_double_room_with_two_double_beds'.tr(),
          pricePerNight: 21.0,
          maxAdults: 2,
          maxChildren: 0,
          imageUrl:
              'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400&h=300&fit=crop',
          amenities: [
            'free_wifi'.tr(),
            'attached_bathroom'.tr(),
            'air_conditioning'.tr(),
            'balcony'.tr(),
            'city_view'.tr(),
            'flat_screen_tv'.tr(),
            'soundproof'.tr(),
            'minibar'.tr()
          ],
        ));
      }

      // Add each selected room to waiting list
      final waitingListNotifier = ref.read(waitingListProvider.notifier);
      for (SelectedRoom room in selectedRoomObjects) {
        waitingListNotifier.addToWaitingList(
          hotel: widget.hotel,
          room: room,
          checkInDate: widget.checkInDate ?? DateTime.now(),
          checkOutDate:
              widget.checkOutDate ?? DateTime.now().add(Duration(days: 1)),
          quantity: _roomQuantities[room.name] ?? 1,
        );
      }

      // Show success message and navigate to waiting list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${selectedRoomObjects.length} room(s) added to waiting list'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushNamed(context, '/waiting-list');

      // Clear selected rooms
      setState(() {
        _selectedRooms.clear();
        _roomQuantities.clear();
      });
    }
  }
}
