import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../config/dynamic_config.dart';
import '../../config/wp_config.dart';
import '../../providers/favorites_provider.dart';
import '../../models/hotel.dart';
import '../../models/selected_room.dart' as models;
import '../../models/booking.dart' as models;
import '../../providers/bookings_provider.dart' as providers;
import '../main/main_scaffold.dart';

class HotelDetailsPage extends ConsumerStatefulWidget {
  final Hotel hotel;

  const HotelDetailsPage({
    Key? key,
    required this.hotel,
  }) : super(key: key);

  @override
  ConsumerState<HotelDetailsPage> createState() => _HotelDetailsPageState();
}

class _HotelDetailsPageState extends ConsumerState<HotelDetailsPage> {
  int selectedImageIndex = 0;
  List<Map<String, dynamic>> userQuestions = [];
  int totalQuestionCount = 8; // Base count for default questions

  // Expansion states for different sections
  bool isRoomsExpanded = false;
  bool isReviewsExpanded = false;
  bool isAttractionsExpanded = false;
  bool isPoliciesExpanded = false;

  @override
  void initState() {
    super.initState();
    // Load questions asynchronously without blocking initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final primaryColor = dynamicConfig.primaryColor;
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Hotel Images
          SliverAppBar(
            expandedHeight: isTablet ? 400 : 300,
            pinned: true,
            backgroundColor: primaryColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Colors.white, size: isTablet ? 28 : 24),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              children: [
                Text(
                  widget.hotel.name ?? 'Hotel Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 24 : 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.hotel.city != null)
                  Text(
                    '- ${widget.hotel.city}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 20 : 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
            actions: [
              Consumer(
                builder: (context, ref, child) {
                  final favorites = ref.watch(favoritesProvider);
                  final isFavorite =
                      favorites.any((h) => h.id == widget.hotel.id);
                  return IconButton(
                    icon: AnimatedSwitcher(
                      duration: Duration(milliseconds: 200),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        key: ValueKey(isFavorite),
                        color: Colors.white,
                        size: isTablet ? 28 : 24,
                      ),
                    ),
                    onPressed: () {
                      ref
                          .read(favoritesProvider.notifier)
                          .toggleFavorite(widget.hotel, context);
                    },
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.share,
                    color: Colors.white, size: isTablet ? 28 : 24),
                onPressed: () => _shareHotel(),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageGallery(isTablet),
            ),
          ),

          // Hotel Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 24 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating Section
                  _buildAnimatedSection(_buildRatingSection(isTablet), 0),

                  SizedBox(height: isTablet ? 20 : 16),

                  // Most Popular Facilities
                  _buildAnimatedSection(_buildFacilitiesSection(isTablet), 2),

                  SizedBox(height: isTablet ? 20 : 16),

                  // Travelers Questions
                  _buildAnimatedSection(_buildQuestionsSection(isTablet), 3),

                  SizedBox(height: isTablet ? 20 : 16),

                  // Description
                  _buildAnimatedSection(_buildDescriptionSection(isTablet), 4),

                  SizedBox(height: isTablet ? 20 : 16),

                  // Map Section
                  if (widget.hotel.latitude != null &&
                      widget.hotel.longitude != null)
                    _buildAnimatedSection(_buildMapSection(isTablet), 5),

                  SizedBox(height: isTablet ? 20 : 16),

                  // Expandable Sections
                  _buildExpandableSection(
                    title: 'Available Rooms',
                    previewText: '3 room types available • From \$120/night',
                    expandedContent: _buildRoomsContent(isTablet),
                    isExpanded: isRoomsExpanded,
                    onToggle: () =>
                        setState(() => isRoomsExpanded = !isRoomsExpanded),
                    icon: Icons.bed_outlined,
                    isTablet: isTablet,
                  ),

                  _buildExpandableSection(
                    title: 'Guest Reviews',
                    previewText: '4.5/5 stars • 156 reviews',
                    expandedContent: _buildReviewsContent(isTablet),
                    isExpanded: isReviewsExpanded,
                    onToggle: () =>
                        setState(() => isReviewsExpanded = !isReviewsExpanded),
                    icon: Icons.star_outline,
                    isTablet: isTablet,
                  ),

                  _buildExpandableSection(
                    title: 'Nearby Attractions',
                    previewText: 'City Center • National Museum • Central Park',
                    expandedContent: _buildAttractionsContent(isTablet),
                    isExpanded: isAttractionsExpanded,
                    onToggle: () => setState(
                        () => isAttractionsExpanded = !isAttractionsExpanded),
                    icon: Icons.place_outlined,
                    isTablet: isTablet,
                  ),

                  _buildExpandableSection(
                    title: 'Hotel Policies',
                    previewText:
                        'Check-in 3PM • Free cancellation • Pet policy',
                    expandedContent: _buildPoliciesContent(isTablet),
                    isExpanded: isPoliciesExpanded,
                    onToggle: () => setState(
                        () => isPoliciesExpanded = !isPoliciesExpanded),
                    icon: Icons.policy_outlined,
                    isTablet: isTablet,
                  ),

                  SizedBox(height: isTablet ? 20 : 16),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Action Button
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, -4),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You won\'t be charged yet',
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: isTablet ? 12 : 8),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => _navigateToBooking(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bed, size: 20, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Select rooms',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
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
    );
  }

  Widget _buildImageGallery(bool isTablet) {
    if (widget.hotel.images != null && widget.hotel.images!.isNotEmpty) {
      return PageView.builder(
        itemCount: widget.hotel.images!.length,
        onPageChanged: (index) {
          setState(() {
            selectedImageIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Image.network(
                widget.hotel.images![index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage(isTablet);
                },
              ),
              // Image counter overlay
              if (widget.hotel.images!.length > 1)
                Positioned(
                  bottom: isTablet ? 24 : 16,
                  right: isTablet ? 24 : 16,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 12,
                        vertical: isTablet ? 8 : 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                    ),
                    child: Text(
                      '${selectedImageIndex + 1}/${widget.hotel.images!.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
    } else {
      return _buildPlaceholderImage(isTablet);
    }
  }

  Widget _buildPlaceholderImage(bool isTablet) {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hotel,
              color: Colors.grey[600],
              size: isTablet ? 80 : 64,
            ),
            SizedBox(height: isTablet ? 24 : 16),
            Text(
              'No Images Available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isTablet ? 24 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(color: Colors.grey.shade200),
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16 : 12,
                    vertical: isTablet ? 12 : 8),
                decoration: BoxDecoration(
                  color: WPConfig.navbarColor,
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                ),
                child: Text(
                  '${widget.hotel.rate?.toStringAsFixed(1) ?? "N/A"}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 22 : 18,
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Text(
                _getRatingText(widget.hotel.rate),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 22 : 18,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 12 : 8),
          _buildCategoryRating('Cleanliness', 8.5, isTablet),
          _buildCategoryRating('Comfort', 8.5, isTablet),
          _buildCategoryRating('Facilities', 8.3, isTablet),
        ],
      ),
    );
  }

  Widget _buildCategoryRating(String category, double rating, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 6 : 4),
      child: Row(
        children: [
          Text(
            category,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: isTablet ? 12 : 8),
          Expanded(
            child: Container(
              height: isTablet ? 8 : 6,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: rating / 10,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        WPConfig.navbarColor,
                        WPConfig.navbarColor.withOpacity(0.8)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: isTablet ? 12 : 8),
          Text(
            rating.toString(),
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitiesSection(bool isTablet) {
    final facilities = [
      {
        'icon': Icons.restaurant_outlined,
        'name': 'Restaurant',
        'color': Colors.orange,
        'description': 'Fine dining'
      },
      {
        'icon': Icons.room_service_outlined,
        'name': 'Room Service',
        'color': Colors.blue,
        'description': '24/7 available'
      },
      {
        'icon': Icons.local_parking_outlined,
        'name': 'Parking',
        'color': Colors.green,
        'description': 'Free parking'
      },
      {
        'icon': Icons.wifi,
        'name': 'WiFi',
        'color': Colors.purple,
        'description': 'High-speed internet'
      },
      {
        'icon': Icons.support_agent_outlined,
        'name': 'Front Desk',
        'color': Colors.teal,
        'description': '24-hour service'
      },
      {
        'icon': Icons.local_bar_outlined,
        'name': 'Bar & Lounge',
        'color': Colors.amber,
        'description': 'Premium drinks'
      },
      {
        'icon': Icons.ac_unit_outlined,
        'name': 'Air Conditioning',
        'color': Colors.cyan,
        'description': 'Climate control'
      },
      {
        'icon': Icons.fitness_center_outlined,
        'name': 'Fitness Center',
        'color': Colors.red,
        'description': 'Modern equipment'
      },
      {
        'icon': Icons.pool_outlined,
        'name': 'Swimming Pool',
        'color': Colors.lightBlue,
        'description': 'Outdoor pool'
      },
      {
        'icon': Icons.spa_outlined,
        'name': 'Spa & Wellness',
        'color': Colors.pink,
        'description': 'Relaxation services'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 3 : 2,
            crossAxisSpacing: isTablet ? 12 : 8,
            mainAxisSpacing: isTablet ? 12 : 8,
            childAspectRatio: isTablet ? 2.0 : 1.8,
          ),
          itemCount: facilities.length,
          itemBuilder: (context, index) {
            final facility = facilities[index];
            return _buildModernFacilityCard(
              facility['icon'] as IconData,
              facility['name'] as String,
              facility['description'] as String,
              facility['color'] as Color,
              isTablet,
            );
          },
        ),
      ],
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required String previewText,
    required Widget expandedContent,
    required bool isExpanded,
    required VoidCallback onToggle,
    required IconData icon,
    required bool isTablet,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          onTap: onToggle,
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isTablet ? 10 : 8),
                      decoration: BoxDecoration(
                        color: WPConfig.navbarColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: WPConfig.navbarColor,
                        size: isTablet ? 24 : 20,
                      ),
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 20 : 18,
                              color: Colors.black,
                            ),
                          ),
                          if (!isExpanded) ...[
                            SizedBox(height: 4),
                            Text(
                              previewText,
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: WPConfig.navbarColor,
                        size: isTablet ? 28 : 24,
                      ),
                    ),
                  ],
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: isExpanded ? null : 0,
                  child: isExpanded
                      ? Column(
                          children: [
                            SizedBox(height: isTablet ? 12 : 8),
                            expandedContent,
                          ],
                        )
                      : SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernFacilityCard(IconData icon, String name,
      String description, Color color, bool isTablet) {
    return InkWell(
      borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
      onTap: () {
        // Add facility detail action if needed
      },
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 8 : 6),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 8 : 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
              ),
              child: Icon(
                icon,
                color: color,
                size: isTablet ? 20 : 18,
              ),
            ),
            SizedBox(width: isTablet ? 12 : 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 14 : 14,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (description.isNotEmpty) ...[
                    SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: isTablet ? 16 : 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsSection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Travelers are asking',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 22 : 18,
            color: Colors.black,
          ),
        ),
        SizedBox(height: isTablet ? 20 : 16),
        Container(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            border: Border.all(color: Colors.grey.shade200),
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
              Row(
                children: [
                  Icon(Icons.chat_bubble_outline,
                      color: Colors.grey[600], size: isTablet ? 24 : 20),
                  SizedBox(width: isTablet ? 12 : 8),
                  Expanded(
                    child: Text(
                      'Hi - can I check in early?',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 16 : 12),
              Container(
                padding: EdgeInsets.all(isTablet ? 16 : 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '8 Feb 2024',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: isTablet ? 6 : 4),
                    Text(
                      'Yes, but based on other availability and check outs.',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isTablet ? 20 : 16),
              GestureDetector(
                onTap: _showAllQuestionsPage,
                child: Text(
                  'See all $totalQuestionCount questions',
                  style: TextStyle(
                    color: WPConfig.navbarColor,
                    fontSize: isTablet ? 18 : 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 20 : 16),
              OutlinedButton(
                onPressed: () => _showAskQuestionDialog(isTablet),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24 : 16,
                    vertical: isTablet ? 12 : 8,
                  ),
                ),
                child: Text(
                  'Ask a question',
                  style: TextStyle(
                    color: WPConfig.navbarColor,
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 12 : 8),
              Text(
                'This property usually replies within a few days',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 22 : 18,
            color: Colors.black,
          ),
        ),
        SizedBox(height: isTablet ? 20 : 16),
        Text(
          'Featuring a bar, ${widget.hotel.name ?? 'Hotel'} is located in ${widget.hotel.city ?? 'City'} in the ${widget.hotel.country ?? 'Country'} region, a 7-minute walk from the beach and 600 yards from the city center. The hotel offers air-conditioned rooms with free WiFi and private bathrooms.',
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
        SizedBox(height: isTablet ? 12 : 8),
      ],
    );
  }

  String _getRatingText(double? rating) {
    if (rating == null) return 'N/A';
    if (rating >= 9.0) return 'Exceptional';
    if (rating >= 8.0) return 'Excellent';
    if (rating >= 7.0) return 'Very Good';
    if (rating >= 6.0) return 'Good';
    if (rating >= 5.0) return 'Average';
    return 'Below Average';
  }

  int _getRandomQuestionCount() {
    // This should come from your dynamic data
    final hotelId = int.tryParse(widget.hotel.id ?? '0') ?? 0;
    return 10 + (hotelId % 10); // Random number between 10-19
  }

  int _getReviewCount() {
    // This should come from your dynamic data
    final hotelId = int.tryParse(widget.hotel.id ?? '0') ?? 0;
    return 100 + (hotelId % 500); // Random number between 100-600
  }

  void _navigateToBooking() {
    _showRoomSelectionBottomSheet();
  }

  void _showRoomSelectionBottomSheet() {
    final isTablet = MediaQuery.of(context).size.width >= 768;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Text(
                    'Available Rooms',
                    style: TextStyle(
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Availability notice
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Only 2 rooms left on Booking.com',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Room list using new design
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildBookingRoomItem(
                      'Standard Double Room',
                      '\$120',
                      '2 adults',
                      '25 m²',
                      '1 double bed',
                      [
                        'Free Wi-Fi',
                        'Air conditioning',
                        'Private bathroom',
                        'TV'
                      ],
                      isTablet,
                    ),
                    _buildBookingRoomItem(
                      'Deluxe Suite',
                      '\$200',
                      '2 adults + 1 child',
                      '45 m²',
                      '1 king bed + sofa bed',
                      [
                        'Free Wi-Fi',
                        'Air conditioning',
                        'Balcony',
                        'Mini bar',
                        'TV'
                      ],
                      isTablet,
                    ),
                    _buildBookingRoomItem(
                      'Family Room',
                      '\$180',
                      '4 adults',
                      '35 m²',
                      '2 double beds',
                      [
                        'Free Wi-Fi',
                        'Air conditioning',
                        'Private bathroom',
                        'TV',
                        'Coffee maker'
                      ],
                      isTablet,
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

  Widget _buildBookingRoomItem(String name, String price, String guests,
      String size, String bed, List<String> amenities, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room header with image and title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room image
              Container(
                width: isTablet ? 120 : 90,
                height: isTablet ? 90 : 70,
                margin: EdgeInsets.all(isTablet ? 16 : 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          WPConfig.navbarColor.withOpacity(0.1),
                          WPConfig.navbarColor.withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.bed_outlined,
                        size: isTablet ? 32 : 24,
                        color: WPConfig.navbarColor.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ),

              // Room info
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: isTablet ? 16 : 12,
                    right: isTablet ? 16 : 12,
                    bottom: isTablet ? 8 : 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 18 : 16,
                          color: Colors.blue[700],
                        ),
                      ),
                      SizedBox(height: isTablet ? 8 : 6),

                      // Room details
                      _buildRoomDetailRow(Icons.single_bed, bed, isTablet),
                      SizedBox(height: isTablet ? 4 : 3),
                      _buildRoomDetailRow(Icons.straighten, size, isTablet),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Amenities with icons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12),
            child: Wrap(
              spacing: isTablet ? 16 : 12,
              runSpacing: isTablet ? 8 : 6,
              children: [
                _buildAmenityIcon(Icons.ac_unit, 'Air conditioning', isTablet),
                _buildAmenityIcon(
                    Icons.bathroom_outlined, 'Private bathroom', isTablet),
                _buildAmenityIcon(Icons.wifi, 'Internet', isTablet),
                _buildAmenityIcon(Icons.check, 'Balcony', isTablet),
                _buildAmenityIcon(Icons.tv, 'Flat-screen TV', isTablet),
                _buildAmenityIcon(Icons.landscape, 'View', isTablet),
              ],
            ),
          ),

          SizedBox(height: isTablet ? 16 : 12),

          // Simplified pricing section
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.people_outline,
                        size: isTablet ? 16 : 14, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      'Price for 2 adults',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 8 : 6),

                // Simplified policies
                _buildPolicyItem(Icons.check, 'Free cancellation', '',
                    Colors.green, isTablet),
                _buildPolicyItem(Icons.check, 'No prepayment needed', '',
                    Colors.green, isTablet),
                _buildPolicyItem(Icons.restaurant, 'Breakfast included', '',
                    Colors.green, isTablet),

                SizedBox(height: isTablet ? 12 : 8),

                // Price
                Row(
                  children: [
                    Text(
                      'US\$${(double.parse(price.replaceAll('\$', '')) * 1.2).toInt()}',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: Colors.red,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'US$price',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isTablet ? 16 : 12),

                // Select button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      final roomData = {
                        'name': name,
                        'discountedPrice':
                            double.tryParse(price.replaceAll('\$', '')) ?? 0.0,
                        'maxAdults': 2,
                        'maxChildren': 0,
                        'image': '',
                        'amenities': amenities,
                      };
                      _selectRoom(roomData);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: isTablet ? 12 : 10),
                    ),
                    child: Text(
                      'Select',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 16 : 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Availability notice
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isTablet ? 8 : 6),
            decoration: BoxDecoration(
              color: Colors.red[50],
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Text(
              'Only ${(guests.split(' ')[0] == '2') ? '2' : '1'} room${(guests.split(' ')[0] == '2') ? 's' : ''} left on Booking.com',
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  void _selectRoom(Map<String, dynamic> roomData) async {
    // Show booking confirmation dialog
    final confirmed = await _showBookingConfirmationDialog(roomData);

    if (confirmed == true) {
      _processBooking(roomData);
    }
  }

  Future<bool?> _showBookingConfirmationDialog(Map<String, dynamic> roomData) {
    final roomName = roomData['name'] as String;
    final roomPrice = roomData['discountedPrice'] as double;
    final checkInDate = DateTime.now().add(Duration(days: 1));
    final checkOutDate = DateTime.now().add(Duration(days: 2));
    final nights = checkOutDate.difference(checkInDate).inDays;
    final totalPrice = roomPrice * nights;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.hotel, color: WPConfig.navbarColor),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'confirm_booking'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel name
            Text(
              widget.hotel.name ?? 'hotel_name'.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: WPConfig.navbarColor,
              ),
            ),
            SizedBox(height: 8),

            // Room details
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'room_details'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(roomName),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        'check_in'.tr(),
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Text(DateFormat('MMM dd, yyyy').format(checkInDate)),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        'check_out'.tr(),
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Text(DateFormat('MMM dd, yyyy').format(checkOutDate)),
                  SizedBox(height: 8),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'total_price'.tr(),
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'US\$${totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: WPConfig.navbarColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$nights ${'nights'.tr()}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),

            Text(
              'booking_confirmation_message'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'cancel'.tr(),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: WPConfig.navbarColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, size: 18),
                SizedBox(width: 4),
                Text('confirm_booking'.tr()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _processBooking(Map<String, dynamic> roomData) {
    // Create a SelectedRoom object
    final selectedRoom = models.SelectedRoom(
      name: roomData['name'] as String,
      pricePerNight: roomData['discountedPrice'] as double,
      maxAdults: roomData['maxAdults'] as int,
      maxChildren: roomData['maxChildren'] as int,
      imageUrl: roomData['image'] as String? ?? '',
      amenities: (roomData['amenities'] as List<String>),
    );

    // Create a booking using the factory constructor
    final booking = models.Booking.create(
      hotel: widget.hotel,
      selectedRoom: selectedRoom,
      adults: 2,
      children: 0,
    );

    // Add to bookings
    ref.read(providers.bookingsProvider.notifier).addBooking(booking);

    // Close the bottom sheet if it's open
    Navigator.pop(context);

    // Show success message with booking details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text('booking_success_message'.tr()),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'view_bookings'.tr(),
          textColor: Colors.white,
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => MainScaffold()),
              (route) => false,
            );
            // Navigate to bookings page (index 2)
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MainScaffold(initialIndex: 2),
                  ),
                );
              }
            });
          },
        ),
      ),
    );
  }

  void _shareHotel() {
    final hotelName = widget.hotel.name ?? 'Hotel';
    final hotelCity = widget.hotel.city ?? 'City';
    final hotelCountry = widget.hotel.country ?? 'Country';
    final hotelPrice = widget.hotel.priceRange ?? '0';

    final shareText =
        'Check out this amazing hotel: $hotelName in $hotelCity, $hotelCountry\nPrice: US\$$hotelPrice\n\nBook now on RealInn!';

    try {
      if (kIsWeb ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux) {
        // For web and desktop platforms, copy to clipboard and show snackbar
        _showShareFallback(shareText);
      } else {
        // For mobile platforms, use native share
        Share.share(
          shareText,
          subject: 'Amazing Hotel: $hotelName',
        );
      }
    } catch (e) {
      // Fallback if share fails
      _showShareFallback(shareText);
    }
  }

  void _showShareFallback(String text) {
    // Copy to clipboard and show notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Hotel details copied to clipboard!'),
        backgroundColor: WPConfig.navbarColor,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
    // Note: In a real implementation, you'd also copy to clipboard here
    // using Clipboard.setData(ClipboardData(text: text));
  }

  Widget _buildMapSection(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(color: Colors.grey.shade200),
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
          Text(
            'Location',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 22 : 18,
              color: Colors.black,
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),

          // Map placeholder with location info
          Container(
            width: double.infinity,
            height: isTablet ? 200 : 150,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: isTablet ? 48 : 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${widget.hotel.latitude!.toStringAsFixed(4)}, ${widget.hotel.longitude!.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton.small(
                    onPressed: () => _openInMaps(),
                    backgroundColor: Colors.white,
                    child: Icon(Icons.map, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12),

          // Location details
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey[600], size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${widget.hotel.city ?? 'City'}, ${widget.hotel.country ?? 'Country'}',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openInMaps() async {
    final lat = widget.hotel.latitude;
    final lng = widget.hotel.longitude;
    final hotelName = widget.hotel.name ?? 'Hotel';

    if (lat != null && lng != null) {
      final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }

  Widget _buildAnimatedSection(Widget child, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildRoomsContent(bool isTablet) {
    final rooms = [
      {
        'name': 'Standard Double Room',
        'price': '\$120',
        'guests': '2 adults',
        'size': '25 m²',
        'bed': '1 double bed',
        'amenities': [
          'Free Wi-Fi',
          'Air conditioning',
          'Private bathroom',
          'TV'
        ],
      },
      {
        'name': 'Deluxe Suite',
        'price': '\$200',
        'guests': '2 adults + 1 child',
        'size': '45 m²',
        'bed': '1 king bed + sofa bed',
        'amenities': [
          'Free Wi-Fi',
          'Air conditioning',
          'Balcony',
          'Mini bar',
          'TV'
        ],
      },
      {
        'name': 'Family Room',
        'price': '\$180',
        'guests': '4 adults',
        'size': '35 m²',
        'bed': '2 double beds',
        'amenities': [
          'Free Wi-Fi',
          'Air conditioning',
          'Private bathroom',
          'TV',
          'Coffee maker'
        ],
      },
    ];

    return Column(
      children: rooms
          .map((room) => _buildRoomItem(
                room['name'] as String,
                room['price'] as String,
                room['guests'] as String,
                room['size'] as String,
                room['bed'] as String,
                room['amenities'] as List<String>,
                isTablet,
              ))
          .toList(),
    );
  }

  Widget _buildReviewsContent(bool isTablet) {
    final reviews = [
      {
        'name': 'John Smith',
        'rating': 4.5,
        'date': '2 days ago',
        'comment':
            'Excellent hotel with great service. The staff was very friendly and helpful.',
        'country': 'United States',
      },
      {
        'name': 'Maria Garcia',
        'rating': 5.0,
        'date': '1 week ago',
        'comment': 'Perfect location and beautiful rooms. Highly recommended!',
        'country': 'Spain',
      },
      {
        'name': 'Ahmed Hassan',
        'rating': 4.0,
        'date': '2 weeks ago',
        'comment': 'Good value for money. Clean rooms and decent facilities.',
        'country': 'Egypt',
      },
    ];

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 12 : 8,
            vertical: isTablet ? 6 : 4,
          ),
          decoration: BoxDecoration(
            color: WPConfig.navbarColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                color: Colors.white,
                size: isTablet ? 16 : 14,
              ),
              SizedBox(width: 4),
              Text(
                '4.5 Overall Rating',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 14 : 12,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isTablet ? 20 : 16),
        ...reviews
            .map((review) => _buildReviewItem(
                  review['name'] as String,
                  review['rating'] as double,
                  review['date'] as String,
                  review['comment'] as String,
                  review['country'] as String,
                  isTablet,
                ))
            .toList(),
      ],
    );
  }

  Widget _buildAttractionsContent(bool isTablet) {
    final attractions = [
      {
        'name': 'City Center',
        'distance': '0.5 km',
        'type': 'Shopping',
        'icon': Icons.shopping_bag,
      },
      {
        'name': 'National Museum',
        'distance': '1.2 km',
        'type': 'Culture',
        'icon': Icons.museum,
      },
      {
        'name': 'Central Park',
        'distance': '0.8 km',
        'type': 'Nature',
        'icon': Icons.park,
      },
      {
        'name': 'Beach Resort',
        'distance': '3.5 km',
        'type': 'Recreation',
        'icon': Icons.beach_access,
      },
      {
        'name': 'Airport',
        'distance': '15 km',
        'type': 'Transport',
        'icon': Icons.flight,
      },
    ];

    return Column(
      children: attractions
          .map((attraction) => _buildAttractionItem(
                attraction['name'] as String,
                attraction['distance'] as String,
                attraction['type'] as String,
                attraction['icon'] as IconData,
                isTablet,
              ))
          .toList(),
    );
  }

  Widget _buildPoliciesContent(bool isTablet) {
    return Column(
      children: [
        _buildPolicyItem(
          Icons.login,
          'Check-in',
          'From 3:00 PM',
          WPConfig.navbarColor,
          isTablet,
        ),
        _buildPolicyItem(
          Icons.logout,
          'Check-out',
          'Until 12:00 PM',
          WPConfig.navbarColor,
          isTablet,
        ),
        _buildPolicyItem(
          Icons.cancel_outlined,
          'Cancellation',
          'Free cancellation until 24 hours before check-in',
          WPConfig.navbarColor,
          isTablet,
        ),
        _buildPolicyItem(
          Icons.child_care,
          'Age restriction',
          'Children of all ages are welcome',
          WPConfig.navbarColor,
          isTablet,
        ),
        _buildPolicyItem(
          Icons.pets,
          'Pets',
          'Pets are not allowed',
          WPConfig.navbarColor,
          isTablet,
        ),
        _buildPolicyItem(
          Icons.payment,
          'Payment',
          'Cash, Credit Card accepted',
          WPConfig.navbarColor,
          isTablet,
        ),
      ],
    );
  }

  Widget _buildPoliciesSection(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(color: Colors.grey.shade200),
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
          Text(
            'Hotel Policies',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 22 : 18,
              color: Colors.black,
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          _buildPolicyItem(
            Icons.login,
            'Check-in',
            'From 3:00 PM',
            WPConfig.navbarColor,
            isTablet,
          ),
          _buildPolicyItem(
            Icons.logout,
            'Check-out',
            'Until 12:00 PM',
            WPConfig.navbarColor,
            isTablet,
          ),
          _buildPolicyItem(
            Icons.cancel_outlined,
            'Cancellation',
            'Free cancellation until 24 hours before check-in',
            WPConfig.navbarColor,
            isTablet,
          ),
          _buildPolicyItem(
            Icons.child_care,
            'Age restriction',
            'Children of all ages are welcome',
            WPConfig.navbarColor,
            isTablet,
          ),
          _buildPolicyItem(
            Icons.pets,
            'Pets',
            'Pets are not allowed',
            WPConfig.navbarColor,
            isTablet,
          ),
          _buildPolicyItem(
            Icons.payment,
            'Payment',
            'Cash, Credit Card accepted',
            WPConfig.navbarColor,
            isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildAttractionsSection(bool isTablet) {
    final attractions = [
      {
        'name': 'City Center',
        'distance': '0.5 km',
        'type': 'Shopping',
        'icon': Icons.shopping_bag,
      },
      {
        'name': 'National Museum',
        'distance': '1.2 km',
        'type': 'Culture',
        'icon': Icons.museum,
      },
      {
        'name': 'Central Park',
        'distance': '0.8 km',
        'type': 'Nature',
        'icon': Icons.park,
      },
      {
        'name': 'Beach Resort',
        'distance': '3.5 km',
        'type': 'Recreation',
        'icon': Icons.beach_access,
      },
      {
        'name': 'Airport',
        'distance': '15 km',
        'type': 'Transport',
        'icon': Icons.flight,
      },
    ];

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(color: Colors.grey.shade200),
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
          Text(
            'Nearby Attractions',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 22 : 18,
              color: Colors.black,
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          ...attractions
              .map((attraction) => _buildAttractionItem(
                    attraction['name'] as String,
                    attraction['distance'] as String,
                    attraction['type'] as String,
                    attraction['icon'] as IconData,
                    isTablet,
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildAttractionItem(
      String name, String distance, String type, IconData icon, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 12 : 10),
            decoration: BoxDecoration(
              color: WPConfig.navbarColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: WPConfig.navbarColor,
              size: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 16 : 14,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      ' • ',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      distance,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: WPConfig.navbarColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(bool isTablet) {
    final reviews = [
      {
        'name': 'John Smith',
        'rating': 4.5,
        'date': '2 days ago',
        'comment':
            'Excellent hotel with great service. The staff was very friendly and helpful.',
        'country': 'United States',
      },
      {
        'name': 'Maria Garcia',
        'rating': 5.0,
        'date': '1 week ago',
        'comment': 'Perfect location and beautiful rooms. Highly recommended!',
        'country': 'Spain',
      },
      {
        'name': 'Ahmed Hassan',
        'rating': 4.0,
        'date': '2 weeks ago',
        'comment': 'Good value for money. Clean rooms and decent facilities.',
        'country': 'Egypt',
      },
    ];

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(color: Colors.grey.shade200),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Guest Reviews',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 22 : 18,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 12 : 8,
                  vertical: isTablet ? 6 : 4,
                ),
                decoration: BoxDecoration(
                  color: WPConfig.navbarColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.white,
                      size: isTablet ? 16 : 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '4.5',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 14 : 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),
          ...reviews
              .map((review) => _buildReviewItem(
                    review['name'] as String,
                    review['rating'] as double,
                    review['date'] as String,
                    review['comment'] as String,
                    review['country'] as String,
                    isTablet,
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String name, double rating, String date,
      String comment, String country, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    country,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: isTablet ? 16 : 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 14 : 12,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            comment,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsSection(bool isTablet) {
    final rooms = [
      {
        'name': 'Standard Double Room',
        'price': '\$120',
        'guests': '2 adults',
        'size': '25 m²',
        'bed': '1 double bed',
        'amenities': [
          'Free Wi-Fi',
          'Air conditioning',
          'Private bathroom',
          'TV'
        ],
      },
      {
        'name': 'Deluxe Suite',
        'price': '\$200',
        'guests': '2 adults + 1 child',
        'size': '45 m²',
        'bed': '1 king bed + sofa bed',
        'amenities': [
          'Free Wi-Fi',
          'Air conditioning',
          'Balcony',
          'Mini bar',
          'TV'
        ],
      },
      {
        'name': 'Family Room',
        'price': '\$180',
        'guests': '4 adults',
        'size': '35 m²',
        'bed': '2 double beds',
        'amenities': [
          'Free Wi-Fi',
          'Air conditioning',
          'Private bathroom',
          'TV',
          'Coffee maker'
        ],
      },
    ];

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(color: Colors.grey.shade200),
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
          Text(
            'Available Rooms',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 22 : 18,
              color: Colors.black,
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          ...rooms
              .map((room) => _buildRoomItem(
                    room['name'] as String,
                    room['price'] as String,
                    room['guests'] as String,
                    room['size'] as String,
                    room['bed'] as String,
                    room['amenities'] as List<String>,
                    isTablet,
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildRoomItem(String name, String price, String guests, String size,
      String bed, List<String> amenities, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room header with image and title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room image
              Container(
                width: isTablet ? 120 : 90,
                height: isTablet ? 90 : 70,
                margin: EdgeInsets.all(isTablet ? 16 : 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          WPConfig.navbarColor.withOpacity(0.1),
                          WPConfig.navbarColor.withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.bed_outlined,
                        size: isTablet ? 32 : 24,
                        color: WPConfig.navbarColor.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ),

              // Room info
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: isTablet ? 16 : 12,
                    right: isTablet ? 16 : 12,
                    bottom: isTablet ? 8 : 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 18 : 16,
                          color: Colors.blue[700],
                        ),
                      ),
                      SizedBox(height: isTablet ? 8 : 6),

                      // Room details
                      _buildRoomDetailRow(Icons.single_bed, bed, isTablet),
                      SizedBox(height: isTablet ? 4 : 3),
                      _buildRoomDetailRow(Icons.straighten, size, isTablet),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Amenities with icons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic amenities with icons
                Wrap(
                  spacing: isTablet ? 16 : 12,
                  runSpacing: isTablet ? 8 : 6,
                  children: [
                    _buildAmenityIcon(
                        Icons.ac_unit, 'Air conditioning', isTablet),
                    _buildAmenityIcon(
                        Icons.bathroom_outlined, 'Private bathroom', isTablet),
                    _buildAmenityIcon(Icons.wifi, 'Internet', isTablet),
                    _buildAmenityIcon(Icons.check, 'Balcony', isTablet),
                    _buildAmenityIcon(Icons.tv, 'Flat-screen TV', isTablet),
                    _buildAmenityIcon(Icons.landscape, 'View', isTablet),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: isTablet ? 16 : 12),

          // Pricing section
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                // Left pricing card
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(isTablet ? 16 : 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.people_outline,
                                size: isTablet ? 16 : 14,
                                color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Text(
                              'Price for 2 adults',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isTablet ? 8 : 6),

                        // Policies
                        _buildPolicyItem(
                            Icons.check,
                            'Free cancellation',
                            'before 6:00 PM on 23 Aug 2025',
                            Colors.green,
                            isTablet),
                        _buildPolicyItem(Icons.check, 'No prepayment needed',
                            'pay at the property', Colors.green, isTablet),
                        _buildPolicyItem(
                            Icons.credit_card_off,
                            'No credit card needed',
                            '',
                            Colors.green,
                            isTablet),
                        _buildPolicyItem(Icons.restaurant, 'Breakfast included',
                            '', Colors.green, isTablet),

                        SizedBox(height: isTablet ? 12 : 8),

                        // Discount
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_offer,
                                  size: 12, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Genius 14% discount',
                                style: TextStyle(
                                  fontSize: isTablet ? 12 : 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Applied to the price before taxes and fees',
                          style: TextStyle(
                            fontSize: isTablet ? 11 : 9,
                            color: Colors.grey[600],
                          ),
                        ),

                        SizedBox(height: isTablet ? 12 : 8),

                        // Discount badges
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '14% off',
                                style: TextStyle(
                                  fontSize: isTablet ? 12 : 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[700],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Genius Discount',
                                style: TextStyle(
                                  fontSize: isTablet ? 12 : 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: isTablet ? 16 : 12),

                        // Price
                        Text(
                          'Price for 1 night (23 Aug - 24 Aug)',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'US\$${(double.parse(price.replaceAll('\$', '')) * 1.2).toInt()}',
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                color: Colors.red,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'US$price',
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.info_outline,
                                size: 16, color: Colors.blue),
                          ],
                        ),
                        Text(
                          '+US\$${(double.parse(price.replaceAll('\$', '')) * 0.15).toStringAsFixed(2)} taxes and fees',
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 10,
                            color: Colors.grey[600],
                          ),
                        ),

                        SizedBox(height: isTablet ? 16 : 12),

                        // Select button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => _navigateToBooking(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.blue[700]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: isTablet ? 12 : 10),
                            ),
                            child: Text(
                              'Select',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 16 : 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right pricing card (if multiple options)
                if (false) // Set to true if you want to show multiple pricing options
                  Container(
                    width: 1,
                    height: 200,
                    color: Colors.grey.shade200,
                  ),
              ],
            ),
          ),

          // Availability notice
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isTablet ? 8 : 6),
            decoration: BoxDecoration(
              color: Colors.red[50],
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Text(
              'Only ${(guests.split(' ')[0] == '2') ? '2' : '1'} room${(guests.split(' ')[0] == '2') ? 's' : ''} left on Booking.com',
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomDetailRow(IconData icon, String text, bool isTablet) {
    return Row(
      children: [
        Icon(
          icon,
          size: isTablet ? 16 : 14,
          color: Colors.grey[600],
        ),
        SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildAmenityIcon(IconData icon, String label, bool isTablet) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: isTablet ? 16 : 14,
          color: Colors.grey[600],
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 12 : 11,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildPolicyItem(IconData icon, String title, String subtitle,
      Color color, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 4 : 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: isTablet ? 16 : 14,
            color: color,
          ),
          SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 13 : 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 11,
                      color: color,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomDetail(IconData icon, String text, bool isTablet) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: isTablet ? 16 : 14,
          color: Colors.grey[600],
        ),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Future<void> _loadQuestions() async {
    try {
      // Temporarily disable SharedPreferences to prevent platform channel errors
      // This will use in-memory storage only until the platform issue is resolved
      if (mounted) {
        setState(() {
          userQuestions = [];
          totalQuestionCount = 8;
        });
      }

      // TODO: Re-enable SharedPreferences once platform channel issue is fixed
      /*
      final prefs = await SharedPreferences.getInstance();
      final hotelKey = 'hotel_questions_${widget.hotel.id}';
      final questionsJson = prefs.getString(hotelKey);
      
      if (questionsJson != null && questionsJson.isNotEmpty) {
        final List<dynamic> decodedQuestions = json.decode(questionsJson);
        if (mounted) {
          setState(() {
            userQuestions = decodedQuestions.map((q) => {
              'question': q['question'],
              'date': DateTime.parse(q['date']),
              'answered': q['answered'],
            }).toList();
            totalQuestionCount = 8 + userQuestions.length; // Base count + user questions
          });
        }
      }
      */
    } catch (e) {
      // Silently handle SharedPreferences errors - continue with default values
      print('Warning: Could not load saved questions: $e');
      if (mounted) {
        setState(() {
          userQuestions = [];
          totalQuestionCount = 8;
        });
      }
    }
  }

  Future<void> _saveQuestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hotelKey = 'hotel_questions_${widget.hotel.id}';
      final questionsJson = json.encode(userQuestions
          .map((q) => {
                'question': q['question'],
                'date': q['date'].toIso8601String(),
                'answered': q['answered'],
              })
          .toList());

      await prefs.setString(hotelKey, questionsJson);
    } catch (e) {
      // Silently handle SharedPreferences errors - don't crash the app
      print('Warning: Could not save questions: $e');
    }
  }

  void _showAllQuestionsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AllQuestionsPage(
          hotel: widget.hotel,
          userQuestions: userQuestions,
          onQuestionAdded: (question) {
            setState(() {
              userQuestions.add(question);
              totalQuestionCount = 8 + userQuestions.length;
            });
            _saveQuestions();
          },
        ),
      ),
    );
  }

  void _showAskQuestionDialog(bool isTablet) {
    final TextEditingController questionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Ask a Question',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 22 : 18,
              color: Colors.black,
            ),
          ),
          content: Container(
            width: isTablet ? 400 : double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your question will be answered by the property or other travelers.',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: isTablet ? 12 : 8),
                TextField(
                  controller: questionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'What would you like to know?',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: WPConfig.navbarColor),
                    ),
                    isDense: true,
                  ),
                  style: TextStyle(fontSize: isTablet ? 14 : 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size(60, 32),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isTablet ? 14 : 12,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (questionController.text.trim().isNotEmpty) {
                  setState(() {
                    userQuestions.add({
                      'question': questionController.text.trim(),
                      'date': DateTime.now(),
                      'answered': false,
                    });
                    totalQuestionCount = 8 + userQuestions.length;
                  });
                  _saveQuestions();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Your question has been submitted!'),
                      backgroundColor: WPConfig.navbarColor,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: WPConfig.navbarColor,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size(80, 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'Submit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 14 : 12,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class AllQuestionsPage extends StatefulWidget {
  final Hotel hotel;
  final List<Map<String, dynamic>> userQuestions;
  final Function(Map<String, dynamic>) onQuestionAdded;

  const AllQuestionsPage({
    Key? key,
    required this.hotel,
    required this.userQuestions,
    required this.onQuestionAdded,
  }) : super(key: key);

  @override
  State<AllQuestionsPage> createState() => _AllQuestionsPageState();
}

class _AllQuestionsPageState extends State<AllQuestionsPage> {
  final List<Map<String, dynamic>> defaultQuestions = [
    {
      'question': 'Hi - can I check in early?',
      'answer': 'Yes, but based on other availability and check outs.',
      'date': '8 Feb 2024',
      'isDefault': true,
    },
    {
      'question': 'Is breakfast included in the room rate?',
      'answer': 'Continental breakfast is included for all guests.',
      'date': '6 Feb 2024',
      'isDefault': true,
    },
    {
      'question': 'Do you have airport shuttle service?',
      'answer':
          'Yes, we provide complimentary airport shuttle service every hour.',
      'date': '5 Feb 2024',
      'isDefault': true,
    },
    {
      'question': 'Is there free WiFi in the rooms?',
      'answer': 'Yes, high-speed WiFi is complimentary throughout the hotel.',
      'date': '4 Feb 2024',
      'isDefault': true,
    },
    {
      'question': 'What time is checkout?',
      'answer':
          'Standard checkout time is 12:00 PM. Late checkout available upon request.',
      'date': '3 Feb 2024',
      'isDefault': true,
    },
    {
      'question': 'Do you allow pets?',
      'answer':
          'Unfortunately, pets are not allowed except for service animals.',
      'date': '2 Feb 2024',
      'isDefault': true,
    },
    {
      'question': 'Is there parking available?',
      'answer': 'Yes, we have both self-parking and valet parking available.',
      'date': '1 Feb 2024',
      'isDefault': true,
    },
    {
      'question': 'Can I cancel my reservation?',
      'answer': 'Free cancellation up to 24 hours before check-in.',
      'date': '31 Jan 2024',
      'isDefault': true,
    },
  ];

  void _showAskQuestionDialog() {
    final TextEditingController questionController = TextEditingController();
    final isTablet = MediaQuery.of(context).size.width >= 768;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Ask a Question',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 22 : 18,
              color: Colors.black,
            ),
          ),
          content: Container(
            width: isTablet ? 400 : double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your question will be answered by the property or other travelers.',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: isTablet ? 12 : 8),
                TextField(
                  controller: questionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'What would you like to know?',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: WPConfig.navbarColor),
                    ),
                    isDense: true,
                  ),
                  style: TextStyle(fontSize: isTablet ? 14 : 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size(60, 32),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isTablet ? 14 : 12,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (questionController.text.trim().isNotEmpty) {
                  final newQuestion = {
                    'question': questionController.text.trim(),
                    'date': DateTime.now(),
                    'answered': false,
                  };
                  widget.onQuestionAdded(newQuestion);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Your question has been submitted!'),
                      backgroundColor: WPConfig.navbarColor,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: WPConfig.navbarColor,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size(80, 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'Submit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 14 : 12,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768;
    final allQuestions = [...defaultQuestions, ...widget.userQuestions];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'All Questions',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: WPConfig.navbarColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header with hotel info
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            color: WPConfig.navbarColor.withOpacity(0.1),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.hotel.name ?? 'Hotel',
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Text(
                  '${allQuestions.length} questions',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: WPConfig.navbarColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Questions list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              itemCount: allQuestions.length,
              itemBuilder: (context, index) {
                final question = allQuestions[index];
                final isDefault = question['isDefault'] == true;

                return Container(
                  margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                    border: Border.all(color: Colors.grey.shade200),
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
                      // Question
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            color: WPConfig.navbarColor,
                            size: isTablet ? 24 : 20,
                          ),
                          SizedBox(width: isTablet ? 12 : 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  question['question'],
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  isDefault
                                      ? question['date']
                                      : DateFormat('d MMM yyyy')
                                          .format(question['date']),
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isDefault)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 10 : 8,
                                vertical: isTablet ? 4 : 2,
                              ),
                              decoration: BoxDecoration(
                                color: WPConfig.navbarColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Your Question',
                                style: TextStyle(
                                  fontSize: isTablet ? 12 : 10,
                                  color: WPConfig.navbarColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Answer (only for default questions)
                      if (isDefault && question['answer'] != null) ...[
                        SizedBox(height: isTablet ? 16 : 12),
                        Container(
                          padding: EdgeInsets.all(isTablet ? 16 : 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius:
                                BorderRadius.circular(isTablet ? 12 : 8),
                          ),
                          child: Text(
                            question['answer'],
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],

                      // Pending status for user questions
                      if (!isDefault) ...[
                        SizedBox(height: isTablet ? 12 : 8),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: isTablet ? 16 : 14,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Waiting for answer...',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: Colors.orange,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Floating action button to ask new question
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAskQuestionDialog,
        backgroundColor: WPConfig.navbarColor,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Ask Question',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
