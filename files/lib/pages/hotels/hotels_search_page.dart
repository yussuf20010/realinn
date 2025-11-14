import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realinn/config/wp_config.dart';
import 'package:realinn/services/hotel_service.dart';
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
  Set<String> _selectedAmenities = <String>{};

  @override
  void initState() {
    super.initState();
    print(
        'HotelsSearchPage initState - initialHotels: ${widget.initialHotels?.length ?? 0}');
    print('Search query: ${widget.searchQuery}');
    if (widget.initialHotels != null && widget.initialHotels!.isNotEmpty) {
      _hotels = widget.initialHotels!;
      _isLoading = false;
      print('Using initial hotels: ${_hotels.length}');
    } else {
      print('Loading hotels from provider');
      _loadHotels();
    }
  }

  Future<void> _loadHotels() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final hotels = await HotelService.fetchHotels();
      setState(() {
        _hotels = hotels;
        _isLoading = false;
      });
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
      // Create a copy of the Set to avoid concurrent modification issues
      final selectedAmenitiesCopy = Set<String>.from(_selectedAmenities);
      filtered = filtered.where((hotel) {
        // Check if hotel has any of the selected amenities
        // For now, we'll use a simple check - you can enhance this based on your hotel data structure
        return selectedAmenitiesCopy.any((amenity) {
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
          height: isTablet ? 80.h : 70.h,
          color: primaryColor,
        ),
        // White content area with search box and buttons
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 16.w : 12.w),
          child: Column(
            children: [
              // Search Box with slight overlap
              Transform.translate(
                offset:
                    Offset(0, isTablet ? -25 : -20), // Overlap into blue area
                child: Container(
                  height: isTablet ? 60.h : 55.h,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor, width: 3.w),
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
                      SizedBox(width: 12.w),
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
                                    fontSize: isTablet ? 18.sp : 16.sp,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (hasDates) ...[
                                SizedBox(width: 16.w),
                                Flexible(
                                  child: Text(
                                    dateText,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: isTablet ? 14.sp : 13.sp,
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
                                    fontSize: isTablet ? 18.sp : 16.sp,
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

              SizedBox(height: isTablet ? 20.h : 16.h),

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
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.tune,
                      text: 'filter'.tr(),
                      onTap: _showFilters,
                      isTablet: isTablet,
                    ),
                  ),
                  SizedBox(width: 12.w),
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

              SizedBox(height: 16.h),
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
        height: isTablet ? 50.h : 45.h,
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
            SizedBox(width: 8.w),
            Text(
              text,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 16.sp : 14.sp,
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
              SizedBox(height: 16.h),
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
                  fontSize: isTablet ? 16.sp : 14.sp,
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
              SizedBox(height: 16.h),
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
                  fontSize: isTablet ? 16.sp : 14.sp,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
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
                          fontSize: isTablet ? 16.sp : 14.sp,
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
