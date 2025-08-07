import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/wp_config.dart';
import '../../models/hotel.dart';
import '../../widgets/custom_app_bar.dart';
import '../hotel_details/hotel_details_page.dart';
import '../notifications/notifications_page.dart';
import '../settings/pages/customer_support_page.dart';
import '../home/components/hotel_card.dart'; // Import to use HotelCardModern


final bookingsProvider = StateNotifierProvider<BookingsNotifier, List<Booking>>((ref) {
  return BookingsNotifier();
});

class Booking {
  final Hotel hotel;
  final DateTime checkIn;
  final DateTime checkOut;
  final int adults;
  final int children;
  final int rooms;
  final String status; // 'upcoming', 'completed', 'cancelled'

  Booking({
    required this.hotel,
    required this.checkIn,
    required this.checkOut,
    required this.adults,
    required this.children,
    required this.rooms,
    this.status = 'upcoming',
  });
}

class BookingsNotifier extends StateNotifier<List<Booking>> {
  BookingsNotifier() : super([]);

  void addBooking(Booking booking) {
    state = [...state, booking];
  }

  void removeBooking(Booking booking) {
    state = state.where((b) => b.hotel.id != booking.hotel.id).toList();
  }

  void updateBookingStatus(Booking booking, String newStatus) {
    state = state.map((b) {
      if (b.hotel.id == booking.hotel.id) {
        return Booking(
          hotel: b.hotel,
          checkIn: b.checkIn,
          checkOut: b.checkOut,
          adults: b.adults,
          children: b.children,
          rooms: b.rooms,
          status: newStatus,
        );
      }
      return b;
    }).toList();
  }
}

class BookingPage extends ConsumerWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingsProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Bookings',
        showBackButton: true,
        onNotificationPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NotificationsPage()),
          );
        },

      ),
      body: bookings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No bookings yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your bookings will appear here',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return Column(
                  children: [
                    HotelCardModern(
                      hotel: booking.hotel,
                      bookingType: 0,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(booking.status),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  booking.status.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                icon: Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {
                                  ref.read(bookingsProvider.notifier).removeBooking(booking);
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          _buildBookingInfoRow(
                            Icons.calendar_today,
                            'Check-in: ${_formatDate(booking.checkIn)}',
                          ),
                          SizedBox(height: 4),
                          _buildBookingInfoRow(
                            Icons.calendar_today,
                            'Check-out: ${_formatDate(booking.checkOut)}',
                          ),
                          SizedBox(height: 4),
                          _buildBookingInfoRow(
                            Icons.people,
                            '${booking.adults} Adults, ${booking.children} Children, ${booking.rooms} Room${booking.rooms > 1 ? 's' : ''}',
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildBookingInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: WPConfig.primaryColor),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return WPConfig.primaryColor;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 