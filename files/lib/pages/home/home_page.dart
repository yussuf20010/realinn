import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realinn/config/wp_config.dart';
import '../../config/image_cache_config.dart';
import '../../controllers/hotel_controller.dart';
import '../../controllers/location_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../models/hotel.dart';
import '../../models/location.dart';
import '../../widgets/CustomBottomNavBar.dart';
import '../all_hotels/all_hotels_page.dart';
import '../all_locations/all_locations_page.dart';
import '../booking/booking_page.dart';
import '../favorites/favorites_page.dart';
import '../location_page/location_hotels_page.dart';
import '../hotel_details/hotel_details_page.dart';
import '../notifications/notifications_page.dart';
import '../profile/profile_page.dart';
import 'package:easy_localization/easy_localization.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with AutomaticKeepAliveClientMixin, RouteAware {
  int _selectedTab = 0;
  int _selectedBookingType = 0;
  final List<Map<String, dynamic>> _tabs = [
    {'icon': Icons.hotel, 'label': 'stays'.tr()},
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: WPConfig.primaryColor,
        elevation: 0,
        title: Text('Realinn', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22)),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsPage()));
            },
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: Container(
            color: WPConfig.primaryColor,
            child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10, top: 2),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(_tabs.length, (index) {
                    final tab = _tabs[index];
                    final selected = _selectedTab == index;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTab = index;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: selected
                              ? BoxDecoration(
                                  color: Colors.yellow.shade300,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.yellow.withOpacity(0.5),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                )
                              : null,
                          child: Row(
                            children: [
                              Icon(tab['icon'], color: selected ? WPConfig.primaryColor : Colors.white, size: 22),
                              SizedBox(width: 6),
                              Text(
                                tab['label'],
                                style: TextStyle(
                                  color: selected ? WPConfig.primaryColor : Colors.white,
                                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // شريط اختيار نوع الحجز
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedBookingType = 0),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedBookingType == 0 ? WPConfig.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: WPConfig.primaryColor),
                      ),
                      child: Center(
                        child: Text(
                          'daily_booking'.tr(),
                          style: TextStyle(
                            color: _selectedBookingType == 0 ? Colors.white : WPConfig.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedBookingType = 1),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedBookingType == 1 ? WPConfig.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: WPConfig.primaryColor),
                      ),
                      child: Center(
                        child: Text(
                          'monthly_booking'.tr(),
                          style: TextStyle(
                            color: _selectedBookingType == 1 ? Colors.white : WPConfig.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text('stay_at_unique_properties'.tr(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ),
          SizedBox(
            height: screenHeight * 0.32,
            child: Consumer(
              builder: (context, ref, _) {
                final hotelsAsync = ref.watch(hotelProvider);
                return hotelsAsync.when(
                  data: (hotels) => ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: hotels.length,
                    separatorBuilder: (_, __) => SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final hotel = hotels[index];
                      return _HotelCardModern(hotel: hotel, bookingType: _selectedBookingType);
                    },
                  ),
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error loading hotels')),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text('deals_for_weekend'.tr(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ),
          SizedBox(
            height: screenHeight * 0.32,
            child: Consumer(
              builder: (context, ref, _) {
                final hotelsAsync = ref.watch(hotelProvider);
                return hotelsAsync.when(
                  data: (hotels) => ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: hotels.length,
                    separatorBuilder: (_, __) => SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final hotel = hotels[index];
                      return _HotelCardModern(hotel: hotel, bookingType: _selectedBookingType);
                    },
                  ),
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error loading hotels')),
                );
              },
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedTab,
        onTap: (index) {
          if (index == _selectedTab) return;
          setState(() {
            _selectedTab = index;
          });
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const BookingPage()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesPage()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
              break;
          }
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

// تحديث _HotelCardModern لقبول نوع الحجز
class _HotelCardModern extends ConsumerWidget {
  final Hotel hotel;
  final int bookingType; // 0: يومي، 1: شهري
  const _HotelCardModern({required this.hotel, this.bookingType = 0});

  String _getImageUrl(Hotel hotel) {
    if (hotel.images?.isNotEmpty == true) {
      return hotel.images!.first;
    }
    return hotel.imageUrl ?? '';
  }

  String getBookingPrice() {
    // priceRange is String, so parse it to double
    double? price;
    try {
      price = hotel.priceRange != null ? double.tryParse(hotel.priceRange!) : null;
    } catch (_) {
      price = null;
    }
    if (bookingType == 1 && price != null) {
      // شهري: افترض خصم 30%
      return '\$${(price * 30 * 0.7).toStringAsFixed(0)} / شهر';
    } else if (price != null) {
      return '\$${price.toStringAsFixed(0)} / يوم';
    }
    return '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = _getImageUrl(hotel);
    final isFavorite = ref.watch(favoritesProvider).any((h) => h.id == hotel.id);
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.7; // wider card for Booking.com look
    // بيانات وهمية للخدمات القريبة
    final List<Map<String, dynamic>> nearbyServices = [
      {
        'icon': Icons.restaurant,
        'name': 'مطعم الأرز',
        'type': 'مطعم',
        'rating': 4.5,
      },
      {
        'icon': Icons.local_pharmacy,
        'name': 'صيدلية الشفاء',
        'type': 'صيدلية',
        'rating': 4.8,
      },
      {
        'icon': Icons.local_hospital,
        'name': 'عيادة الحياة',
        'type': 'عيادة',
        'rating': 4.2,
      },
    ];
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HotelDetailsPage(hotel: hotel),
          ),
        );
      },
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    child: ImageCacheConfig.buildCachedImage(
                      imageUrl: imageUrl,
                      height: cardWidth * 0.55,
                      width: cardWidth,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      errorWidget: Container(
                        width: cardWidth,
                        height: cardWidth * 0.55,
                        color: Colors.grey[300],
                        child: Image.asset(
                          'assets/png/error.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        if (isFavorite) {
                          ref.read(favoritesProvider.notifier).removeHotel(hotel);
                        } else {
                          ref.read(favoritesProvider.notifier).addHotel(hotel);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            hotel.name ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hotel.rate != null)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: WPConfig.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  hotel.rate!.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.star, color: Colors.white, size: 14),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            hotel.location ?? '',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          getBookingPrice(),
                          style: TextStyle(
                            color: WPConfig.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // قسم الخدمات القريبة
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentedControl extends StatefulWidget {
  @override
  State<_SegmentedControl> createState() => _SegmentedControlState();
}

class _SegmentedControlState extends State<_SegmentedControl> {
  int selected = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: WPConfig.primaryColor.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        children: [
          _buildTab('Daily', 0),
          SizedBox(width: 8),
          _buildTab('Monthly', 1),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = selected == index;
    return Expanded(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
        decoration: BoxDecoration(
          color: isSelected ? WPConfig.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: WPConfig.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() => selected = index),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : WPConfig.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchCardV2 extends StatefulWidget {
  @override
  State<_SearchCardV2> createState() => _SearchCardV2State();
}

class _SearchCardV2State extends State<_SearchCardV2> {
  int expandedField = -1; // -1: none, 0: location, 1: checkin, 2: checkout, 3: guests
  String location = 'Abidjan';
  DateTime? checkIn;
  DateTime? checkOut;
  int adults = 0;
  int children = 0;
  int rooms = 0;
  String locationSearch = '';

  void _expandField(int field) {
    setState(() {
      expandedField = expandedField == field ? -1 : field;
    });
  }

  void _selectDate(DateTime date, bool isCheckIn) {
    setState(() {
      if (isCheckIn) {
        checkIn = date;
      } else {
        checkOut = date;
      }
      expandedField = -1;
    });
  }

  void _selectGuests(int a, int c, int r) {
    setState(() {
      adults = a;
      children = c;
      rooms = r;
      expandedField = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 12,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildField(
              icon: Icons.location_on,
              value: location,
              expanded: expandedField == 0,
              onTap: () => _expandField(0),
              child: expandedField == 0
                  ? _LocationDropdown(
                      onSelectLocation: (loc) => setState(() => location = loc.country ?? ''),
                      onSelectHotel: (hotel) => setState(() => location = hotel.location ?? ''),
                      onSearch: (s) => setState(() => locationSearch = s),
                      search: locationSearch,
                    )
                  : null,
            ),
            SizedBox(height: 16),
            _buildField(
              icon: Icons.calendar_today,
              value: checkIn != null ? _formatDate(checkIn!) : 'Checkin date & time',
              expanded: expandedField == 1,
              onTap: () => _expandField(1),
              child: expandedField == 1
                  ? _DateTimeGridPicker(
                      initialDate: checkIn ?? DateTime.now(),
                      onDateSelected: (date) => _selectDate(date, true),
                    )
                  : null,
            ),
            SizedBox(height: 16),
            _buildField(
              icon: Icons.calendar_today,
              value: checkOut != null ? _formatDate(checkOut!) : 'Checkout date & time',
              expanded: expandedField == 2,
              onTap: () => _expandField(2),
              child: expandedField == 2
                  ? _DateTimeGridPicker(
                      initialDate: checkOut ?? DateTime.now().add(Duration(days: 1)),
                      onDateSelected: (date) => _selectDate(date, false),
                    )
                  : null,
            ),
            SizedBox(height: 16),
            _buildField(
              icon: Icons.people,
              value: '${adults} Adults. ${children} Children. ${rooms} room',
              expanded: expandedField == 3,
              onTap: () => _expandField(3),
              child: expandedField == 3
                  ? _GuestsGridPicker(
                      adults: adults,
                      children: children,
                      rooms: rooms,
                      onChanged: _selectGuests,
                    )
                  : null,
            ),
            SizedBox(height: 24),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    WPConfig.primaryColor,
                    WPConfig.primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: WPConfig.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Center(
                      child: Text(
                        'Search',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({required IconData icon, required String value, String? subtitle, required bool expanded, required VoidCallback onTap, Widget? child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            decoration: BoxDecoration(
              color: Color(0xFFF6F8FA),
              borderRadius: BorderRadius.circular(16),
              border: expanded ? Border.all(color: WPConfig.primaryColor, width: 1.5) : null,
              boxShadow: expanded ? [
                BoxShadow(
                  color: WPConfig.primaryColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ] : null,
            ),
            child: Row(
              children: [
                Icon(icon, color: WPConfig.primaryColor, size: 22),
                SizedBox(width: 14),
                Expanded(
                  child: subtitle == null
                      ? Text(
                          value,
                          style: TextStyle(
                            color: (value.contains('date') || value.contains('Where')) ? Colors.grey[600] : Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 2),
                            Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                          ],
                        ),
                ),
                Icon(expanded ? Icons.expand_less : Icons.expand_more, color: WPConfig.primaryColor),
              ],
            ),
          ),
        ),
        if (expanded && child != null)
          Container(
            margin: EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
      ],
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: value ? WPConfig.primaryColor : Color(0xFFF6F8FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: value ? WPConfig.primaryColor : Colors.grey[300]!),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: value ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _LocationDropdown extends ConsumerWidget {
  final void Function(LocationModel) onSelectLocation;
  final void Function(Hotel) onSelectHotel;
  final void Function(String) onSearch;
  final String search;
  const _LocationDropdown({required this.onSelectLocation, required this.onSelectHotel, required this.onSearch, required this.search});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(locationProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search country',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            onChanged: onSearch,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text('Countries', style: TextStyle(fontWeight: FontWeight.bold, color: WPConfig.primaryColor)),
        ),
        locationsAsync.when(
          data: (locations) {
            final filtered = locations.where((loc) =>
              (loc.country ?? '').toLowerCase().contains(search.toLowerCase()) ||
              (loc.capital ?? '').toLowerCase().contains(search.toLowerCase())
            ).toList();
            return Column(
              children: filtered.map((loc) => ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: loc.image ?? '',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 40,
                      height: 40,
                      color: WPConfig.primaryColor.withOpacity(0.1),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(WPConfig.primaryColor),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 40,
                      height: 40,
                      color: WPConfig.primaryColor.withOpacity(0.1),
                      child: Icon(Icons.location_on, color: WPConfig.primaryColor, size: 20),
                    ),
                  ),
                ),
                title: Text(loc.country ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(loc.capital ?? ''),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: WPConfig.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.hotel, size: 14, color: WPConfig.primaryColor),
                      SizedBox(width: 4),
                      Text(
                        '${loc.numberOfHotels}',
                        style: TextStyle(
                          color: WPConfig.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () => onSelectLocation(loc),
              )).toList(),
            );
          },
          loading: () => Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading locations')),
        ),
      ],
    );
  }
}

class _DateTimeGridPicker extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;
  const _DateTimeGridPicker({required this.initialDate, required this.onDateSelected});
  @override
  State<_DateTimeGridPicker> createState() => _DateTimeGridPickerState();
}

class _DateTimeGridPickerState extends State<_DateTimeGridPicker> {
  late int selectedDay;
  late int selectedMonth;
  late int selectedYear;
  late int selectedHour;
  late int selectedMinute;

  @override
  void initState() {
    super.initState();
    selectedDay = widget.initialDate.day;
    selectedMonth = widget.initialDate.month;
    selectedYear = widget.initialDate.year;
    selectedHour = widget.initialDate.hour;
    selectedMinute = widget.initialDate.minute;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDropdown('Day', selectedDay, 1, 31, (v) => setState(() => selectedDay = v)),
              _buildDropdown('Month', selectedMonth, 1, 12, (v) => setState(() => selectedMonth = v)),
              _buildDropdown('Year', selectedYear, 2018, 2025, (v) => setState(() => selectedYear = v)),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDropdown('Hour', selectedHour, 0, 23, (v) => setState(() => selectedHour = v)),
              _buildDropdown('Min', selectedMinute, 0, 59, (v) => setState(() => selectedMinute = v)),
              SizedBox(width: 60),
            ],
          ),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              widget.onDateSelected(DateTime(selectedYear, selectedMonth, selectedDay, selectedHour, selectedMinute));
            },
            child: Text('OK'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF9461c9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, int value, int min, int max, ValueChanged<int> onChanged) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Color(0xFF9461c9), fontWeight: FontWeight.bold)),
        SizedBox(
          width: 56,
          child: DropdownButton<int>(
            value: value,
            isExpanded: true,
            underline: SizedBox(),
            items: List.generate(max - min + 1, (i) => min + i)
                .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
                .toList(),
            onChanged: (v) => onChanged(v!),
          ),
        ),
      ],
    );
  }
}

class _GuestsGridPicker extends StatefulWidget {
  final int adults;
  final int children;
  final int rooms;
  final void Function(int, int, int) onChanged;
  const _GuestsGridPicker({required this.adults, required this.children, required this.rooms, required this.onChanged});
  @override
  State<_GuestsGridPicker> createState() => _GuestsGridPickerState();
}

class _GuestsGridPickerState extends State<_GuestsGridPicker> {
  late int adults;
  late int children;
  late int rooms;
  @override
  void initState() {
    super.initState();
    adults = widget.adults;
    children = widget.children;
    rooms = widget.rooms;
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCounter('Adults', adults, (v) => setState(() => adults = v)),
              _buildCounter('Children', children, (v) => setState(() => children = v)),
              _buildCounter('Rooms', rooms, (v) => setState(() => rooms = v)),
            ],
          ),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => widget.onChanged(adults, children, rooms),
            child: Text('Done'),
            style: ElevatedButton.styleFrom(
              backgroundColor: WPConfig.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCounter(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove_circle_outline),
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
            ),
            Text('$value', style: TextStyle(fontSize: 16)),
            IconButton(
              icon: Icon(Icons.add_circle_outline),
              onPressed: () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }
}







