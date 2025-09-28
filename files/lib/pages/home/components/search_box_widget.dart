import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../controllers/location_controller.dart';
import '../../../models/location.dart';

class SearchBoxWidget extends ConsumerStatefulWidget {
  final Function(String destination, DateTime? checkIn, DateTime? checkOut, int rooms, int adults, int children) onSearch;
  final bool isLoading;

  const SearchBoxWidget({
    Key? key,
    required this.onSearch,
    this.isLoading = false,
  }) : super(key: key);

  @override
  ConsumerState<SearchBoxWidget> createState() => _SearchBoxWidgetState();
}

class _SearchBoxWidgetState extends ConsumerState<SearchBoxWidget> {
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
    final primaryColor = const Color(0xFFa93ae1); // Purple color from theme
    final isTablet = MediaQuery.of(context).size.width >= 768;
    
    // Adjustable background height (you can change this value)
    final backgroundHeight = 60.0; // Purple background behind table, connects to app bar

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
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

          // Search table with proper margins and borders
          Container(
              margin: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor, width: 3),
              ),
            child: Column(
              children: [
                // Daily/Monthly Tabs
                _buildTabSelector(primaryColor, isTablet),
                
                // Destination Field
                _buildSearchField(
                  icon: Icons.search,
                  text: _destination.isEmpty ? 'destination'.tr() : _destination,
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



  Widget _buildTabSelector(Color primaryColor, bool isTablet) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: primaryColor, width: 2),
        ),
      ),
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
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? primaryColor.withOpacity(0.3) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _selectedTab == 0 ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Center(
                  child: Text(
                    _tabs[0].tr(),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Divider between buttons
          Container(
            height: 40,
            width: 2,
            color: primaryColor,
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
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? primaryColor.withOpacity(0.3) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _selectedTab == 1 ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Center(
                  child: Text(
                    _tabs[1].tr(),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isTablet ? 14 : 12,
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
        height: 45,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: primaryColor, width: 2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.black,
              size: isTablet ? 18 : 16,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: isTablet ? 14 : 13,
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
      height: 45,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(9),
          bottomRight: Radius.circular(9),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : _performSearch,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(9),
            bottomRight: Radius.circular(9),
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            child: widget.isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'search'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 16 : 14,
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
            title: Text('select_rooms_guests'.tr()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('rooms'.tr()),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (tempRooms > 1) {
                              setState(() => tempRooms--);
                            }
                          },
                          icon: Icon(Icons.remove),
                        ),
                        Text('$tempRooms'),
                        IconButton(
                          onPressed: () {
                            setState(() => tempRooms++);
                          },
                          icon: Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('adults'.tr()),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (tempAdults > 1) {
                              setState(() => tempAdults--);
                            }
                          },
                          icon: Icon(Icons.remove),
                        ),
                        Text('$tempAdults'),
                        IconButton(
                          onPressed: () {
                            setState(() => tempAdults++);
                          },
                          icon: Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('children'.tr()),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (tempChildren > 0) {
                              setState(() => tempChildren--);
                            }
                          },
                          icon: Icon(Icons.remove),
                        ),
                        Text('$tempChildren'),
                        IconButton(
                          onPressed: () {
                            setState(() => tempChildren++);
                          },
                          icon: Icon(Icons.add),
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
                child: Text('cancel'.tr()),
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
                child: Text('apply'.tr()),
              ),
            ],
          );
        },
      ),
    );
  }

  void _performSearch() {
    widget.onSearch(_destination, _checkInDate, _checkOutDate, _rooms, _adults, _children);
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    return '$day $month';
  }
}

class DestinationSelectionModal extends ConsumerStatefulWidget {
  final String selectedDestination;
  final Function(String) onDestinationSelected;

  const DestinationSelectionModal({
    Key? key,
    required this.selectedDestination,
    required this.onDestinationSelected,
  }) : super(key: key);

  @override
  ConsumerState<DestinationSelectionModal> createState() => _DestinationSelectionModalState();
}

class _DestinationSelectionModalState extends ConsumerState<DestinationSelectionModal> {
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

  List<String> _extractDestinations(LocationResponse locationResponse) {
    List<String> destinations = [];
    
    // Add cities
    if (locationResponse.cities != null) {
      for (var city in locationResponse.cities!) {
        if (city.name != null) {
          // Find the country name for this city
          String countryName = '';
          if (city.countryId != null && locationResponse.countries != null) {
            var country = locationResponse.countries!.firstWhere(
              (c) => c.id == city.countryId,
              orElse: () => Country(),
            );
            countryName = country.name ?? '';
          }
          
          if (countryName.isNotEmpty) {
            destinations.add('${city.name}, $countryName');
          } else {
            destinations.add(city.name!);
          }
        }
      }
    }
    
    // Add countries
    if (locationResponse.countries != null) {
      for (var country in locationResponse.countries!) {
        if (country.name != null) {
          destinations.add(country.name!);
        }
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
          .where((destination) =>
              destination.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFa93ae1);
    final isTablet = MediaQuery.of(context).size.width >= 768;
    
    // Watch location data
    final locationResponse = ref.watch(locationProvider);
    
    // Update destinations when data is available
    locationResponse.when(
      data: (data) {
        if (_destinations.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _destinations = _extractDestinations(data);
              _filteredDestinations = List.from(_destinations);
            });
          });
        }
      },
      loading: () {
        // Keep current destinations while loading
      },
      error: (error, stackTrace) {
        // Fallback to default destinations if API fails
        if (_destinations.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _destinations = [
                'Cairo, Egypt',
                'Dubai, UAE',
                'London, UK',
                'Paris, France',
                'New York, USA',
              ];
              _filteredDestinations = List.from(_destinations);
            });
          });
        }
      },
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'select_destination'.tr(),
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
          
          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor, width: 2),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'search_destinations'.tr(),
                  prefixIcon: Icon(Icons.search, color: primaryColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          
          SizedBox(height: 20.h),
          
          // Destinations list
          Expanded(
            child: locationResponse.when(
              data: (data) => ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: _filteredDestinations.length,
                itemBuilder: (context, index) {
                  final destination = _filteredDestinations[index];
                  final isSelected = _selectedDestination == destination;

                  return Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        destination,
                        style: TextStyle(
                          color: isSelected ? primaryColor : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: primaryColor)
                          : Icon(Icons.radio_button_unchecked, color: Colors.grey[400]),
                      onTap: () {
                        setState(() {
                          _selectedDestination = destination;
                        });
                      },
                    ),
                  );
                },
              ),
              loading: () => Center(
                child: CircularProgressIndicator(color: primaryColor),
              ),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 48.sp),
                    SizedBox(height: 16.h),
                    Text(
                      'failed_to_load_destinations'.tr(),
                      style: TextStyle(fontSize: 16.sp, color: Colors.red),
                    ),
                  ],
                ),
              ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'apply_selection'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 16 : 14,
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
