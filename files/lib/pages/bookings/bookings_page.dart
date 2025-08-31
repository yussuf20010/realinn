import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/wp_config.dart';
import '../../providers/bookings_provider.dart';
import '../../models/booking.dart';
import '../hotel_details/hotel_details_page.dart';

class BookingsPage extends ConsumerStatefulWidget {
  const BookingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends ConsumerState<BookingsPage> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final primaryColor = WPConfig.navbarColor;
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100), // App bar height
        child: _buildCustomAppBar(context, primaryColor, isTablet),
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              100, // Adjusted for new app bar height
        ),
        child: Column(
          children: [
            // Navigation tabs
            _buildNavigationTabs(isTablet, primaryColor),

            // Main content
            Expanded(
              child: _buildMainContent(isTablet),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(
      BuildContext context, Color primaryColor, bool isTablet) {
    return Container(
      color: primaryColor,
      child: SafeArea(
        child: Column(
          children: [
            // Main app bar content
            Container(
              height: 80,
              child: Center(
                child: Text(
                  'Trips',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 28 : 24,
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

  Widget _buildNavigationTabs(bool isTablet, Color primaryColor) {
    final tabs = ['Active', 'Past', 'Canceled'];

    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = _selectedTabIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[100] : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        color: isSelected ? primaryColor : Colors.grey[700],
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainContent(bool isTablet) {
    final bookings = ref.watch(bookingsProvider);

    // Filter bookings based on selected tab
    List<Booking> filteredBookings = [];
    switch (_selectedTabIndex) {
      case 0: // Active
        filteredBookings = bookings
            .where((b) =>
                b.status == BookingStatus.confirmed ||
                b.status == BookingStatus.pending)
            .toList();
        break;
      case 1: // Past
        filteredBookings = bookings
            .where((b) =>
                b.status == BookingStatus.completed ||
                b.checkOutDate.isBefore(DateTime.now()))
            .toList();
        break;
      case 2: // Canceled
        filteredBookings =
            bookings.where((b) => b.status == BookingStatus.cancelled).toList();
        break;
    }

    if (filteredBookings.isEmpty) {
      return _buildEmptyState(isTablet);
    }

    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Row(
            children: [
              Icon(Icons.book,
                  color: WPConfig.navbarColor, size: isTablet ? 24 : 20),
              SizedBox(width: 8),
              Text(
                '${filteredBookings.length} ${_getTabTitle()} ${filteredBookings.length == 1 ? 'trip' : 'trips'}',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),

        // Bookings list
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12),
            itemCount: filteredBookings.length,
            itemBuilder: (context, index) {
              final booking = filteredBookings[index];
              return _buildBookingCard(booking, isTablet);
            },
          ),
        ),
      ],
    );
  }

  String _getTabTitle() {
    switch (_selectedTabIndex) {
      case 0:
        return 'active';
      case 1:
        return 'past';
      case 2:
        return 'cancelled';
      default:
        return '';
    }
  }

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Globe illustration
            Container(
              width: isTablet ? 250 : 180,
              height: isTablet ? 250 : 180,
              child: Stack(
                children: [
                  // Blue arc frame
                  Positioned(
                    top: isTablet ? 25 : 18,
                    left: isTablet ? 25 : 18,
                    child: Container(
                      width: isTablet ? 180 : 130,
                      height: isTablet ? 180 : 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border(
                          top: BorderSide(
                            color: Colors.blue[300]!,
                            width: isTablet ? 8 : 6,
                          ),
                          left: BorderSide(
                            color: Colors.blue[300]!,
                            width: isTablet ? 8 : 6,
                          ),
                          right: BorderSide(
                            color: Colors.blue[300]!,
                            width: isTablet ? 8 : 6,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Main globe
                  Center(
                    child: Container(
                      width: isTablet ? 140 : 100,
                      height: isTablet ? 140 : 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.yellow[300]!,
                            Colors.orange[300]!,
                            Colors.orange[400]!,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.public,
                          color: Colors.white,
                          size: isTablet ? 56 : 40,
                        ),
                      ),
                    ),
                  ),

                  // Blue base
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: isTablet ? 60 : 40,
                        height: isTablet ? 20 : 15,
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          borderRadius:
                              BorderRadius.circular(isTablet ? 10 : 8),
                        ),
                      ),
                    ),
                  ),

                  // Flags
                  Positioned(
                    top: isTablet ? 20 : 15,
                    right: isTablet ? 30 : 20,
                    child: Column(
                      children: [
                        Container(
                          width: isTablet ? 20 : 15,
                          height: isTablet ? 15 : 12,
                          decoration: BoxDecoration(
                            color: Colors.blue[700],
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Center(
                            child: Container(
                              width: isTablet ? 16 : 12,
                              height: isTablet ? 11 : 8,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          width: isTablet ? 20 : 15,
                          height: isTablet ? 15 : 12,
                          decoration: BoxDecoration(
                            color: Colors.orange[600],
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Center(
                            child: Container(
                              width: isTablet ? 16 : 12,
                              height: isTablet ? 11 : 8,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(1),
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

            SizedBox(height: isTablet ? 32 : 24),

            // Heading
            Text(
              'Where to next?',
              style: TextStyle(
                fontSize: isTablet ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: isTablet ? 16 : 12),

            // Description
            Text(
              'You haven\'t started any trips yet. Once you make a booking, it\'ll appear here.',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, bool isTablet) {
    final primaryColor = WPConfig.navbarColor;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HotelDetailsPage(hotel: booking.hotel),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hotel name and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      booking.hotel.name ?? 'Hotel Name',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(booking.status),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 12 : 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8),

              // Location
              if (booking.hotel.city != null)
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                    SizedBox(width: 4),
                    Text(
                      booking.hotel.city!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isTablet ? 14 : 12,
                      ),
                    ),
                  ],
                ),

              SizedBox(height: 12),

              // Dates and details
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Check-in',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: isTablet ? 12 : 10,
                          ),
                        ),
                        Text(
                          '${booking.checkInDate.day}/${booking.checkInDate.month}/${booking.checkInDate.year}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Check-out',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: isTablet ? 12 : 10,
                          ),
                        ),
                        Text(
                          '${booking.checkOutDate.day}/${booking.checkOutDate.month}/${booking.checkOutDate.year}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: isTablet ? 12 : 10,
                          ),
                        ),
                        Text(
                          '\$${booking.totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.pending:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.pending:
        return 'Pending';
      default:
        return 'Unknown';
    }
  }
}
