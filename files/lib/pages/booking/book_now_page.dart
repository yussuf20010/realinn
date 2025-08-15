import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/wp_config.dart';
import '../../models/hotel.dart';
import '../../config/image_cache_config.dart';
import '../../config/wp_config.dart';
import '../../controllers/location_controller.dart';
import '../../models/location.dart' as location_model;
import '../../widgets/custom_app_bar.dart';
import '../booking/booking_page.dart';
import '../notifications/notifications_page.dart';
import 'package:easy_localization/easy_localization.dart';

class BookNowPage extends ConsumerStatefulWidget {
  final Hotel hotel;
  final int bookingType; // 0: daily (time), 1: monthly (dates)
  final DateTimeRange? dateRangeFromSearch;
  final TimeOfDay? startTimeFromSearch;
  final TimeOfDay? endTimeFromSearch;

  const BookNowPage({
    Key? key,
    required this.hotel,
    required this.bookingType,
    this.dateRangeFromSearch,
    this.startTimeFromSearch,
    this.endTimeFromSearch,
  }) : super(key: key);

  @override
  ConsumerState<BookNowPage> createState() => _BookNowPageState();
}

class _BookNowPageState extends ConsumerState<BookNowPage> {
  int selectedRoomIndex = 0;
  DateTimeRange? selectedDateRange;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  
  String _normalizeImageUrl(String raw) {
    if (raw.isEmpty) return raw;
    if (raw.startsWith('http')) return raw;
    if (!raw.startsWith('/')) raw = '/'+raw;
    return WPConfig.siteStorageUrl + raw.replaceFirst(RegExp(r'^/+'), '');
  }

  String _resolveHeaderImageUrl() {
    try {
      final images = widget.hotel.images;
      if (images != null && images.isNotEmpty) {
        return _normalizeImageUrl(images.first);
      }
    } catch (_) {}
    return widget.hotel.imageUrl != null ? _normalizeImageUrl(widget.hotel.imageUrl!) : '';
  }

