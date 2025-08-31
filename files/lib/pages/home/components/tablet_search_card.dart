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

                    // Destination field
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search,
                              color: Colors.grey.shade600, size: 24),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _destinationController,
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                isDense: false,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 10),
                                hintText: 'Enter destination',
                                hintStyle: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.normal),
                                border: InputBorder.none,
                              ),
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) => _onSearchAndNavigate(),
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
