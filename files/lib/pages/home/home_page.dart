import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/wp_config.dart';
import '../../config/dynamic_config.dart';
import '../../models/hotel.dart';
import '../../models/location.dart';
import '../../controllers/location_controller.dart';
import '../../controllers/hotel_controller.dart';
import '../../core/constants/assets.dart';
import 'components/search_box_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _destinationController = TextEditingController();
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _rooms = 1;
  List<City> _cities = [];
  List<Country> _countries = [];
  List<Hotel> _allHotels = [];
  bool _isSearching = false;
  bool _isLoadingLocations = true;
  bool _isLoadingHotels = true;
  String? _selectedDestination;
  int _selectedServiceType = 0;

  final List<String> _serviceTypes = ['stays', 'services'];

  @override
  void initState() {
    super.initState();
    _loadLocationData();
    _loadAllHotels();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _loadLocationData() async {
    try {
      setState(() {
        _isLoadingLocations = true;
      });

      final locationResponse = await ref.read(locationProvider.future);
      setState(() {
        _cities = locationResponse.cities ?? [];
        _countries = locationResponse.countries ?? [];
        _isLoadingLocations = false;
      });

      print(
          'Locations loaded: ${_cities.length} cities, ${_countries.length} countries');
    } catch (e) {
      print('Error loading locations: $e');
      setState(() {
        _isLoadingLocations = false;
        // Load fallback data
        _cities = [
          City(id: 1, name: 'Cairo', countryId: 1),
          City(id: 2, name: 'Alexandria', countryId: 1),
          City(id: 3, name: 'Giza', countryId: 1),
        ];
        _countries = [
          Country(id: 1, name: 'Egypt'),
          Country(id: 2, name: 'Saudi Arabia'),
          Country(id: 3, name: 'UAE'),
        ];
      });
    }
  }

  Future<void> _loadAllHotels() async {
    try {
      setState(() {
        _isLoadingHotels = true;
      });

      final hotels = await ref.read(hotelProvider.future);
      setState(() {
        _allHotels = hotels;
        _isLoadingHotels = false;
      });

      print('Hotels loaded: ${_allHotels.length}');
    } catch (e) {
      print('Error loading hotels: $e');
      setState(() {
        _isLoadingHotels = false;
        _allHotels = [
          Hotel(
            id: '1',
            name: 'Cairo Marriott Hotel',
            cityId: 1,
            city: 'Cairo',
            country: 'Egypt',
            description: 'Luxury hotel in Cairo',
            rate: 4.5,
            priceRange: '150.0',
            imageUrl: 'https://example.com/cairo.jpg',
          ),
          Hotel(
            id: '2',
            name: 'Alexandria Beach Resort',
            cityId: 2,
            city: 'Alexandria',
            country: 'Egypt',
            description: 'Beach resort in Alexandria',
            rate: 4.3,
            priceRange: '120.0',
            imageUrl: 'https://example.com/alexandria.jpg',
          ),
        ];
      });
    }
  }

  Future<void> _performSearch() async {
    if (_selectedDestination == null || _selectedDestination!.isEmpty) {
      // If no destination selected, show all hotels page
      if (mounted) {
        Navigator.pushNamed(context, '/all-hotels', arguments: {
          'hotels': _allHotels,
        });
      }
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      print('Searching for destination: $_selectedDestination');
      print(
          'Available countries: ${_countries.map((c) => '${c.id}:${c.name}').join(', ')}');
      print(
          'Available cities: ${_cities.map((c) => '${c.id}:${c.name}').join(', ')}');
      print('Total hotels available: ${_allHotels.length}');
      print(
          'Sample hotel IDs: ${_allHotels.take(3).map((h) => '${h.name} (Country ID: ${h.countryId}, City ID: ${h.cityId})').join(', ')}');

      // First, try to find the destination in countries and cities
      Country? selectedCountry;
      City? selectedCity;

      // Check if it's a country
      selectedCountry = _countries.firstWhere(
        (country) =>
            country.name?.toLowerCase() == _selectedDestination!.toLowerCase(),
        orElse: () => Country(id: 0, name: ''),
      );

      // Check if it's a city
      if (selectedCountry.id == 0) {
        selectedCity = _cities.firstWhere(
          (city) =>
              city.name?.toLowerCase() == _selectedDestination!.toLowerCase(),
          orElse: () => City(id: 0, name: '', countryId: 0),
        );
      }

      List<Hotel> filteredHotels = [];

      if (selectedCountry.id != 0) {
        // Filter by country ID
        filteredHotels = _allHotels
            .where((hotel) => hotel.countryId == selectedCountry?.id)
            .toList();
        print(
            'Found ${filteredHotels.length} hotels in country: ${selectedCountry.name ?? 'Unknown'}');
        print(
            'Hotels found: ${filteredHotels.map((h) => '${h.name} (Country ID: ${h.countryId})').join(', ')}');
      } else if (selectedCity?.id != 0) {
        // Filter by city ID
        filteredHotels = _allHotels
            .where((hotel) => hotel.cityId == selectedCity?.id)
            .toList();
        print(
            'Found ${filteredHotels.length} hotels in city: ${selectedCity?.name ?? 'Unknown'}');
        print(
            'Hotels found: ${filteredHotels.map((h) => '${h.name} (City ID: ${h.cityId})').join(', ')}');
      } else {
        // Fallback: try to match by name (for backward compatibility)
        filteredHotels = _allHotels.where((hotel) {
          final matchesDestination = hotel.city
                      ?.toLowerCase()
                      .contains(_selectedDestination!.toLowerCase()) ==
                  true ||
              hotel.country
                      ?.toLowerCase()
                      .contains(_selectedDestination!.toLowerCase()) ==
                  true;
          return matchesDestination;
        }).toList();
        print('Fallback search found ${filteredHotels.length} hotels');
      }

      // Navigate to search results
      if (mounted) {
        print(
            'Navigating to search results with ${filteredHotels.length} hotels');
        print('Search query: $_selectedDestination');
        Navigator.pushNamed(context, '/search-results', arguments: {
          'hotels': filteredHotels,
          'searchQuery': _selectedDestination,
          'checkInDate': _checkInDate,
          'checkOutDate': _checkOutDate,
          'rooms': _rooms,
        });
      }
    } catch (e) {
      print('Search error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('search_failed'.tr(args: [e.toString()]))),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _navigateToCountryHotels(String countryName) {
    print('Navigating to country hotels: $countryName');
    Navigator.pushNamed(context, '/country-hotels', arguments: countryName);
  }

  void _handleSearchBoxSearch(String destination, DateTime? checkIn,
      DateTime? checkOut, int rooms, int adults, int children) {
    setState(() {
      _selectedDestination = destination;
      _checkInDate = checkIn;
      _checkOutDate = checkOut;
      _rooms = rooms;
    });

    // Perform the search using the existing search logic
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(dynamicConfigProvider);
    final primaryColor = WPConfig.navbarColor;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 768;
    final isLandscape = screenSize.width > screenSize.height;

    // Adjust app bar height based on orientation
    final appBarHeight = isLandscape ? (isTablet ? 100.h : 80.h) : 120.h;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: _buildCustomAppBar(context, primaryColor, isTablet, isLandscape),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_selectedServiceType == 0) ...[
              SearchBoxWidget(
                onSearch: _handleSearchBoxSearch,
                isLoading: _isSearching,
              ),
              SizedBox(height: 16),
            ],

            // Add space when Services is selected
            if (_selectedServiceType == 1) ...[
              SizedBox(height: 40),
            ],

            _buildMainContent(isTablet, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context, Color primaryColor,
      bool isTablet, bool isLandscape) {
    return Container(
      color: primaryColor,
      child: SafeArea(
        child: Column(
          children: [
            // Main App Bar with Icons, Logo, and Service Buttons
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 16.w, vertical: isLandscape ? 6.h : 10.h),
              child: Column(
                children: [
                  // Top Row - Icons and Logo
                  Row(
                    children: [
                      // Left side - Notification and Chat
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.notifications_outlined,
                                color: Colors.white,
                                size: isLandscape
                                    ? (isTablet ? 20.sp : 18.sp)
                                    : (isTablet ? 24.sp : 20.sp)),
                            onPressed: () {
                              Navigator.pushNamed(context, '/notifications');
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.chat,
                                color: Colors.white,
                                size: isLandscape
                                    ? (isTablet ? 20.sp : 18.sp)
                                    : (isTablet ? 24.sp : 20.sp)),
                            onPressed: () {
                              Navigator.pushNamed(context, '/customer-service');
                            },
                          ),
                        ],
                      ),

                      // Center - Logo
                      Expanded(
                        child: Center(
                            child: Image.asset(
                          AssetsManager.appbar,
                          height: isLandscape
                              ? (isTablet ? 30.h : 24.h)
                              : (isTablet ? 40.h : 32.h),
                          fit: BoxFit.contain,
                        )),
                      ),

                      // Right side - Language and Profile
                      Row(
                        children: [
                          // Language Toggle
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16.r),
                                onTap: () => _toggleLanguage(context),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: isLandscape ? 8.w : 12.w,
                                      vertical: isLandscape ? 4.h : 6.h),
                                  child: Text(
                                    Localizations.localeOf(context)
                                        .languageCode
                                        .toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isLandscape
                                          ? (isTablet ? 12.sp : 10.sp)
                                          : (isTablet ? 14.sp : 12.sp),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.person,
                                color: Colors.white,
                                size: isLandscape
                                    ? (isTablet ? 20.sp : 18.sp)
                                    : (isTablet ? 24.sp : 20.sp)),
                            onPressed: () {
                              Navigator.pushNamed(context, '/profile');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Service Type Selector - Centered below icons
                  SizedBox(height: isLandscape ? 6.h : 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _serviceTypes.asMap().entries.map((entry) {
                      final index = entry.key;
                      final serviceType = entry.value;
                      final isSelected = _selectedServiceType == index;

                      return Container(
                        width: isLandscape
                            ? (isTablet ? 100.w : 80.w)
                            : (isTablet ? 120.w : 100.w),
                        margin: EdgeInsets.symmetric(horizontal: 6.w),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedServiceType = index;
                            });
                          },
                          child: Container(
                            height: isLandscape ? 20.h : 25.h,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(25.r),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getServiceIcon(serviceType),
                                  color: Colors.white,
                                  size: isLandscape
                                      ? (isTablet ? 14.sp : 12.sp)
                                      : (isTablet ? 18.sp : 16.sp),
                                ),
                                SizedBox(width: isLandscape ? 4.w : 6.w),
                                Flexible(
                                  child: Text(
                                    serviceType.tr(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isLandscape
                                          ? (isTablet ? 12.sp : 10.sp)
                                          : (isTablet ? 14.sp : 12.sp),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType) {
      case 'stays':
        return Icons.bed;
      case 'services':
        return Icons.restaurant;
      default:
        return Icons.bed;
    }
  }

  void _toggleLanguage(BuildContext context) async {
    final currentLocale = Localizations.localeOf(context);
    final newLocale = currentLocale.languageCode == 'ar'
        ? Locale('en', 'US')
        : Locale('ar', 'SA');

    final newLanguageName =
        newLocale.languageCode == 'ar' ? 'العربية' : 'English';

    print('Home Page - Current locale: ${currentLocale.languageCode}');
    print('Home Page - New locale: ${newLocale.languageCode}');

    // Show confirmation dialog
    final shouldChange = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'change_language'.tr(),
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'change_language_confirm'.tr(args: [newLanguageName]),
          style: TextStyle(fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'cancel'.tr(),
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'confirm'.tr(),
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );

    if (shouldChange != true) return;

    try {
      // Set the new locale
      await EasyLocalization.of(context)!.setLocale(newLocale);
      print(
          'Home Page - Locale set successfully to: ${newLocale.languageCode}');

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('language_changed_success'.tr()),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Force a rebuild by calling setState
      setState(() {});

      // Also force a rebuild of the entire app to ensure RTL is applied
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      print('Home Page - Error setting locale: $e');
      // Show error dialog
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'error'.tr(),
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            content: Text(
              'failed_change_language'.tr(args: [e.toString()]),
              style: TextStyle(fontSize: 16.sp),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'ok'.tr(),
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget _buildMainContent(bool isTablet, Color primaryColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side ad (only on tablet)
        if (isTablet) ...[
          Container(
            width: 120.w,
            margin: EdgeInsets.only(left: 16.w, top: 8.h),
            child: _buildSideAd(isTablet, primaryColor),
          ),
          SizedBox(width: 16.w),
        ],

        // Main content
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Travel more, spend less section
                _buildTravelMoreSection(isTablet, primaryColor),

                SizedBox(height: isTablet ? 16.h : 12.h),

                // Offers section
                _buildOffersSection(isTablet, primaryColor),

                SizedBox(height: isTablet ? 16.h : 12.h),

                // Explore locations section (from API)
                _buildExploreLocationsSection(isTablet, primaryColor),

                SizedBox(height: isTablet ? 16.h : 12.h),

                // Why RealInn section
                _buildWhyRealInnSection(isTablet, primaryColor),

                SizedBox(height: isTablet ? 16.h : 12.h),
              ],
            ),
          ),
        ),

        // Right side ad (only on tablet)
        if (isTablet) ...[
          SizedBox(width: 16.w),
          Container(
            width: 120.w,
            margin: EdgeInsets.only(right: 16.w, top: 20.h),
            child: _buildSideAd(isTablet, primaryColor),
          ),
        ],
      ],
    );
  }

  Widget _buildSideAd(bool isTablet, Color primaryColor) {
    return Container(
      height: 300.h,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        children: [
          Container(
            height: 200.h,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.campaign,
                color: primaryColor,
                size: 40.sp,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ad_space'.tr(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'non_intrusive'.tr(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey[500],
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

  Widget _buildTravelMoreSection(bool isTablet, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'travel_more_spend_less'.tr(),
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: isTablet ? 8.h : 6.h),
        Row(
          children: [
            Expanded(
              child: Container(
                height: isTablet ? 140.h : 120.h, // Fixed height
                padding: EdgeInsets.all(isTablet ? 20.w : 16.w),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'genius'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'genius_level_message'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Container(
                height: isTablet ? 140.h : 120.h, // Fixed height
                padding: EdgeInsets.all(isTablet ? 20.w : 16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: primaryColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'discounts_10'.tr(),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'discounts_description'.tr(),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOffersSection(bool isTablet, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'offers'.tr(),
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'offers_description'.tr(),
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isTablet ? 20.h : 16.h),
        Container(
          height: isTablet ? 120.h : 105.h, // Fixed height
          padding: EdgeInsets.all(isTablet ? 20.w : 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: primaryColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'quick_escape_quality_time'.tr(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'save_up_to_20_percent'.tr(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: isTablet ? 80.w : 60.w,
                height: isTablet ? 80.h : 60.h,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.people,
                  color: Colors.blue[600],
                  size: isTablet ? 32.sp : 24.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExploreLocationsSection(bool isTablet, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'explore_destinations'.tr(),
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        if (_isLoadingLocations || _isLoadingHotels)
          Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  SizedBox(height: 16.h),
                  Text(
                    'loading_destinations'.tr(),
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (_countries.isEmpty && _cities.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                children: [
                  Icon(
                    Icons.location_off,
                    size: isTablet ? 64.sp : 48.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'no_destinations_available'.tr(),
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'check_network_connection'.tr(),
                    style: TextStyle(
                      fontSize: isTablet ? 14.sp : 12.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      _loadLocationData();
                      _loadAllHotels();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            ),
          )
        else ...[
          // Countries section with cities inside
          if (_countries.isNotEmpty) ...[
            SizedBox(height: 12.h),
            // Show other countries
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _countries
                    .skip(1)
                    .take(3)
                    .map((country) => _buildDestinationCard(
                          country.name ?? 'unknown_country'.tr(),
                          '',
                          isTablet,
                          () => _navigateToCountryHotels(country.name ?? ''),
                          isCountry: true,
                        ))
                    .toList(),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ],
      ],
    );
  }

  Widget _buildDestinationCard(
      String city, String properties, bool isTablet, VoidCallback onTap,
      {bool isCountry = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isTablet ? 200.w : 150.w,
        height: isTablet ? 120.h : 100.h,
        margin: EdgeInsets.only(right: isTablet ? 16.w : 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: isCountry
              ? Colors.green[100]
              : Colors.blue[100], // Fallback color
          image: DecorationImage(
            image: NetworkImage(
              isCountry ? _getCountryImage(city) : _getCityImage(city),
            ),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {
              print('Image loading error: $exception');
            },
            colorFilter: ColorFilter.mode(
              isCountry
                  ? Colors.green.withOpacity(0.3)
                  : Colors.blue.withOpacity(0.3),
              BlendMode.overlay,
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(
                      isCountry ? Icons.public : Icons.location_city,
                      color: Colors.white,
                      size: isTablet ? 16.sp : 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        city,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 18.sp : 16.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (properties.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    properties,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 12.sp : 10.sp,
                      fontWeight: FontWeight.bold,
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

  String _getCountryImage(String countryName) {
    final name = countryName.toLowerCase();

    // Egypt
    if (name.contains('egypt') || name.contains('cairo')) {
      return 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop';
    }

    // United States
    if (name.contains('united states') ||
        name.contains('usa') ||
        name.contains('america')) {
      return 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=400&h=300&fit=crop';
    }

    // India
    if (name.contains('india')) {
      return 'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=400&h=300&fit=crop';
    }

    // Australia
    if (name.contains('australia')) {
      return 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop';
    }

    // Bangladesh
    if (name.contains('bangladesh')) {
      return 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop';
    }

    // Default beautiful landscape
    return 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop';
  }

  String _getCityImage(String cityName) {
    final name = cityName.toLowerCase();

    // Seas and beaches
    if (name.contains('sea') ||
        name.contains('beach') ||
        name.contains('coast') ||
        name.contains('ocean') ||
        name.contains('marina') ||
        name.contains('port')) {
      return 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&h=300&fit=crop';
    }

    // Deserts
    if (name.contains('desert') ||
        name.contains('sahara') ||
        name.contains('oasis')) {
      return 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop';
    }

    // Nature and mountains
    if (name.contains('mountain') ||
        name.contains('valley') ||
        name.contains('forest') ||
        name.contains('park') ||
        name.contains('garden') ||
        name.contains('nature')) {
      return 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop';
    }

    // Cities and urban
    if (name.contains('city') ||
        name.contains('town') ||
        name.contains('district') ||
        name.contains('street') ||
        name.contains('avenue')) {
      return 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=400&h=300&fit=crop';
    }

    // Historical and cultural
    if (name.contains('temple') ||
        name.contains('mosque') ||
        name.contains('church') ||
        name.contains('museum') ||
        name.contains('palace') ||
        name.contains('castle')) {
      return 'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=400&h=300&fit=crop';
    }

    // Rivers and lakes
    if (name.contains('river') ||
        name.contains('lake') ||
        name.contains('waterfall') ||
        name.contains('stream') ||
        name.contains('pond')) {
      return 'https://images.unsplash.com/photo-1439066615861-d1af74d74000?w=400&h=300&fit=crop';
    }

    // Default beautiful landscape
    return 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop';
  }

  Widget _buildWhyRealInnSection(bool isTablet, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'why_realinn'.tr(),
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: isTablet ? 15.h : 12.h),
        // Horizontal scrollable feature cards with same size
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFeatureCard(
                icon: Icons.percent,
                title: 'mobile_only_pricing'.tr(),
                description: 'mobile_pricing_description'.tr(),
                isTablet: isTablet,
                primaryColor: primaryColor,
                backgroundColor: Colors.yellow[100]!,
                iconColor: Colors.yellow[800]!,
              ),
              SizedBox(width: 16.w),
              _buildFeatureCard(
                icon: Icons.calendar_today,
                title: 'free_cancellation'.tr(),
                description: 'free_cancellation_description'.tr(),
                isTablet: isTablet,
                primaryColor: primaryColor,
                backgroundColor: Colors.blue[100]!,
                iconColor: Colors.blue[600]!,
              ),
              SizedBox(width: 16.w),
              _buildFeatureCard(
                icon: Icons.security,
                title: 'secure_booking'.tr(),
                description: 'secure_booking_description'.tr(),
                isTablet: isTablet,
                primaryColor: primaryColor,
                backgroundColor: Colors.green[100]!,
                iconColor: Colors.green[600]!,
              ),
              SizedBox(width: 16.w),
              _buildFeatureCard(
                icon: Icons.support_agent,
                title: 'support_24_7'.tr(),
                description: 'support_24_7_description'.tr(),
                isTablet: isTablet,
                primaryColor: primaryColor,
                backgroundColor: Colors.purple[100]!,
                iconColor: Colors.purple[600]!,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isTablet,
    required Color primaryColor,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      width: isTablet ? 250.w : 200.w,
      height: isTablet ? 160.h : 160.h,
      padding: EdgeInsets.all(isTablet ? 20.w : 16.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: isTablet ? 32.sp : 28.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 12.sp : 10.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          Text(
            description,
            style: TextStyle(
              fontSize: isTablet ? 14.sp : 11.sp,
              color: Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class DestinationPickerDialog extends StatelessWidget {
  final List<Country> countries;
  final List<City> cities;
  final Function(String) onDestinationSelected;

  const DestinationPickerDialog({
    Key? key,
    required this.countries,
    required this.cities,
    required this.onDestinationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400.w,
        height: 600.h,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'select_destination'.tr(),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        Tab(text: 'countries'.tr() + ' (${countries.length})'),
                        Tab(text: 'cities'.tr() + ' (${cities.length})'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Countries tab
                          ListView.builder(
                            itemCount: countries.length,
                            itemBuilder: (context, index) {
                              final country = countries[index];
                              return ListTile(
                                leading: Icon(Icons.public),
                                title: Text(
                                    country.name ?? 'unknown_country'.tr()),
                                subtitle: Text('click_to_select'.tr()),
                                onTap: () {
                                  onDestinationSelected(country.name ?? '');
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                          // Cities tab
                          ListView.builder(
                            itemCount: cities.length,
                            itemBuilder: (context, index) {
                              final city = cities[index];
                              return ListTile(
                                leading: Icon(Icons.location_city),
                                title: Text(city.name ?? 'unknown_city'.tr()),
                                subtitle: Text('click_to_select'.tr()),
                                onTap: () {
                                  onDestinationSelected(city.name ?? '');
                                  Navigator.pop(context);
                                },
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
          ],
        ),
      ),
    );
  }
}
