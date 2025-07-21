import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/wp_config.dart';
import '../../models/hotel.dart';
import '../../widgets/CustomBottomNavBar.dart';
import '../hotel_details/hotel_details_page.dart';
import '../home/home_page.dart';
import '../favorites/favorites_page.dart';
import '../profile/profile_page.dart';

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
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HotelDetailsPage(hotel: booking.hotel),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.network(
                                booking.hotel.imageUrl ?? '',
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: Icon(Icons.hotel, size: 64, color: Colors.grey[400]),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
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
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      booking.hotel.name ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () {
                                      ref.read(bookingsProvider.notifier).removeBooking(booking);
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                booking.hotel.location ?? '',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 16),
                              _buildBookingInfoRow(
                                Icons.calendar_today,
                                'Check-in: ${_formatDate(booking.checkIn)}',
                              ),
                              SizedBox(height: 8),
                              _buildBookingInfoRow(
                                Icons.calendar_today,
                                'Check-out: ${_formatDate(booking.checkOut)}',
                              ),
                              SizedBox(height: 8),
                              _buildBookingInfoRow(
                                Icons.people,
                                '${booking.adults} Adults, ${booking.children} Children, ${booking.rooms} Room${booking.rooms > 1 ? 's' : ''}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
              break;
            case 1:
              // Already on BookingPage
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