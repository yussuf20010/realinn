import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../config/dynamic_config.dart';
import '../../../../core/constants/assets.dart';
import '../providers/home_providers.dart';
import '../../../controllers/location_controller.dart';
import '../../../models/location.dart' as location_model;
import '../search_results_page.dart';

class MobileSearchCard extends ConsumerStatefulWidget {
  final VoidCallback onDailyBookingTap;
  final VoidCallback onMonthlyBookingTap;

  const MobileSearchCard({
    Key? key,
    required this.onDailyBookingTap,
    required this.onMonthlyBookingTap,
  }) : super(key: key);

  @override
  ConsumerState<MobileSearchCard> createState() => _MobileSearchCardState();
}

class _MobileSearchCardState extends ConsumerState<MobileSearchCard> {
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
    final bool isTablet = MediaQuery.of(context).size.width >= 768;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Booking type selector
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: Colors.grey.shade600, size: 20),
                          const SizedBox(width: 12),
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

                    // Destination field
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search,
                              color: Colors.grey.shade600, size: 24),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _showDestinationModal(
                                  context, primaryColor, isTablet),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  _destinationController.text.isEmpty
                                      ? 'Select destination'
                                      : _destinationController.text,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: _destinationController.text.isEmpty
                                        ? Colors.grey.shade500
                                        : Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.keyboard_arrow_down,
                                color: Colors.grey.shade600),
                            onPressed: () => _showDestinationModal(
                                context, primaryColor, isTablet),
                          ),
                        ],
                      ),
                    ),

                    // Date/Time selector based on booking type
                    if (_selectedBookingType == 0)
                      // Daily: show time range selectors
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time,
                                color: Colors.grey.shade600, size: 20),
                            const SizedBox(width: 12),
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
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('-',
                                      style: TextStyle(
                                          color: Colors.grey.shade600)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _pickEndTime,
                                      child: Text(
                                        _endTime == null
                                            ? 'End time'
                                            : _formatTime(_endTime!),
                                        style: TextStyle(
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: Colors.grey.shade600, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: _pickDateRange,
                                child: Text(
                                  _dateRange != null
                                      ? '${DateFormat('EEE, d MMM').format(_dateRange!.start)} - ${DateFormat('EEE, d MMM').format(_dateRange!.end)}'
                                      : 'Select dates',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black87),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Guests/Rooms selector
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                      child: Row(
                        children: [
                          Icon(Icons.person,
                              color: Colors.grey.shade600, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickGuests,
                              child: Text(
                                '${_rooms} room · ${_adults} adults · ${_children} children',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black87),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

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
                              offset: const Offset(0, 4),
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            minimumSize: Size(double.infinity, 40),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search, size: 20, color: Colors.white),
                              const SizedBox(width: 8),
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
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _startTime = time);
    }
  }

  Future<void> _pickEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _endTime ?? (_startTime ?? TimeOfDay.now()),
    );
    if (time != null) {
      setState(() => _endTime = time);
    }
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
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
          hotels: [],
          searchQuery: query,
        ),
      ),
    );
  }

  void _showDestinationModal(
      BuildContext context, Color primaryColor, bool isTablet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _buildDestinationModal(context, primaryColor, isTablet),
    );
  }

  Widget _buildDestinationModal(
      BuildContext context, Color primaryColor, bool isTablet) {
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
                  Icons.location_on,
                  color: Colors.white,
                  size: isTablet ? 28 : 24,
                ),
                SizedBox(width: 16),
                Text(
                  'Select Destination',
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
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7),
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _destinationController,
                      decoration: InputDecoration(
                        hintText: 'Search destinations...',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: primaryColor,
                          size: 24,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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

                // Popular Destinations
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Popular Destinations',
                          style: TextStyle(
                            fontSize: isTablet ? 20 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
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
                                      // Countries
                                      if (countries.isNotEmpty) ...[
                                        _buildSectionHeader('Countries',
                                            Icons.public, primaryColor),
                                        SizedBox(height: 12),
                                        ...countries.take(4).map((country) =>
                                            _buildDestinationOption(
                                              country.name ?? 'Country',
                                              Icons.flag,
                                              'Country',
                                              () {
                                                _destinationController.text =
                                                    country.name ?? '';
                                                Navigator.pop(context);
                                              },
                                              isTablet,
                                              primaryColor,
                                            )),
                                        SizedBox(height: 24),
                                      ],

                                      // Cities
                                      if (cities.isNotEmpty) ...[
                                        _buildSectionHeader('Cities',
                                            Icons.location_city, primaryColor),
                                        SizedBox(height: 12),
                                        ...cities.take(8).map(
                                            (city) => _buildDestinationOption(
                                                  city.name ?? 'City',
                                                  Icons.location_city,
                                                  'City',
                                                  () {
                                                    _destinationController
                                                        .text = city.name ?? '';
                                                    Navigator.pop(context);
                                                  },
                                                  isTablet,
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
                                    CircularProgressIndicator(
                                        color: primaryColor),
                                    SizedBox(height: 16),
                                    Text(
                                      'Loading destinations...',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                )),
                                error: (e, _) => Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red[400],
                                        size: 48,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Error loading destinations',
                                        style: TextStyle(
                                          color: Colors.red[400],
                                          fontSize: 16,
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

  Widget _buildSectionHeader(String title, IconData icon, Color primaryColor) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationOption(String name, IconData icon, String type,
      VoidCallback onTap, bool isTablet, Color primaryColor) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: primaryColor,
                    size: isTablet ? 28 : 24,
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
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        type,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
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
}
