import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realinn/config/wp_config.dart';
import 'package:realinn/controllers/hotel_controller.dart';
import 'package:realinn/models/hotel.dart';
import 'package:realinn/pages/home/components/hotel_card.dart';

class HotelsSearchPage extends ConsumerStatefulWidget {
  final String? searchQuery;
  final String? cityName;
  final String? countryName;
  final List<Hotel>? initialHotels;

  const HotelsSearchPage({
    Key? key,
    this.searchQuery,
    this.cityName,
    this.countryName,
    this.initialHotels,
  }) : super(key: key);

  @override
  ConsumerState<HotelsSearchPage> createState() => _HotelsSearchPageState();
}

class _HotelsSearchPageState extends ConsumerState<HotelsSearchPage> {
  List<Hotel> _hotels = [];
  bool _isLoading = true;
  String _sortBy = 'recommended';
  double _minRating = 0.0;
  List<String> _selectedAmenities = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialHotels != null) {
      _hotels = widget.initialHotels!;
      _isLoading = false;
    } else {
      _loadHotels();
    }
  }

  Future<void> _loadHotels() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final hotelsAsync = ref.read(hotelProvider);

      await hotelsAsync.when(
        data: (hotels) {
          setState(() {
            _hotels = hotels;
            _isLoading = false;
          });
        },
        loading: () {
          setState(() {
            _isLoading = true;
          });
        },
        error: (error, stack) {
          setState(() {
            _isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading hotels: $error')),
            );
          }
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
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

  List<Hotel> _applyFilters(List<Hotel> hotels) {
    List<Hotel> filtered = List.from(hotels);
    
    // Apply rating filter
    if (_minRating > 0) {
      filtered = filtered.where((hotel) => 
        (hotel.rate ?? 0) >= _minRating
      ).toList();
    }
    
    // Apply amenities filter
    if (_selectedAmenities.isNotEmpty) {
      filtered = filtered.where((hotel) {
        // Check if hotel has any of the selected amenities
        // For now, we'll use a simple check - you can enhance this based on your hotel data structure
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

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final primaryColor = WPConfig.navbarColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('All Hotels'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(isTablet, primaryColor),
          _buildResultsSummary(isTablet),
          Expanded(
            child: _buildHotelsList(isTablet, primaryColor),
          ),
        ],
      ),
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
            'Sort & Filter',
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
                  'Sort',
                  Icons.sort,
                  () => _showSortModal(context, isTablet, primaryColor),
                  isTablet,
                  primaryColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildFilterButton(
                  'Rating',
                  Icons.star,
                  () => _showRatingModal(context, isTablet, primaryColor),
                  isTablet,
                  primaryColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildFilterButton(
                  'Filters',
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
    return Container(
      height: isTablet ? 56 : 48,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
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
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSummary(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_hotels.length} hotels found',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (widget.searchQuery?.isNotEmpty == true)
                  Text(
                    'Search results for "${widget.searchQuery}"',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelsList(bool isTablet, Color primaryColor) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryColor),
            SizedBox(height: 16),
            Text(
              'Loading hotels...',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (_hotels.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.hotel_outlined,
                size: isTablet ? 80 : 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'No hotels found',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Try adjusting your search criteria',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Apply filters and sorting
    final filteredHotels = _applyFilters(_hotels);
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
                'No hotels match your filters',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Try adjusting your filters',
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
                child: Text('Clear All Filters'),
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
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: HotelCard(
            hotel: hotel,
            city: null,
            country: null,
            onFavoriteTap: null,
            isFavorite: false,
          ),
        );
      },
    );
  }

  void _showSortModal(BuildContext context, bool isTablet, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSortModal(context, isTablet, primaryColor),
    );
  }

  void _showRatingModal(
      BuildContext context, bool isTablet, Color primaryColor) {
    showModalBottomSheet(
      context: context,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.sort,
                  color: Colors.white,
                  size: isTablet ? 28 : 24,
                ),
                SizedBox(width: 16),
                Text(
                  'Sort By',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Content
          Container(
            constraints: BoxConstraints(maxHeight: 400),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                _buildSortOption(
                  context,
                  'recommended',
                  'Recommended',
                  Icons.recommend,
                  'Best matches for you',
                  isTablet,
                  primaryColor,
                ),
                _buildSortOption(
                  context,
                  'price_low',
                  'Price: Low to High',
                  Icons.trending_up,
                  'Cheapest first',
                  isTablet,
                  primaryColor,
                ),
                _buildSortOption(
                  context,
                  'price_high',
                  'Price: High to Low',
                  Icons.trending_down,
                  'Most expensive first',
                  isTablet,
                  primaryColor,
                ),
                _buildSortOption(
                  context,
                  'rating',
                  'Rating',
                  Icons.star,
                  'Highest rated first',
                  isTablet,
                  primaryColor,
                ),
                _buildSortOption(
                  context,
                  'name',
                  'Name',
                  Icons.sort_by_alpha,
                  'Alphabetical order',
                  isTablet,
                  primaryColor,
                ),
              ],
            ),
          ),
        ],
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.white,
                  size: isTablet ? 28 : 24,
                ),
                SizedBox(width: 16),
                Text(
                  'Minimum Rating',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                // Rating Display
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${_minRating.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: isTablet ? 48 : 40,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          if (index < _minRating.floor()) {
                            return Icon(Icons.star,
                                color: Colors.amber, size: 24);
                          } else if (index == _minRating.floor() &&
                              _minRating % 1 > 0) {
                            return Icon(Icons.star_half,
                                color: Colors.amber, size: 24);
                          } else {
                            return Icon(Icons.star_border,
                                color: Colors.amber, size: 24);
                          }
                        }),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _getRatingText(_minRating),
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // Slider
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adjust Rating',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: primaryColor,
                        inactiveTrackColor: Colors.grey[300],
                        thumbColor: primaryColor,
                        overlayColor: primaryColor.withOpacity(0.2),
                        trackHeight: 6,
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 12),
                        overlayShape:
                            RoundSliderOverlayShape(overlayRadius: 24),
                      ),
                      child: Slider(
                        value: _minRating,
                        min: 0,
                        max: 5,
                        divisions: 10,
                        label: _minRating.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            _minRating = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 32),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  height: isTablet ? 56 : 48,
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
                      'Apply Rating Filter',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
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
    );
  }

  String _getRatingText(double rating) {
    if (rating >= 4.5) return 'Exceptional';
    if (rating >= 4.0) return 'Excellent';
    if (rating >= 3.5) return 'Very Good';
    if (rating >= 3.0) return 'Good';
    if (rating >= 2.5) return 'Average';
    if (rating >= 2.0) return 'Below Average';
    return 'Poor';
  }

  Widget _buildFilterModal(
      BuildContext context, bool isTablet, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list,
                  color: Colors.white,
                  size: isTablet ? 28 : 24,
                ),
                SizedBox(width: 16),
                Text(
                  'Amenities & Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Select amenities you want in your hotel:',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildAmenityOption(
                          'WiFi',
                          Icons.wifi,
                          'Free wireless internet',
                          isTablet,
                          primaryColor,
                        ),
                        _buildAmenityOption(
                          'Pool',
                          Icons.pool,
                          'Swimming pool access',
                          isTablet,
                          primaryColor,
                        ),
                        _buildAmenityOption(
                          'Gym',
                          Icons.fitness_center,
                          'Fitness center',
                          isTablet,
                          primaryColor,
                        ),
                        _buildAmenityOption(
                          'Restaurant',
                          Icons.restaurant,
                          'On-site dining',
                          isTablet,
                          primaryColor,
                        ),
                        _buildAmenityOption(
                          'Spa',
                          Icons.spa,
                          'Wellness & spa services',
                          isTablet,
                          primaryColor,
                        ),
                        _buildAmenityOption(
                          'Parking',
                          Icons.local_parking,
                          'Free parking available',
                          isTablet,
                          primaryColor,
                        ),
                        _buildAmenityOption(
                          'Air Conditioning',
                          Icons.ac_unit,
                          'Climate control',
                          isTablet,
                          primaryColor,
                        ),
                        _buildAmenityOption(
                          'Room Service',
                          Icons.room_service,
                          '24/7 room service',
                          isTablet,
                          primaryColor,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    height: isTablet ? 56 : 48,
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
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
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
    );
  }

  Widget _buildAmenityOption(String amenity, IconData icon, String description,
      bool isTablet, Color primaryColor) {
    final isSelected = _selectedAmenities.contains(amenity);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
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
              if (isSelected) {
                _selectedAmenities.remove(amenity);
              } else {
                _selectedAmenities.add(amenity);
              }
            });
          },
          child: Padding(
            padding: EdgeInsets.all(16),
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
                        amenity,
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? primaryColor : Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 10,
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
}
