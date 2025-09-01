import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../config/wp_config.dart';
import '../../models/hotel.dart';
import 'components/hotel_card.dart';

class SearchResultsPage extends ConsumerStatefulWidget {
  final List<Hotel> hotels;
  final String searchQuery;

  const SearchResultsPage({
    Key? key,
    required this.hotels,
    required this.searchQuery,
  }) : super(key: key);

  @override
  ConsumerState<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends ConsumerState<SearchResultsPage> {
  String _sortBy = 'recommended';
  double _minRating = 0.0;
  List<String> _selectedAmenities = [];

  @override
  Widget build(BuildContext context) {
    final primaryColor = WPConfig.navbarColor;
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: _buildCustomAppBar(context, primaryColor, isTablet),
      ),
      body: _buildMainContent(isTablet, primaryColor),
    );
  }

  Widget _buildCustomAppBar(
      BuildContext context, Color primaryColor, bool isTablet) {
    return Container(
      color: primaryColor,
      child: SafeArea(
        child: Container(
          height: 80,
          child: Row(
            children: [
              // Back button
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              // Title
              Expanded(
                child: Center(
                  child: Text(
                    'search_results'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 20 : 15,
                      fontWeight: FontWeight.bold,
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

  Widget _buildMainContent(bool isTablet, Color primaryColor) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'search_results_for'.tr(args: [widget.searchQuery]),
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'hotels_found'.tr(args: [widget.hotels.length.toString()]),
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        // Filter Bar
        _buildFilterBar(isTablet, primaryColor),
        Expanded(
          child: _buildFilteredResults(isTablet, primaryColor),
        ),
      ],
    );
  }

  Widget _buildFilterBar(bool isTablet, Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'sort_filter'.tr(),
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFilterButton(
                  'sort'.tr(),
                  Icons.sort,
                  () => _showSortModal(context, isTablet, primaryColor),
                  isTablet,
                  primaryColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildFilterButton(
                  'rating'.tr(),
                  Icons.star,
                  () => _showRatingModal(context, isTablet, primaryColor),
                  isTablet,
                  primaryColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildFilterButton(
                  'filters'.tr(),
                  Icons.filter_list,
                  () => _showFilterModal(context, isTablet, primaryColor),
                  isTablet,
                  primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, IconData icon, VoidCallback onTap,
      bool isTablet, Color primaryColor) {
    // Check if this button is currently active
    bool isActive = false;
    if (label == 'sort'.tr()) {
      isActive = _sortBy != 'recommended';
    } else if (label == 'rating'.tr()) {
      isActive = _minRating > 0;
    } else if (label == 'filters'.tr()) {
      isActive = _selectedAmenities.isNotEmpty;
    }

    return Container(
      height: isTablet ? 56 : 48,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : primaryColor,
        borderRadius: BorderRadius.circular(16),
        border: isActive ? Border.all(color: primaryColor, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: isActive
                ? primaryColor.withOpacity(0.3)
                : primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: isTablet ? 20 : 18,
                  color: isActive ? primaryColor : Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? primaryColor : Colors.white,
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Show indicator if active
                if (isActive) ...[
                  SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilteredResults(bool isTablet, Color primaryColor) {
    // Apply filters and sorting
    final filteredHotels = _applyFilters(widget.hotels);
    final sortedHotels = List<Hotel>.from(filteredHotels);
    _sortHotels(sortedHotels);

    if (sortedHotels.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.filter_list,
                size: isTablet ? 80 : 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'no_hotels_match_filters'.tr(),
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'try_adjusting_filters'.tr(),
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _minRating = 0.0;
                    _selectedAmenities.clear();
                    _sortBy = 'recommended';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text('clear_all_filters'.tr()),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      itemCount: sortedHotels.length,
      itemBuilder: (context, index) {
        final hotel = sortedHotels[index];
        return HotelCard(
          hotel: hotel,
          city: null,
          country: null,
          onFavoriteTap: null,
          isFavorite: false,
        );
      },
    );
  }

  List<Hotel> _applyFilters(List<Hotel> hotels) {
    List<Hotel> filtered = List.from(hotels);

    // Apply rating filter
    if (_minRating > 0) {
      filtered =
          filtered.where((hotel) => (hotel.rate ?? 0) >= _minRating).toList();
    }

    // Apply amenities filter
    if (_selectedAmenities.isNotEmpty) {
      filtered = filtered.where((hotel) {
        // Check if hotel has any of the selected amenities
        return _selectedAmenities.any((amenity) {
          switch (amenity) {
            case 'WiFi':
              return true; // Assume all hotels have WiFi for now
            case 'Pool':
              return true; // Assume all hotels have pool for now
            case 'Gym':
              return true; // Assume all hotels have gym for now
            case 'Restaurant':
              return true; // Assume all hotels have restaurant for now
            case 'Spa':
              return true; // Assume all hotels have spa for now
            case 'Parking':
              return true; // Assume all hotels have parking for now
            case 'Air Conditioning':
              return true; // Assume all hotels have AC for now
            case 'Room Service':
              return true; // Assume all hotels have room service for now
            default:
              return false;
          }
        });
      }).toList();
    }

    return filtered;
  }

  void _sortHotels(List<Hotel> hotels) {
    switch (_sortBy) {
      case 'price_low':
        hotels.sort((a, b) =>
            _extractPriceFromHotel(a).compareTo(_extractPriceFromHotel(b)));
        break;
      case 'price_high':
        hotels.sort((a, b) =>
            _extractPriceFromHotel(b).compareTo(_extractPriceFromHotel(a)));
        break;
      case 'rating':
        hotels.sort((a, b) => (b.rate ?? 0).compareTo(a.rate ?? 0));
        break;
      case 'name':
        hotels.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
        break;
      default:
        // recommended - keep original order
        break;
    }
  }

  double _extractPriceFromHotel(Hotel hotel) {
    if (hotel.priceRange != null) {
      final priceStr = hotel.priceRange!.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(priceStr) ?? 100.0;
    }
    return 100.0;
  }

  void _showSortModal(BuildContext context, bool isTablet, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSortModal(context, isTablet, primaryColor),
    );
  }

  void _showRatingModal(
      BuildContext context, bool isTablet, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRatingModal(context, isTablet, primaryColor),
    );
  }

  void _showFilterModal(
      BuildContext context, bool isTablet, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterModal(context, isTablet, primaryColor),
    );
  }

  Widget _buildSortModal(
      BuildContext context, bool isTablet, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Enhanced Header with gradient
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor,
                    primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.4),
                    blurRadius: 25,
                    offset: Offset(0, 15),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.sort,
                      color: Colors.white,
                      size: isTablet ? 28 : 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'sort_hotels'.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 24 : 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'choose_preferred_order'.tr(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.all(8),
                      constraints: BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSortOption(
                      context,
                      'recommended',
                      'recommended'.tr(),
                      Icons.recommend,
                      'best_matches'.tr(),
                      isTablet,
                      primaryColor),
                  _buildSortOption(
                      context,
                      'price_low',
                      'price_low_to_high'.tr(),
                      Icons.trending_up,
                      'affordable_first'.tr(),
                      isTablet,
                      primaryColor),
                  _buildSortOption(
                      context,
                      'price_high',
                      'price_high_to_low'.tr(),
                      Icons.trending_down,
                      'luxury_first'.tr(),
                      isTablet,
                      primaryColor),
                  _buildSortOption(
                      context,
                      'rating',
                      'highest_rated'.tr(),
                      Icons.star,
                      'top_rated_first'.tr(),
                      isTablet,
                      primaryColor),
                  _buildSortOption(
                      context,
                      'name',
                      'alphabetical'.tr(),
                      Icons.sort_by_alpha,
                      'a_to_z_order'.tr(),
                      isTablet,
                      primaryColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, String value, String title,
      IconData icon, String subtitle, bool isTablet, Color primaryColor) {
    final isSelected = _sortBy == value;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? primaryColor : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              _sortBy = value;
            });
            Navigator.pop(context);
          },
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    size: isTablet ? 24 : 20,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? primaryColor : Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: isSelected
                              ? primaryColor.withOpacity(0.8)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: primaryColor,
                    size: isTablet ? 24 : 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingModal(
      BuildContext context, bool isTablet, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Enhanced Header with gradient
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor,
                    primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.4),
                    blurRadius: 25,
                    offset: Offset(0, 15),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.star,
                      color: Colors.white,
                      size: isTablet ? 28 : 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'filter_by_rating'.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 24 : 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'choose_minimum_rating'.tr(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.all(8),
                      constraints: BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Current rating display
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'minimum_rating'.tr(),
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 16),
                        // Large rating number
                        Text(
                          '${_minRating.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: isTablet ? 48 : 40,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            if (index < _minRating.floor()) {
                              return Icon(Icons.star,
                                  color: Colors.amber, size: 28);
                            } else if (index == _minRating.floor() &&
                                _minRating % 1 > 0) {
                              return Icon(Icons.star_half,
                                  color: Colors.amber, size: 28);
                            } else {
                              return Icon(Icons.star_border,
                                  color: Colors.amber, size: 28);
                            }
                          }),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _getRatingText(_minRating),
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32),

                  // Star Rating Selection
                  Column(
                    children: [
                      Text(
                        'adjust_rating'.tr(),
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 16),
                      // Star rating container
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: [
                            // Current rating display
                            Text(
                              'current_rating'.tr() +
                                  ': ${_minRating.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            SizedBox(height: 16),
                            // Interactive stars
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                final starRating = index + 1.0;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _minRating = starRating;
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 4),
                                    child: Icon(
                                      _minRating >= starRating
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: _minRating >= starRating
                                          ? Colors.amber
                                          : Colors.grey[400],
                                      size: isTablet ? 40 : 36,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            SizedBox(height: 16),
                            // Rating text
                            Text(
                              _getRatingText(_minRating),
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            // Clear rating button
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _minRating = 0.0;
                                });
                              },
                              child: Text(
                                'clear_rating'.tr(),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: isTablet ? 14 : 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 32),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    height: isTablet ? 64 : 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {}); // Trigger rebuild to apply filters
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: primaryColor.withOpacity(0.3),
                      ),
                      child: Text(
                        'apply_rating_filter'.tr(),
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.bold,
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
    );
  }

  String _getRatingText(double rating) {
    if (rating >= 4.5) return 'exceptional'.tr();
    if (rating >= 4.0) return 'excellent'.tr();
    if (rating >= 3.5) return 'very_good'.tr();
    if (rating >= 3.0) return 'good'.tr();
    if (rating >= 2.5) return 'average'.tr();
    if (rating >= 2.0) return 'below_average'.tr();
    return 'poor'.tr();
  }

  Widget _buildFilterModal(
      BuildContext context, bool isTablet, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Enhanced Header with gradient
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor,
                    primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.4),
                    blurRadius: 25,
                    offset: Offset(0, 15),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.filter_list,
                      color: Colors.white,
                      size: isTablet ? 24 : 20,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'amenities_filters'.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 24 : 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'select_preferences'.tr(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.all(8),
                      constraints: BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'select_amenities'.tr(),
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Amenities grid
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: isTablet ? 3 : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildAmenityOption('WiFi', Icons.wifi,
                              'free_wifi'.tr(), isTablet, primaryColor),
                          _buildAmenityOption('Pool', Icons.pool,
                              'swimming_pool'.tr(), isTablet, primaryColor),
                          _buildAmenityOption('Gym', Icons.fitness_center,
                              'fitness_center'.tr(), isTablet, primaryColor),
                          _buildAmenityOption(
                              'Restaurant',
                              Icons.restaurant,
                              'on_site_restaurant'.tr(),
                              isTablet,
                              primaryColor),
                          _buildAmenityOption('Spa', Icons.spa,
                              'spa_wellness'.tr(), isTablet, primaryColor),
                          _buildAmenityOption('Parking', Icons.local_parking,
                              'free_parking'.tr(), isTablet, primaryColor),
                          _buildAmenityOption('Air Conditioning', Icons.ac_unit,
                              'air_conditioning'.tr(), isTablet, primaryColor),
                          _buildAmenityOption(
                              'Room Service',
                              Icons.room_service,
                              'room_service'.tr(),
                              isTablet,
                              primaryColor),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Apply Button
                    SizedBox(
                      width: double.infinity,
                      height: isTablet ? 64 : 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {}); // Trigger rebuild to apply filters
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: primaryColor.withOpacity(0.3),
                        ),
                        child: Text(
                          'apply_filters'.tr(),
                          style: TextStyle(
                            fontSize: isTablet ? 20 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  Widget _buildAmenityOption(String amenity, IconData icon, String description,
      bool isTablet, Color primaryColor) {
    final isSelected = _selectedAmenities.contains(amenity);

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? primaryColor : Colors.grey[200]!,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedAmenities.remove(amenity);
              } else {
                _selectedAmenities.add(amenity);
              }
            });
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    size: isTablet ? 24 : 20,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  amenity,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? primaryColor : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
