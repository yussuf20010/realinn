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
  int _adults = 1;
  int _children = 0;
  int _rooms = 1;
  DateTimeRange? _dateRange;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _selectedCountry;
  String _countrySearchQuery = '';
  String? _selectedCity;
  String _citySearchQuery = '';

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final Color primaryColor = dynamicConfig.primaryColor ?? const Color(0xFF895ffc);
    final int bookingType = ref.watch(selectedBookingTypeProvider);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            // Destination field
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey.shade600, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _destinationController,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'search_where_to_go_hint'.tr(),
                        hintStyle: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        border: InputBorder.none,
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _onSearchAndNavigate(),
                    ),
                  ),
                ],
              ),
            ),
            
          
            // Time or Date field
            if (bookingType == 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.grey.shade600, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickStartTime,
                              child: Text(
                                _startTime == null ? 'Start time'.tr() : _formatTime(_startTime!),
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('-', style: TextStyle(color: Colors.grey.shade600)),
                          SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickEndTime,
                              child: Text(
                                _endTime == null ? 'End time'.tr() : _formatTime(_endTime!),
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickDateRange,
                        child: Text(
                          _dateRange == null
                              ? 'select_date_time'.tr()
                              : '${DateFormat('yMMMd').format(_dateRange!.start)} - ${DateFormat('yMMMd').format(_dateRange!.end)}',
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Guests/Rooms field
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.grey.shade600, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickGuests,
                      child: Text(
                        '${_rooms} ${'rooms'.tr()} · ${_adults} ${'adults'.tr()} · ${_children} ${'children'.tr()}',
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 12),
            
            // Search button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onSearchAndNavigate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'search'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
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

  Future<void> _pickCountry() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (_, setModal) {
            final locationAsync = ref.watch(locationProvider);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search country'.tr(),
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (v) => setModal(() => _countrySearchQuery = v.trim().toLowerCase()),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: locationAsync.when(
                        data: (data) {
                          final countries = (data.countries ?? [])
                              .where((c) => _countrySearchQuery.isEmpty || (c.name ?? '').toLowerCase().contains(_countrySearchQuery))
                              .toList();
                          return ListView.builder(
                            itemCount: countries.length,
                            itemBuilder: (_, i) {
                              final name = countries[i].name ?? '';
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: AssetImage(AssetsManager.logo),
                                ),
                                title: Text(name),
                                onTap: () {
                                  Navigator.pop(context);
                                  setState(() => _selectedCountry = name);
                                  setState(() => _selectedCity = null);
                                },
                              );
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, __) => Center(child: Text('Error loading countries'.tr())),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickCity() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (_, setModal) {
            final locationAsync = ref.watch(locationProvider);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search city'.tr(),
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (v) => setModal(() => _citySearchQuery = v.trim().toLowerCase()),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: locationAsync.when(
                        data: (data) {
                          final countries = data.countries ?? [];
                          final citiesAll = data.cities ?? [];
                          int? selectedCountryId;
                          if (_selectedCountry != null) {
                            selectedCountryId = countries
                                .firstWhere((c) => (c.name ?? '') == _selectedCountry, orElse: () => location_model.Country())
                                .id;
                          }
                          final cities = citiesAll
                              .where((c) => (selectedCountryId == null || c.countryId == selectedCountryId))
                              .where((c) => _citySearchQuery.isEmpty || (c.name ?? '').toLowerCase().contains(_citySearchQuery))
                              .toList();
                          return ListView.builder(
                            itemCount: cities.length,
                            itemBuilder: (_, i) {
                              final name = cities[i].name ?? '';
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: AssetImage(AssetsManager.logo),
                                ),
                                title: Text(name),
                                onTap: () {
                                  Navigator.pop(context);
                                  setState(() => _selectedCity = name);
                                },
                              );
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, __) => Center(child: Text('Error loading cities'.tr())),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _counterRow(label: 'adults'.tr(), value: adults, onChanged: (v) => setModal(() => adults = v), min: 1),
                    _counterRow(label: 'children'.tr(), value: children, onChanged: (v) => setModal(() => children = v), min: 0),
                    _counterRow(label: 'rooms'.tr(), value: rooms, onChanged: (v) => setModal(() => rooms = v), min: 1),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: () { Navigator.pop(context); setState(() { _adults = adults; _children = children; _rooms = rooms; }); }, child: Text('done'.tr()))
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _counterRow({required String label, required int value, required ValueChanged<int> onChanged, int min = 0}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          IconButton(onPressed: value > min ? () => onChanged(value - 1) : null, icon: const Icon(Icons.remove_circle_outline)),
          Text('$value'),
          IconButton(onPressed: () => onChanged(value + 1), icon: const Icon(Icons.add_circle_outline)),
        ],
      ),
    );
  }

  void _onSearchAndNavigate() {
    final int bookingType = ref.read(selectedBookingTypeProvider);
    final baseQuery = _destinationController.text.trim();
    final query = [baseQuery, _selectedCity, _selectedCountry]
        .where((e) => e != null && e!.isNotEmpty)
        .join(' ');
    ref.read(selectedLocationsProvider.notifier).state = query.isEmpty ? [] : [query];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchResultsPage(
          query: query,
          adults: _adults,
          children: _children,
          rooms: _rooms,
          dateRange: _dateRange,
          startTime: bookingType == 0 ? _startTime : null,
          endTime: bookingType == 0 ? _endTime : null,
        ),
      ),
    );
  }
} 