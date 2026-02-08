import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../services/hotel_service.dart';
import '../../../models/hotel.dart';
import '../../../config/constants/app_colors.dart';

class SearchBoxWidget extends StatefulWidget {
  final Function(String destination, DateTime? checkIn, DateTime? checkOut,
      int rooms, int adults, int children) onSearch;
  final bool isLoading;

  const SearchBoxWidget({
    Key? key,
    required this.onSearch,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<SearchBoxWidget> createState() => _SearchBoxWidgetState();
}

class _SearchBoxWidgetState extends State<SearchBoxWidget> {
  int _selectedTab = 0;
  String _destination = '';
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _rooms = 1;
  int _adults = 2;
  int _children = 0;

  final List<String> _tabs = ['daily', 'monthly'];

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primary(context); // Dynamic color from API
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 768;
    final isLandscape = screenSize.width > screenSize.height;

    // Adjustable background height using ScreenUtil - responsive to orientation
    final backgroundHeight = isLandscape ? 45.h : 55.h;

    return Container(
      margin: EdgeInsets.only(bottom: isLandscape ? 12.h : 20.h),
      child: Stack(
        children: [
          // Purple background - extends full width to stick to app bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: backgroundHeight,
            child: Container(
              color: primaryColor,
            ),
          ),

          // Search table with proper margins and borders - increased width
          Container(
            margin: EdgeInsets.only(
              top: isLandscape ? 10.h : 15.h, // Space down then show table
              left: isLandscape ? (isTablet ? 20.w : 10.w) : (isTablet ? 40.w : 20.w),
              right: isLandscape ? (isTablet ? 20.w : 10.w) : (isTablet ? 40.w : 20.w),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.amber, width: 3),
            ),
            child: Column(
              children: [
                // Daily/Monthly Tabs
                _buildTabSelector(primaryColor, isTablet, isLandscape),

                // Destination Field
                _buildSearchField(
                  icon: Icons.search,
                  text:
                      _destination.isEmpty ? 'destination'.tr() : _destination,
                  onTap: _selectDestination,
                  isTablet: isTablet,
                  primaryColor: primaryColor,
                ),

                // Date Field
                _buildSearchField(
                  icon: Icons.calendar_today,
                  text: _checkInDate != null && _checkOutDate != null
                      ? '${_formatDate(_checkInDate!)} - ${_formatDate(_checkOutDate!)}'
                      : 'select_date'.tr(),
                  onTap: _selectDates,
                  isTablet: isTablet,
                  primaryColor: primaryColor,
                ),

                // Occupancy Field
                _buildSearchField(
                  icon: Icons.people,
                  text: '$_rooms room, $_adults adults, $_children children',
                  onTap: _selectOccupancy,
                  isTablet: isTablet,
                  primaryColor: primaryColor,
                ),

                // Search Button
                _buildSearchButton(primaryColor, isTablet),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector(
      Color primaryColor, bool isTablet, bool isLandscape) {
    final tabHeight = isLandscape ? 30.h : 40.h;
    final textSize =
        isLandscape ? (isTablet ? 12.sp : 10.sp) : (isTablet ? 14.sp : 12.sp);

    return Container(
      height: tabHeight,
      child: Row(
        children: [
          // Daily button
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = 0;
                });
              },
              child: Container(
                height: tabHeight,
                decoration: BoxDecoration(
                  color: _selectedTab == 0
                      ? primaryColor.withOpacity(0.7)
                      : primaryColor,
                ),
                child: Center(
                  child: Text(
                    _tabs[0].tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: textSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Monthly button
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = 1;
                });
              },
              child: Container(
                height: tabHeight,
                decoration: BoxDecoration(
                  color: _selectedTab == 1
                      ? primaryColor.withOpacity(0.7)
                      : primaryColor,
                ),
                child: Center(
                  child: Text(
                    _tabs[1].tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: textSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required bool isTablet,
    required Color primaryColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.amber, width: 2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.black,
              size: isTablet ? 20.sp : 18.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: isTablet ? 16.sp : 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchButton(Color primaryColor, bool isTablet) {
    return Container(
      width: double.infinity,
      height: 50.h,
      decoration: BoxDecoration(
        color: primaryColor,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : _performSearch,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            child: widget.isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'search'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 18.sp : 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _selectDestination() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DestinationSelectionModal(
          selectedDestination: _destination,
          onDestinationSelected: (destination) {
            setState(() {
              _destination = destination;
            });
          },
        );
      },
    );
  }

  void _selectDates() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDateRange: _checkInDate != null && _checkOutDate != null
          ? DateTimeRange(start: _checkInDate!, end: _checkOutDate!)
          : DateTimeRange(
              start: DateTime.now().add(Duration(days: 1)),
              end: DateTime.now().add(Duration(days: 2)),
            ),
    );

    if (picked != null) {
      setState(() {
        _checkInDate = picked.start;
        _checkOutDate = picked.end;
      });
    }
  }

  void _selectOccupancy() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          int tempRooms = _rooms;
          int tempAdults = _adults;
          int tempChildren = _children;

          return AlertDialog(
            title: Text(
              'select_rooms_guests'.tr(),
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'rooms'.tr(),
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (tempRooms > 1) {
                              setState(() => tempRooms--);
                            }
                          },
                          icon: Icon(Icons.remove, size: 20.sp),
                        ),
                        Text(
                          '$tempRooms',
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() => tempRooms++);
                          },
                          icon: Icon(Icons.add, size: 20.sp),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'adults'.tr(),
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (tempAdults > 1) {
                              setState(() => tempAdults--);
                            }
                          },
                          icon: Icon(Icons.remove, size: 20.sp),
                        ),
                        Text(
                          '$tempAdults',
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() => tempAdults++);
                          },
                          icon: Icon(Icons.add, size: 20.sp),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'children'.tr(),
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (tempChildren > 0) {
                              setState(() => tempChildren--);
                            }
                          },
                          icon: Icon(Icons.remove, size: 20.sp),
                        ),
                        Text(
                          '$tempChildren',
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() => tempChildren++);
                          },
                          icon: Icon(Icons.add, size: 20.sp),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'cancel'.tr(),
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _rooms = tempRooms;
                    _adults = tempAdults;
                    _children = tempChildren;
                  });
                  Navigator.pop(context);
                },
                child: Text(
                  'apply'.tr(),
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _performSearch() {
    widget.onSearch(
        _destination, _checkInDate, _checkOutDate, _rooms, _adults, _children);
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
}

class DestinationSelectionModal extends StatefulWidget {
  final String selectedDestination;
  final Function(String) onDestinationSelected;

  const DestinationSelectionModal({
    Key? key,
    required this.selectedDestination,
    required this.onDestinationSelected,
  }) : super(key: key);

  @override
  State<DestinationSelectionModal> createState() =>
      _DestinationSelectionModalState();
}

class _DestinationSelectionModalState extends State<DestinationSelectionModal> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedDestination = '';
  List<String> _destinations = [];
  List<String> _filteredDestinations = [];

  @override
  void initState() {
    super.initState();
    _selectedDestination = widget.selectedDestination;
    _searchController.addListener(_filterDestinations);
    _loadDestinations();
  }

  void _loadDestinations() {
    // This will be called in the build method using ref.watch
  }

  List<String> _extractDestinations(LocationResponseModel locationResponse) {
    List<String> destinations = [];

    // Add cities
    final cities = locationResponse.cities ?? [];
    for (final city in cities) {
      if (city.name != null) {
        // Find the country name for this city
        String countryName = '';
        final countries = locationResponse.countries ?? [];
        if (city.countryId != null) {
          final match = countries.firstWhere((cc) => cc.id == city.countryId,
              orElse: () => CountryModel());
          countryName = match.name ?? '';
        }
        destinations.add(
            countryName.isNotEmpty ? '${city.name}, $countryName' : city.name!);
      }
    }

    // Add countries
    final countries = locationResponse.countries ?? [];
    for (final country in countries) {
      if (country.name != null) {
        destinations.add(country.name!);
      }
    }

    return destinations;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterDestinations() {
    setState(() {
      _filteredDestinations = _destinations
          .where((destination) => destination
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primary(context);
    final isTablet = MediaQuery.of(context).size.width >= 768;
    Future.microtask(() async {
      if (_destinations.isNotEmpty) return;
      try {
        final data = await HotelService.fetchMeta();
        if (!mounted) return;
        setState(() {
          _destinations = _extractDestinations(data);
          _filteredDestinations = List.from(_destinations);
        });
      } catch (e) {
        if (!mounted) return;
        // Don't set fallback static data - just show empty list
        setState(() {
          _destinations = [];
          _filteredDestinations = [];
        });
      }
    });

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Text(
                  'select_destination'.tr(),
                  style: TextStyle(
                    fontSize: isTablet ? 24.sp : 20.sp,
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

          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: primaryColor, width: 3),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'search_destinations'.tr(),
                  prefixIcon: Icon(Icons.search, color: primaryColor),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // Destinations list
          Expanded(
            child: _destinations.isEmpty
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: _filteredDestinations.length,
                    itemBuilder: (context, index) {
                      final destination = _filteredDestinations[index];
                      final isSelected = _selectedDestination == destination;

                      return Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor.withOpacity(0.1)
                              : Colors.transparent,
                          border: Border.all(
                            color:
                                isSelected ? primaryColor : Colors.grey[300]!,
                            width: isSelected ? 3 : 2,
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            destination,
                            style: TextStyle(
                              color: isSelected ? primaryColor : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: isTablet ? 16.sp : 14.sp,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle,
                                  color: primaryColor,
                                  size: isTablet ? 24.sp : 20.sp)
                              : Icon(Icons.radio_button_unchecked,
                                  color: Colors.grey[400],
                                  size: isTablet ? 24.sp : 20.sp),
                          onTap: () {
                            setState(() {
                              _selectedDestination = destination;
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),

          // Apply button
          Padding(
            padding: EdgeInsets.all(20.w),
            child: SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  widget.onDestinationSelected(_selectedDestination);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(),
                ),
                child: Text(
                  'apply_selection'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 16.sp : 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
