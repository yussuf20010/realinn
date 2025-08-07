import 'package:flutter_riverpod/flutter_riverpod.dart';

// Booking type provider (0: daily, 1: monthly)
final selectedBookingTypeProvider = StateProvider<int>((ref) => 0);

// Selected locations provider for filtering
final selectedLocationsProvider = StateProvider<List<String>>((ref) => []);

