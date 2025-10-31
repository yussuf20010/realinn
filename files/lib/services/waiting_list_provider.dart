import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/selected_room.dart';
import '../models/hotel.dart';

class WaitingListItem {
  final String id;
  final Hotel hotel;
  final SelectedRoom room;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int quantity;
  final DateTime addedAt;
  final String status; // 'pending', 'confirmed', 'cancelled'

  WaitingListItem({
    required this.id,
    required this.hotel,
    required this.room,
    required this.checkInDate,
    required this.checkOutDate,
    required this.quantity,
    required this.addedAt,
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotel': hotel.toJson(),
      'room': room.toJson(),
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
      'status': status,
    };
  }

  factory WaitingListItem.fromJson(Map<String, dynamic> json) {
    return WaitingListItem(
      id: json['id'],
      hotel: Hotel.fromJson(json['hotel'], json['hotel']['id']?.toString() ?? ''),
      room: SelectedRoom.fromJson(json['room']),
      checkInDate: DateTime.parse(json['checkInDate']),
      checkOutDate: DateTime.parse(json['checkOutDate']),
      quantity: json['quantity'],
      addedAt: DateTime.parse(json['addedAt']),
      status: json['status'] ?? 'pending',
    );
  }
}

class WaitingListNotifier extends StateNotifier<List<WaitingListItem>> {
  WaitingListNotifier() : super([]);

  void addToWaitingList({
    required Hotel hotel,
    required SelectedRoom room,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int quantity,
  }) {
    final item = WaitingListItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      hotel: hotel,
      room: room,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      quantity: quantity,
      addedAt: DateTime.now(),
    );

    state = [...state, item];
  }

  void removeFromWaitingList(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void updateStatus(String id, String status) {
    state = state.map((item) {
      if (item.id == id) {
        return WaitingListItem(
          id: item.id,
          hotel: item.hotel,
          room: item.room,
          checkInDate: item.checkInDate,
          checkOutDate: item.checkOutDate,
          quantity: item.quantity,
          addedAt: item.addedAt,
          status: status,
        );
      }
      return item;
    }).toList();
  }

  void clearWaitingList() {
    state = [];
  }

  List<WaitingListItem> getPendingItems() {
    return state.where((item) => item.status == 'pending').toList();
  }

  List<WaitingListItem> getConfirmedItems() {
    return state.where((item) => item.status == 'confirmed').toList();
  }
}

final waitingListProvider = StateNotifierProvider<WaitingListNotifier, List<WaitingListItem>>((ref) {
  return WaitingListNotifier();
});