  final List<Map<String, dynamic>> roomOptions = const [
    {
      'name': 'Standard Room',
      'price': 60.0,
      'maxAdults': 2,
      'maxChildren': 1,
      'amenities': ['Free WiFi', 'TV']
    },
    {
      'name': 'Deluxe Room',
      'price': 85.0,
      'maxAdults': 3,
      'maxChildren': 2,
      'amenities': ['Free WiFi', 'Smart TV', 'Mini Bar']
    },
    {
      'name': 'Suite',
      'price': 120.0,
      'maxAdults': 4,
      'maxChildren': 2,
      'amenities': ['Free WiFi', 'Living Area', 'Kitchenette', 'Balcony']
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.bookingType == 1 && widget.dateRangeFromSearch != null) {
      selectedDateRange = widget.dateRangeFromSearch;
    }
    if (widget.bookingType == 0) {
      selectedStartTime = widget.startTimeFromSearch;
      selectedEndTime = widget.endTimeFromSearch;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = WPConfig.navbarColor;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'book_now'.tr(),
        showBackButton: true,
        // Show profile, chat, logo, lang, notification like other main pages
        onNotificationPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsPage()),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHotelHeader(),
            const SizedBox(height: 12),
            _buildIntervalCard(primary),
            const SizedBox(height: 12),
            _buildRoomsCard(primary),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canConfirm() ? _confirmBooking : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('confirm'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHotelHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: Builder(builder: (context) {
                final url = _resolveHeaderImageUrl();
                if (url.isEmpty) {
                  return Container(color: Colors.grey[200], child: const Icon(Icons.hotel, size: 56, color: Colors.grey));
                }
                return ImageCacheConfig.buildCachedImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.hotel.name ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Consumer(
                  builder: (context, ref, _) {
                    final locationResponse = ref.watch(locationProvider);
                    return locationResponse.when(
                      data: (locationData) {
                        String locationText = '';
                        if (widget.hotel.cityId != null) {
                          final city = locationData.cities?.firstWhere(
                            (c) => c.id == widget.hotel.cityId,
                            orElse: () => location_model.City(),
                          );
                          if (city?.name != null) locationText = city!.name!;
                        }
                        if (widget.hotel.countryId != null) {
                          final country = locationData.countries?.firstWhere(
                            (c) => c.id == widget.hotel.countryId,
                            orElse: () => location_model.Country(),
                          );
                          if (country?.name != null) {
                            locationText = locationText.isNotEmpty ? '$locationText, ${country!.name}' : country!.name!;
                          }
                        }
                        if (locationText.isEmpty) {
                          locationText = '${widget.hotel.city ?? ''}${widget.hotel.country != null ? ', ${widget.hotel.country}' : ''}';
                        }
                        return Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.black54),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                locationText,
                                style: const TextStyle(color: Colors.black54, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.black54),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${widget.hotel.city ?? ''}${widget.hotel.country != null ? ', ${widget.hotel.country}' : ''}',
                              style: const TextStyle(color: Colors.black54, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      error: (e, __) => Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.black54),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${widget.hotel.city ?? ''}${widget.hotel.country != null ? ', ${widget.hotel.country}' : ''}',
                              style: const TextStyle(color: Colors.black54, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalCard(Color primary) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(widget.bookingType == 0 ? Icons.access_time : Icons.calendar_today, color: primary, size: 18),
              ),
              const SizedBox(width: 8),
              Text(widget.bookingType == 0 ? 'Daily time'.tr() : 'Dates'.tr(), style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.bookingType == 0) ...[
            _intervalTile(
              icon: Icons.access_time,
              title: 'Start time'.tr(),
              subtitle: selectedStartTime != null ? _formatTime(selectedStartTime!) : 'Select start time'.tr(),
              onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: selectedStartTime ?? TimeOfDay.now());
                if (picked != null) setState(() => selectedStartTime = picked);
              },
            ),
            const Divider(height: 1),
            _intervalTile(
              icon: Icons.access_time,
              title: 'End time'.tr(),
              subtitle: selectedEndTime != null ? _formatTime(selectedEndTime!) : 'Select end time'.tr(),
              onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: selectedEndTime ?? (selectedStartTime ?? TimeOfDay.now()));
                if (picked != null) setState(() => selectedEndTime = picked);
              },
            ),
          ] else ...[
            _intervalTile(
              icon: Icons.calendar_today,
              title: 'Date range'.tr(),
              subtitle: selectedDateRange != null
                  ? '${DateFormat('yMMMd').format(selectedDateRange!.start)} - ${DateFormat('yMMMd').format(selectedDateRange!.end)}'
                  : 'Select dates'.tr(),
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDateRangePicker(context: context, firstDate: now, lastDate: now.add(const Duration(days: 365)));
                if (picked != null) setState(() => selectedDateRange = picked);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _intervalTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildRoomsCard(Color primary) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.meeting_room, color: primary, size: 18),
              ),
              const SizedBox(width: 8),
              Text('Select Room'.tr(), style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(roomOptions.length, (index) {
            final option = roomOptions[index];
            final isSelected = index == selectedRoomIndex;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected ? primary.withOpacity(0.06) : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? primary : Colors.grey[300]!),
              ),
              child: RadioListTile<int>(
                value: index,
                groupValue: selectedRoomIndex,
                onChanged: (v) => setState(() => selectedRoomIndex = v ?? 0),
                activeColor: primary,
                title: Text(option['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('USD ${(option['price'] as double).toStringAsFixed(0)} / night'),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: -6,
                      children: List<Widget>.from(
                        (option['amenities'] as List).map((a) => Chip(
                          label: Text(a, style: const TextStyle(fontSize: 10)),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            );
          })
        ],
      ),
    );
  }

  bool _canConfirm() {
    if (widget.bookingType == 0) {
      return selectedStartTime != null && selectedEndTime != null;
    }
    return selectedDateRange != null;
  }

  void _confirmBooking() {
    final selectedRoom = roomOptions[selectedRoomIndex];
    final DateTime checkIn;
    final DateTime checkOut;
    if (widget.bookingType == 0) {
      final now = DateTime.now();
      checkIn = DateTime(now.year, now.month, now.day, selectedStartTime!.hour, selectedStartTime!.minute);
      checkOut = DateTime(now.year, now.month, now.day, selectedEndTime!.hour, selectedEndTime!.minute);
    } else {
      checkIn = selectedDateRange!.start;
      checkOut = selectedDateRange!.end;
    }

    final int seed = (widget.hotel.id?.hashCode ?? widget.hotel.name?.hashCode ?? 0).abs();
    final booking = Booking(
      hotel: widget.hotel,
      selectedRoom: SelectedRoom(
        name: selectedRoom['name'] as String,
        pricePerNight: selectedRoom['price'] as double,
        maxAdults: selectedRoom['maxAdults'] as int,
        maxChildren: selectedRoom['maxChildren'] as int,
        imageUrl: 'https://source.unsplash.com/featured/?hotel,room&sig=${seed + 900 + selectedRoomIndex}',
        amenities: List<String>.from(selectedRoom['amenities'] as List),
      ),
      checkIn: checkIn,
      checkOut: checkOut,
      adults: 1,
      children: 0,
      rooms: 1,
      status: 'upcoming',
    );

    ref.read(bookingsProvider.notifier).addBooking(booking);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('booking_confirmed'.tr()))
    );
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}


