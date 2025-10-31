import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/hotel.dart';

class FavoritesNotifier extends StateNotifier<List<Hotel>> {
  FavoritesNotifier() : super([]);

  Future<void> toggleFavorite(Hotel hotel, BuildContext context) async {
    final isCurrentlyFavorite = state.any((h) => h.id == hotel.id);
    if (isCurrentlyFavorite) {
      removeHotel(hotel);
    } else {
      // Show confirmation dialog before adding to favorites
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('add_to_favorites'.tr()),
          content: Text('add_hotel_to_favorites_confirm'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('add'.tr()),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        addHotel(hotel);
      }
    }
  }

  bool isFavorite(Hotel hotel) {
    return state.any((h) => h.id == hotel.id);
  }

  bool isFavoriteById(String hotelId) {
    return state.any((h) => h.id == hotelId);
  }

  void addHotel(Hotel hotel) {
    if (!state.any((h) => h.id == hotel.id)) {
      state = [...state, hotel];
    }
  }

  void removeHotel(Hotel hotel) {
    state = state.where((h) => h.id != hotel.id).toList();
  }

  void removeFavoriteById(String hotelId) {
    state = state.where((h) => h.id != hotelId).toList();
  }

  void clearFavorites() {
    state = [];
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<Hotel>>((ref) {
  return FavoritesNotifier();
});
