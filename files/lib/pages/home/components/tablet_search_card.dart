import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../config/dynamic_config.dart';
import '../providers/home_providers.dart';
import '../../../controllers/location_controller.dart';
import '../../../../core/constants/assets.dart';
import '../../../models/location.dart' as location_model;
import '../search_results_page.dart';

class TabletSearchCard extends ConsumerStatefulWidget {
  final VoidCallback onDailyBookingTap;
  final VoidCallback onMonthlyBookingTap;

  const TabletSearchCard({
    Key? key,
    required this.onDailyBookingTap,
    required this.onMonthlyBookingTap,
  }) : super(key: key);

  @override
  ConsumerState<TabletSearchCard> createState() => _TabletSearchCardState();
}

class _TabletSearchCardState extends ConsumerState<TabletSearchCard> {
  final TextEditingController _destinationController = TextEditingController();
  int _adults = 2;
  int _children = 0;
  int _rooms = 1;
  DateTimeRange? _dateRange;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _selectedCountry;
  String _countrySearchQuery = '';
  String? _selectedCity;
  String _citySearchQuery = '';
  int _selectedBookingType = 0; // 0: daily, 1: monthly

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
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final Color primaryColor =
        dynamicConfig.primaryColor ?? const Color(0xFF895ffc);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Booking type selector
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: Colors.grey.shade600, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedBookingType = 0;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: _selectedBookingType == 0
                                            ? primaryColor
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _selectedBookingType == 0
                                              ? primaryColor
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Daily',
                                          style: TextStyle(
                                            color: _selectedBookingType == 0
                                                ? Colors.white
                                                : Colors.grey.shade600,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedBookingType = 1;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: _selectedBookingType == 1
                                            ? primaryColor
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _selectedBookingType == 1
                                              ? primaryColor
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Monthly',
                                          style: TextStyle(
                                            color: _selectedBookingType == 1
                                                ? Colors.white
                                                : Colors.grey.shade600,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
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

                    // Enhanced Destination field
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on,
                              color: primaryColor, size: 24),
                          SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  _showDestinationModal(context, primaryColor),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _destinationController.text.isEmpty
                                            ? 'Choose destination'
                                            : _destinationController.text,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: _destinationController
                                                  .text.isEmpty
                                              ? Colors.grey[500]
                                              : Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: primaryColor,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Date/Time selector based on booking type
                    if (_selectedBookingType == 0)
                      // Daily: show time range selectors
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time,
                                color: Colors.grey.shade600, size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _pickStartTime,
                                      child: Text(
                                        _startTime == null
                                            ? 'Start time'
                                            : _formatTime(_startTime!),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('-',
                                      style: TextStyle(
                                          color: Colors.grey.shade600)),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _pickEndTime,
                                      child: Text(
                                        _endTime == null
                                            ? 'End time'
                                            : _formatTime(_endTime!),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      // Monthly: show date range selector
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: Colors.grey.shade600, size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: _pickDateRange,
                                child: Text(
                                  _dateRange != null
                                      ? '${DateFormat('EEE, d MMM').format(_dateRange!.start)} - ${DateFormat('EEE, d MMM').format(_dateRange!.end)}'
                                      : 'Select dates',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black87),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Guests/Rooms field
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      child: Row(
                        children: [
                          Icon(Icons.person,
                              color: Colors.grey.shade600, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickGuests,
                              child: Text(
                                '${_rooms} room · ${_adults} adults · ${_children} children',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black87),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Search button
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              primaryColor,
                              primaryColor.withOpacity(0.9)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.25),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _onSearchAndNavigate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            minimumSize: Size(double.infinity, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search, size: 20, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Search Hotels',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
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
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _dateRange,
    );
    if (picked != null) setState(() => _dateRange = picked);
  }

  Future<void> _pickStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => _startTime = time);
  }

  Future<void> _pickEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _endTime ?? (_startTime ?? TimeOfDay.now()),
    );
    if (time != null) setState(() => _endTime = time);
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _showDestinationModal(BuildContext context, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDestinationModal(context, primaryColor),
    );
  }

