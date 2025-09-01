import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:realinn/config/wp_config.dart';
import 'package:realinn/controllers/hotel_controller.dart';
import 'package:realinn/models/hotel.dart';
import 'package:realinn/pages/home/components/hotel_card.dart';

class HotelsSearchPage extends ConsumerStatefulWidget {
  final String? searchQuery;
  final String? cityName;
  final String? countryName;
  final List<Hotel>? initialHotels;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int? rooms;

  const HotelsSearchPage({
    Key? key,
    this.searchQuery,
    this.cityName,
    this.countryName,
    this.initialHotels,
    this.checkInDate,
    this.checkOutDate,
    this.rooms,
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
      filtered =
          filtered.where((hotel) => (hotel.rate ?? 0) >= _minRating).toList();
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
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomHeader(primaryColor, isTablet),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _buildResultsSummary(isTablet),
                    Expanded(
                      child: _buildHotelsList(isTablet, primaryColor),
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

  Widget _buildCustomHeader(Color primaryColor, bool isTablet) {
    final hasQuery =
        (widget.searchQuery != null && widget.searchQuery!.isNotEmpty);
    final hasDates = widget.checkInDate != null && widget.checkOutDate != null;
    final String dateText = hasDates
        ? '${_formatDate(widget.checkInDate!)} - ${_formatDate(widget.checkOutDate!)}'
        : '';

    return Column(
      children: [
        // Blue background area
        Container(
          height: isTablet ? 80 : 70,
          color: primaryColor,
        ),
        // White content area with search box and buttons
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12),
          child: Column(
            children: [
              // Search Box with slight overlap
              Transform.translate(
                offset:
                    Offset(0, isTablet ? -25 : -20), // Overlap into blue area
                child: Container(
                  height: isTablet ? 60 : 55,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back,
                            color: Colors.black87, size: isTablet ? 28 : 24),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints:
                            BoxConstraints(minWidth: 40, minHeight: 40),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Row(
                          children: [
                            if (hasQuery) ...[
                              Flexible(
                                child: Text(
                                  widget.searchQuery ?? '',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isTablet ? 18 : 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (hasDates) ...[
                                SizedBox(width: 16),
                                Flexible(
                                  child: Text(
                                    dateText,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: isTablet ? 14 : 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ] else if (hasDates) ...[
                              Flexible(
                                child: Text(
                                  dateText,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isTablet ? 18 : 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ] else ...[
                              Text(
                                'all_hotels'.tr(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isTablet ? 18 : 16,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: isTablet ? 20 : 16),

              // Sort, Filter, Map buttons in white area
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.swap_vert,
                      text: 'sort'.tr(),
                      onTap: _showSortOptions,
                      isTablet: isTablet,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.tune,
                      text: 'filter'.tr(),
                      onTap: _showFilters,
                      isTablet: isTablet,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.map_outlined,
                      text: 'map'.tr(),
                      onTap: _showMap,
                      isTablet: isTablet,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isTablet ? 50 : 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.black,
              size: isTablet ? 22 : 20,
            ),
            SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 16 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'sort_by'.tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text('recommended'.tr()),
              trailing: _sortBy == 'recommended'
                  ? Icon(Icons.check, color: WPConfig.navbarColor)
                  : null,
              onTap: () {
                setState(() {
                  _sortBy = 'recommended';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('price_low_high'.tr()),
              trailing: _sortBy == 'price_low'
                  ? Icon(Icons.check, color: WPConfig.navbarColor)
                  : null,
              onTap: () {
                setState(() {
                  _sortBy = 'price_low';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('price_high_low'.tr()),
              trailing: _sortBy == 'price_high'
                  ? Icon(Icons.check, color: WPConfig.navbarColor)
                  : null,
              onTap: () {
                setState(() {
                  _sortBy = 'price_high';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('rating'.tr()),
              trailing: _sortBy == 'rating'
                  ? Icon(Icons.check, color: WPConfig.navbarColor)
                  : null,
              onTap: () {
                setState(() {
                  _sortBy = 'rating';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('distance'.tr()),
              trailing: _sortBy == 'distance'
                  ? Icon(Icons.check, color: WPConfig.navbarColor)
                  : null,
              onTap: () {
                setState(() {
                  _sortBy = 'distance';
                });
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'filters'.tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _minRating = 0.0;
                        _selectedAmenities.clear();
                      });
                      // Filters cleared
                    },
                    child: Text('clear_all'.tr()),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Rating Filter
                    Text(
                      'minimum_rating'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    Slider(
                      value: _minRating,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      label: _minRating.toString(),
                      onChanged: (value) {
                        setState(() {
                          _minRating = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),

                    // Amenities Filter
                    Text(
                      'amenities'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    ...[
                      'wifi',
                      'parking',
                      'pool',
                      'gym',
                      'spa',
                      'restaurant',
                      'bar',
                      'room_service'
                    ].map((amenity) => CheckboxListTile(
                          title: Text(amenity.tr()),
                          value: _selectedAmenities.contains(amenity),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedAmenities.add(amenity);
                              } else {
                                _selectedAmenities.remove(amenity);
                              }
                            });
                          },
                        )),
                  ],
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Filters applied
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WPConfig.navbarColor,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'apply_filters'.tr(),
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'select_city'.tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Popular cities
                    Text(
                      'popular_cities'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    ..._getPopularCities().map((city) => ListTile(
                          leading:
                              Icon(Icons.location_city, color: Colors.orange),
                          title: Text(
                            city['name']!,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            city['country']!,
                            style: TextStyle(color: Colors.black54),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: Colors.black54, size: 16),
                          onTap: () {
                            Navigator.pop(context);
                            _filterByCity(city['name']!);
                          },
                        )),
                    SizedBox(height: 20),

                    // All cities
                    Text(
                      'all_cities'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    ..._getAllCities().map((city) => ListTile(
                          leading:
                              Icon(Icons.location_on, color: Colors.orange),
                          title: Text(
                            city,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: Colors.black54, size: 16),
                          onTap: () {
                            Navigator.pop(context);
                            _filterByCity(city);
                          },
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    return '$day $month';
  }

  List<Map<String, String>> _getPopularCities() {
    return [
      {'name': 'Dubai', 'country': 'UAE'},
      {'name': 'Abu Dhabi', 'country': 'UAE'},
      {'name': 'Riyadh', 'country': 'Saudi Arabia'},
      {'name': 'Jeddah', 'country': 'Saudi Arabia'},
      {'name': 'Doha', 'country': 'Qatar'},
      {'name': 'Kuwait City', 'country': 'Kuwait'},
      {'name': 'Manama', 'country': 'Bahrain'},
      {'name': 'Muscat', 'country': 'Oman'},
    ];
  }

  List<String> _getAllCities() {
    return [
      'Dubai',
      'Abu Dhabi',
      'Sharjah',
      'Ajman',
      'Ras Al Khaimah',
      'Riyadh',
      'Jeddah',
      'Mecca',
      'Medina',
      'Dammam',
      'Doha',
      'Al Wakrah',
      'Al Rayyan',
      'Kuwait City',
      'Al Ahmadi',
      'Hawalli',
      'Manama',
      'Riffa',
      'Muharraq',
      'Muscat',
      'Salalah',
      'Nizwa',
      'Cairo',
      'Alexandria',
      'Luxor',
      'Istanbul',
      'Ankara',
      'Antalya',
      'London',
      'Paris',
      'Rome',
      'Barcelona',
      'New York',
      'Los Angeles',
      'Miami',
      'Tokyo',
      'Singapore',
      'Bangkok',
    ];
  }

  void _filterByCity(String cityName) {
    setState(() {
      _hotels = _hotels
          .where((hotel) =>
              hotel.location?.toLowerCase().contains(cityName.toLowerCase()) ??
              false)
          .toList();
    });
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
                'no_hotels_found'.tr(),
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'try_adjusting_search'.tr(),
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
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/hotel-details',
                arguments: {
                  'hotel': hotel,
                  'checkInDate': widget.checkInDate,
                  'checkOutDate': widget.checkOutDate,
                  'rooms': widget.rooms,
                },
              );
            },
            child: HotelCard(
              hotel: hotel,
              city: null,
              country: null,
              onFavoriteTap: null,
              isFavorite: false,
            ),
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
      child: SingleChildScrollView(
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
                    'sort_hotels'.tr(),
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
                    'recommended'.tr(),
                    Icons.recommend,
                    'best_matches'.tr(),
                    isTablet,
                    primaryColor,
                  ),
                  _buildSortOption(
                    context,
                    'price_low',
                    'price_low_to_high'.tr(),
                    Icons.trending_up,
                    'affordable_first'.tr(),
                    isTablet,
                    primaryColor,
                  ),
                  _buildSortOption(
                    context,
                    'price_high',
                    'price_high_to_low'.tr(),
                    Icons.trending_down,
                    'luxury_first'.tr(),
                    isTablet,
                    primaryColor,
                  ),
                  _buildSortOption(
                    context,
                    'rating',
                    'highest_rated'.tr(),
                    Icons.star,
                    'top_rated_first'.tr(),
                    isTablet,
                    primaryColor,
                  ),
                  _buildSortOption(
                    context,
                    'name',
                    'alphabetical'.tr(),
                    Icons.sort_by_alpha,
                    'a_to_z_order'.tr(),
                    isTablet,
                    primaryColor,
                  ),
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
                                    print('Rating changed to: $starRating');
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
                        print('Apply rating filter pressed');
                        print('Current rating filter: $_minRating');
                        Navigator.pop(context);
                        setState(() {}); // Trigger rebuild to apply filters
                        print('Filters applied, rebuilding...');
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
        child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                  'amenities_filters'.tr(),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'select_amenities_description'.tr(),
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 20),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      _buildAmenityOption(
                        'WiFi',
                        Icons.wifi,
                        'free_wireless_internet'.tr(),
                        isTablet,
                        primaryColor,
                      ),
                      _buildAmenityOption(
                        'Pool',
                        Icons.pool,
                        'swimming_pool_access'.tr(),
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
                  height: isTablet ? 64 : 56,
                  child: ElevatedButton(
                    onPressed: () {
                      print('Apply filters pressed');
                      print('Current amenities: $_selectedAmenities');
                      Navigator.pop(context);
                      setState(() {}); // Trigger rebuild to apply filters
                      print('Filters applied, rebuilding...');
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
        ]),
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
            print('Amenity tapped: $amenity, currently selected: $isSelected');
            setState(() {
              if (isSelected) {
                _selectedAmenities.remove(amenity);
                print('Removed amenity: $amenity');
              } else {
                _selectedAmenities.add(amenity);
                print('Added amenity: $amenity');
              }
            });
            print('Updated amenities: $_selectedAmenities');
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
