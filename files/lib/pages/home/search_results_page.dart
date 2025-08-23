import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/hotel_controller.dart';
import '../../controllers/location_controller.dart';
import '../../models/hotel.dart';
import '../../config/dynamic_config.dart';
import 'components/hotel_card.dart';
import 'providers/home_providers.dart';
import '../../config/wp_config.dart';
import '../../models/location.dart' as location_model;
import '../../widgets/custom_app_bar.dart';

class SearchResultsPage extends ConsumerWidget {
  final String query;
  final int adults;
  final int children;
  final int rooms;
  final DateTimeRange? dateRange;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;

  const SearchResultsPage({
    Key? key,
    required this.query,
    required this.adults,
    required this.children,
    required this.rooms,
    this.dateRange,
    this.startTime,
    this.endTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = WPConfig.navbarColor;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'search'.tr(),
        showBackButton: true,
        onNotificationPressed: null,
      ),
      body: Column(
        children: [
          // Summary chips
          _SearchSummaryChips(query: query, adults: adults, children: children, rooms: rooms, dateRange: dateRange),
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final hotelsAsync = ref.watch(hotelProvider);
                final locationsAsync = ref.watch(locationProvider);

                return hotelsAsync.when(
                  data: (hotels) {
                    // Prepare location maps if available
                    final locationData = locationsAsync.value;
                    final countries = locationData?.countries ?? [];
                    final cities = locationData?.cities ?? [];
                    final states = locationData?.states ?? [];

                    // normalize hotels with readable names
                    final normalized = hotels.map((hotel) {
                      String? countryName = hotel.country;
                      String? cityName = hotel.city;
                      String? stateName = hotel.state;

                      if (hotel.countryId != null) {
                        final country = countries.firstWhere(
                          (c) => c.id == hotel.countryId,
                          orElse: () => location_model.Country(),
                        );
                        countryName = country.name ?? countryName;
                      }
                      if (hotel.cityId != null) {
                        final city = cities.firstWhere(
                          (c) => c.id == hotel.cityId,
                          orElse: () => location_model.City(),
                        );
                        cityName = city.name ?? cityName;
                      }
                      if (hotel.stateId != null) {
                        final state = states.firstWhere(
                          (s) => s.id == hotel.stateId,
                          orElse: () => location_model.State(),
                        );
                        stateName = state.name ?? stateName;
                      }

                      return Hotel(
                        id: hotel.id,
                        name: hotel.name,
                        location: hotel.location,
                        imageUrl: hotel.imageUrl,
                        rate: hotel.rate,
                        isOccupied: hotel.isOccupied,
                        description: hotel.description,
                        facilities: hotel.facilities,
                        roomTypes: hotel.roomTypes,
                        checkInTime: hotel.checkInTime,
                        checkOutTime: hotel.checkOutTime,
                        priceRange: hotel.priceRange,
                        contact: hotel.contact,
                        reviews: hotel.reviews,
                        locationCoordinates: hotel.locationCoordinates,
                        bookingUrl: hotel.bookingUrl,
                        images: hotel.images,
                        category: hotel.category,
                        nearbyAttractions: hotel.nearbyAttractions,
                        availableDates: hotel.availableDates,
                        country: countryName,
                        state: stateName,
                        city: cityName,
                        countryId: hotel.countryId,
                        stateId: hotel.stateId,
                        cityId: hotel.cityId,
                        slug: hotel.slug,
                        stars: hotel.stars,
                        categorySlug: hotel.categorySlug,
                        latitude: hotel.latitude,
                        longitude: hotel.longitude,
                      );
                    }).toList();

                    final q = query.trim().toLowerCase();
                    final List<Hotel> results = normalized.where((hotel) {
                      final name = (hotel.name ?? '').toLowerCase();
                      final category = (hotel.category ?? '').toLowerCase();
                      final country = (hotel.country ?? '').toLowerCase();
                      final city = (hotel.city ?? '').toLowerCase();
                      final state = (hotel.state ?? '').toLowerCase();
                      final loc = (hotel.location ?? '').toLowerCase();
                      return name.contains(q) || category.contains(q) || country.contains(q) || city.contains(q) || state.contains(q) || loc.contains(q);
                    }).toList();

                    if (results.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text('no_hotels_found'.tr(), style: const TextStyle(color: Colors.black)),
                        ),
                      );
                    }

                    final bookingType = ref.watch(selectedBookingTypeProvider);
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      itemCount: results.length,
                      itemBuilder: (_, index) => HotelCard(
                        hotel: results[index],
                        city: null,
                        country: null,
                        onFavoriteTap: null,
                        isFavorite: false,
                      ),
                    );
                  },
                  loading: () => Center(child: CircularProgressIndicator(color: primaryColor)),
                  error: (e, _) => Center(child: Text('error_loading_hotels'.tr())),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchSummaryChips extends StatelessWidget {
  final String query;
  final int adults;
  final int children;
  final int rooms;
  final DateTimeRange? dateRange;

  const _SearchSummaryChips({
    Key? key,
    required this.query,
    required this.adults,
    required this.children,
    required this.rooms,
    this.dateRange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    if (query.isNotEmpty) {
      chips.add(_chip(Icons.search, query));
    }
    if (dateRange != null) {
      final start = DateFormat('yMMMd').format(dateRange!.start);
      final end = DateFormat('yMMMd').format(dateRange!.end);
      chips.add(_chip(Icons.calendar_today, '$start - $end'));
    }
    chips.add(_chip(Icons.person, '${adults} ${'adults'.tr()}${children > 0 ? ' · ${children} ${'children'.tr()}' : ''}'));
    chips.add(_chip(Icons.meeting_room, '${rooms} ${'rooms'.tr()}'));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(children: chips.map((w) => Padding(padding: const EdgeInsets.only(right: 8), child: w)).toList()),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 14)),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
    );
  }
}


