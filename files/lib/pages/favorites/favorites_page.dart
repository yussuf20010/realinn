import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/hotel.dart';
import '../../widgets/custom_app_bar.dart';
import '../hotel_details/hotel_details_page.dart';
import '../notifications/notifications_page.dart';
import '../settings/pages/customer_support_page.dart';
import '../../widgets/vertical_hotel_card.dart';

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<Hotel>>((ref) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<List<Hotel>> {
  FavoritesNotifier() : super([]);

  void addHotel(Hotel hotel) {
    if (!state.contains(hotel)) {
      state = [...state, hotel];
    }
  }

  void removeHotel(Hotel hotel) {
    state = state.where((h) => h.id != hotel.id).toList();
  }

  bool isFavorite(Hotel hotel) {
    return state.any((h) => h.id == hotel.id);
  }
}

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Favorites',
        showBackButton: true,
        onNotificationPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NotificationsPage()),
          );
        },

      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add hotels to your favorites to see them here',
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
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final hotel = favorites[index];
                return VerticalHotelCard(
                  hotel: hotel,
                  onRemove: () => ref.read(favoritesProvider.notifier).removeHotel(hotel),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HotelDetailsPage(hotel: hotel),
                      ),
                    );
                  },
                  isFavorite: true,
                );
              },
            ),
    );
  }
}