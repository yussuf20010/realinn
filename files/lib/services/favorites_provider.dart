import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/hotel.dart';
import 'favorites_service.dart';
import 'token_storage_service.dart';

class FavoritesNotifier extends StateNotifier<List<Hotel>> {
  FavoritesNotifier() : super([]);

  Future<void> toggleFavorite(Hotel hotel, BuildContext context) async {
    final isCurrentlyFavorite = state.any((h) => h.id == hotel.id);
    if (isCurrentlyFavorite) {
      await removeHotel(hotel, context);
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
        await addHotel(hotel, context);
      }
    }
  }

  bool isFavorite(Hotel hotel) {
    return state.any((h) => h.id == hotel.id);
  }

  bool isFavoriteById(String hotelId) {
    return state.any((h) => h.id == hotelId);
  }

  Future<void> addHotel(Hotel hotel, BuildContext context) async {
    // Check if user is logged in
    final isLoggedIn = await TokenStorageService.isLoggedIn();
    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('login_is_needed'.tr())),
      );
      return;
    }

    try {
      // Parse hotel ID (could be string or int)
      final hotelId = int.tryParse(hotel.id ?? '0');
      if (hotelId == null || hotelId == 0) {
        throw Exception('Invalid hotel ID');
      }

      // Call API to add to wishlist
      await FavoritesService.addHotelToWishlist(hotelId);

      // Update local state
      if (!state.any((h) => h.id == hotel.id)) {
        state = [...state, hotel];
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('added_to_favorites'.tr())),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> removeHotel(Hotel hotel, BuildContext context) async {
    // Update local state immediately for better UX
    state = state.where((h) => h.id != hotel.id).toList();
    
    // Note: If API supports removing from wishlist, add that call here
    // For now, we just update local state
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('removed_from_favorites'.tr())),
    );
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
