import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../config/dynamic_config.dart';
import '../../../../config/wp_config.dart';
import '../providers/home_providers.dart';
import '../../../controllers/location_controller.dart';
import '../../../controllers/hotel_controller.dart';
import '../../../models/location.dart' as location_model;
import '../../hotels/hotels_search_page.dart';

class TableSearchInterface extends ConsumerStatefulWidget {
  const TableSearchInterface({Key? key}) : super(key: key);

  @override
  ConsumerState<TableSearchInterface> createState() =>
      _TableSearchInterfaceState();
}

class _TableSearchInterfaceState extends ConsumerState<TableSearchInterface> {
  int _adults = 2;
  int _children = 0;
  int _rooms = 1;
  DateTimeRange? _dateRange;
  String? _selectedCountry;
  String? _selectedCity;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Set default date range to next weekend
    final now = DateTime.now();
    final nextSaturday = now.add(Duration(days: (6 - now.weekday) % 7));
    final nextSunday = nextSaturday.add(Duration(days: 1));
    _dateRange = DateTimeRange(start: nextSaturday, end: nextSunday);
  }

  @override
  Widget build(BuildContext context) {
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final Color primaryColor =
        dynamicConfig.primaryColor ?? const Color(0xFF895ffc);
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.yellow, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 20),
        child: Column(
          children: [
            // Daily/Monthly Selector
            _buildDailyMonthlySelector(isTablet),

            SizedBox(height: 20),

            // Destination Field - Fully bordered, clickable
            _buildClickableField(
              icon: Icons.search,
              label: 'Click to select destination',
              value: _selectedCountry != null && _selectedCity != null
                  ? '$_selectedCity, $_selectedCountry'
                  : null,
              onTap: () => _selectDestination(),
              isTablet: isTablet,
              primaryColor: primaryColor,
            ),

            SizedBox(height: 16),

            // Date Selection Field - Fully bordered, clickable
            _buildClickableField(
              icon: Icons.calendar_today,
              label: 'Select dates',
              value: _dateRange != null
                  ? '${_getDayName(_dateRange!.start.weekday)}, ${_dateRange!.start.day} ${_getMonthName(_dateRange!.start.month)} - ${_getDayName(_dateRange!.end.weekday)}, ${_dateRange!.end.day} ${_getMonthName(_dateRange!.end.month)}'
                  : null,
              onTap: () => _selectDates(),
              isTablet: isTablet,
              primaryColor: primaryColor,
            ),

            SizedBox(height: 16),

            // Guests and Rooms Field - Fully bordered, clickable
            _buildClickableField(
              icon: Icons.person,
              label: 'Select guests and rooms',
              value: '$_rooms room · $_adults adults · $_children children',
              onTap: () => _selectGuestsAndRooms(),
              isTablet: isTablet,
              primaryColor: primaryColor,
            ),

            SizedBox(height: 24),

            // Search Button
            _buildSearchButton(primaryColor, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyMonthlySelector(bool isTablet) {
    return Consumer(
      builder: (context, ref, child) {
        final selectedBookingType = ref.watch(selectedBookingTypeProvider);
        final primaryColor = WPConfig.navbarColor;

        return Row(
          children: [
            Expanded(
              child: _buildBookingTypeButton(
                isSelected: selectedBookingType == 0,
                text: 'Daily',
                icon: Icons.bed,
                onTap: () {
                  ref.read(selectedBookingTypeProvider.notifier).state = 0;
                },
                isTablet: isTablet,
                primaryColor: primaryColor,
              ),
            ),
            SizedBox(width: isTablet ? 16 : 8),
            Expanded(
              child: _buildBookingTypeButton(
                isSelected: selectedBookingType == 1,
                text: 'Monthly',
                icon: Icons.calendar_month,
                onTap: () {
                  ref.read(selectedBookingTypeProvider.notifier).state = 1;
                },
                isTablet: isTablet,
                primaryColor: primaryColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBookingTypeButton({
    required bool isSelected,
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    required bool isTablet,
    required Color primaryColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isTablet ? 56 : 48,
        padding:
            EdgeInsets.symmetric(horizontal: isTablet ? 16 : 8, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: primaryColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : primaryColor,
              size: isTablet ? 24 : 18,
            ),
            SizedBox(width: isTablet ? 8 : 4),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 16 : 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClickableField({
    required IconData icon,
    required String label,
    String? value,
    required VoidCallback onTap,
    required bool isTablet,
    required Color primaryColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: primaryColor, width: 2),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: primaryColor,
              size: isTablet ? 24 : 20,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                value ?? label,
                style: TextStyle(
                  color: value != null ? Colors.black : Colors.grey[600],
                  fontWeight:
                      value != null ? FontWeight.bold : FontWeight.normal,
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: primaryColor,
              size: isTablet ? 24 : 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchButton(Color primaryColor, bool isTablet) {
    return SizedBox(
      width: double.infinity,
      height: isTablet ? 56 : 48,
      child: ElevatedButton(
        onPressed: _performSearch,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: Text(
          'Search',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 18 : 16,
          ),
        ),
      ),
    );
  }

  void _selectDestination() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildHotelSelector(),
    );
  }

  Widget _buildHotelSelector() {
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Consumer(
      builder: (context, ref, child) {
        final hotelsAsync = ref.watch(hotelProvider);

        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Select Hotel',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: hotelsAsync.when(
                  data: (hotels) {
                    if (hotels.isEmpty) {
                      return Center(
                        child: Text(
                          'No hotels available',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: hotels.length,
                      itemBuilder: (context, index) {
                        final hotel = hotels[index];
                        return ListTile(
                          leading: Container(
                            width: isTablet ? 60 : 50,
                            height: isTablet ? 60 : 50,
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.hotel,
                              color: Colors.blue[600],
                              size: isTablet ? 28 : 24,
                            ),
                          ),
                          title: Text(
                            hotel.name ?? 'Hotel Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            '${hotel.city ?? 'City'}, ${hotel.country ?? 'Country'}',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedCountry = hotel.country ?? 'Country';
                              _selectedCity = hotel.city ?? 'City';
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                  loading: () => Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      'Error loading hotels: $e',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectDates() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _selectGuestsAndRooms() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildGuestsAndRoomsSelector(),
    );
  }

  Widget _buildGuestsAndRoomsSelector() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select guests and rooms',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20),

          // Adults
          _buildCounterRow('Adults', _adults, (value) {
            setState(() => _adults = value);
          }, 1, 10),

          SizedBox(height: 16),

          // Children
          _buildCounterRow('Children', _children, (value) {
            setState(() => _children = value);
          }, 0, 8),

          SizedBox(height: 16),

          // Rooms
          _buildCounterRow('Rooms', _rooms, (value) {
            setState(() => _rooms = value);
          }, 1, 5),

          SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterRow(
      String label, int value, Function(int) onChanged, int min, int max) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: value > min ? () => onChanged(value - 1) : null,
              icon: Icon(Icons.remove_circle_outline),
            ),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            IconButton(
              onPressed: value < max ? () => onChanged(value + 1) : null,
              icon: Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  void _performSearch() {
    if (_selectedCountry == null || _selectedCity == null) {
      // Show all hotels if no destination selected
      Navigator.pushNamed(context, '/all-hotels');
      return;
    }

    // Navigate to search results with the selected destination
    Navigator.pushNamed(context, '/search-results', arguments: {
      'searchQuery': '$_selectedCity, $_selectedCountry',
      'hotels': [], // Will be loaded by HotelsSearchPage
    });
  }
}