  Widget _buildDestinationModal(BuildContext context, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                    Icons.explore,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose Your Destination',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Discover amazing places to stay',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
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

          // Enhanced Content
          Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7),
            child: Column(
              children: [
                // Enhanced Search Bar
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _destinationController,
                      decoration: InputDecoration(
                        hintText: 'Search destinations, cities, countries...',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Container(
                          margin: EdgeInsets.only(left: 8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.search,
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _countrySearchQuery = value;
                          _citySearchQuery = value;
                        });
                      },
                    ),
                  ),
                ),

                // Enhanced Destinations Section
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.star,
                                color: primaryColor,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Popular Destinations',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Expanded(
                          child: Consumer(
                            builder: (context, ref, child) {
                              final locationsAsync =
                                  ref.watch(locationProvider);

                              return locationsAsync.when(
                                data: (locationData) {
                                  final countries =
                                      locationData.countries ?? [];
                                  final cities = locationData.cities ?? [];

                                  return ListView(
                                    children: [
                                      // Enhanced Countries Section
                                      if (countries.isNotEmpty) ...[
                                        _buildEnhancedSectionHeader(
                                            'Countries',
                                            Icons.public,
                                            'Explore countries',
                                            primaryColor),
                                        SizedBox(height: 16),
                                        ...countries.take(6).map((country) =>
                                            _buildEnhancedDestinationOption(
                                              country.name ?? 'Country',
                                              Icons.flag,
                                              'Country',
                                              'Discover amazing hotels',
                                              () {
                                                _destinationController.text =
                                                    country.name ?? '';
                                                Navigator.pop(context);
                                              },
                                              primaryColor,
                                            )),
                                        SizedBox(height: 24),
                                      ],

                                      // Enhanced Cities Section
                                      if (cities.isNotEmpty) ...[
                                        _buildEnhancedSectionHeader(
                                            'Cities',
                                            Icons.location_city,
                                            'Find city gems',
                                            primaryColor),
                                        SizedBox(height: 16),
                                        ...cities.take(10).map((city) =>
                                            _buildEnhancedDestinationOption(
                                              city.name ?? 'City',
                                              Icons.location_city,
                                              'City',
                                              'Local experiences await',
                                              () {
                                                _destinationController.text =
                                                    city.name ?? '';
                                                Navigator.pop(context);
                                              },
                                              primaryColor,
                                            )),
                                      ],
                                    ],
                                  );
                                },
                                loading: () => Center(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: CircularProgressIndicator(
                                          color: primaryColor),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Loading amazing destinations...',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )),
                                error: (e, _) => Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Icon(
                                          Icons.error_outline,
                                          color: Colors.red[400],
                                          size: 48,
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Oops! Something went wrong',
                                        style: TextStyle(
                                          color: Colors.red[400],
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Please try again later',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSectionHeader(
      String title, IconData icon, String subtitle, Color primaryColor) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 24,
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDestinationOption(String name, IconData icon,
      String type, String description, VoidCallback onTap, Color primaryColor) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor.withOpacity(0.15),
                        primaryColor.withOpacity(0.25),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: primaryColor,
                    size: 28,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        type,
                        style: TextStyle(
                          fontSize: 14,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: primaryColor,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickGuests() async {
    int adults = _adults;
    int children = _children;
    int rooms = _rooms;
    await showModalBottomSheet(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (_, setModal) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _counterRow(
                        label: 'Adults',
                        value: adults,
                        onChanged: (v) => setModal(() => adults = v),
                        min: 1),
                    _counterRow(
                        label: 'Children',
                        value: children,
                        onChanged: (v) => setModal(() => children = v),
                        min: 0),
                    _counterRow(
                        label: 'Rooms',
                        value: rooms,
                        onChanged: (v) => setModal(() => rooms = v),
                        min: 1),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _adults = adults;
                          _children = children;
                          _rooms = rooms;
                        });
                      },
                      child: Text('Done'),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _counterRow(
      {required String label,
      required int value,
      required ValueChanged<int> onChanged,
      int min = 0}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          IconButton(
              onPressed: value > min ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove_circle_outline)),
          Text('$value'),
          IconButton(
              onPressed: () => onChanged(value + 1),
              icon: const Icon(Icons.add_circle_outline)),
        ],
      ),
    );
  }

  void _onSearchAndNavigate() {
    final baseQuery = _destinationController.text.trim();
    final query = [baseQuery, _selectedCity, _selectedCountry]
        .where((e) => e != null && e!.isNotEmpty)
        .join(' ');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchResultsPage(
          hotels: [], // Empty list for now, will be loaded by the page
          searchQuery: query,
        ),
      ),
    );
  }
}
