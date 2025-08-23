import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';
import '../models/hotel.dart';
import '../models/selected_room.dart';

class BookingsNotifier extends StateNotifier<List<Booking>> {
  BookingsNotifier() : super([]);

  void addBooking(Booking booking) {
    state = [...state, booking];
  }

  void removeBooking(String bookingId) {
    state = state.where((booking) => booking.id != bookingId).toList();
  }

  void updateBooking(Booking updatedBooking) {
    state = state.map((booking) {
      return booking.id == updatedBooking.id ? updatedBooking : booking;
    }).toList();
  }

  void cancelBooking(String bookingId) {
    state = state.map((booking) {
      return booking.id == bookingId 
          ? booking.copyWith(status: BookingStatus.cancelled)
          : booking;
    }).toList();
  }

  void completeBooking(String bookingId) {
    state = state.map((booking) {
      return booking.id == bookingId 
          ? booking.copyWith(status: BookingStatus.completed)
          : booking;
    }).toList();
  }

  void clearBookings() {
    state = [];
  }

  List<Booking> getBookingsByStatus(BookingStatus status) {
    return state.where((booking) => booking.status == status).toList();
  }

  List<Booking> getActiveBookings() {
    return state.where((booking) => 
        booking.status == BookingStatus.confirmed || 
        booking.status == BookingStatus.pending
    ).toList();
  }

  double getTotalSpent() {
    return state
        .where((booking) => 
            booking.status == BookingStatus.completed || 
            booking.status == BookingStatus.confirmed
        )
        .fold(0.0, (total, booking) => total + booking.totalPrice);
  }

  int getBookingCount() {
    return state.length;
  }

  Booking? getBookingById(String bookingId) {
    try {
      return state.firstWhere((booking) => booking.id == bookingId);
    } catch (e) {
      return null;
    }
  }
}

final bookingsProvider = StateNotifierProvider<BookingsNotifier, List<Booking>>((ref) {
  return BookingsNotifier();
});
