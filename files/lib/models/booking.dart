import 'hotel.dart';
import 'selected_room.dart';

class Booking {
  final String id;
  final Hotel hotel;
  final SelectedRoom selectedRoom;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int adults;
  final int children;
  final double totalPrice;
  final BookingStatus status;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.hotel,
    required this.selectedRoom,
    required this.checkInDate,
    required this.checkOutDate,
    required this.adults,
    required this.children,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  // Convenience constructor with defaults
  factory Booking.create({
    required Hotel hotel,
    required SelectedRoom selectedRoom,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int adults = 2,
    int children = 0,
  }) {
    final now = DateTime.now();
    final defaultCheckIn = checkInDate ?? now.add(Duration(days: 1));
    final defaultCheckOut = checkOutDate ?? now.add(Duration(days: 2));
    final nights = defaultCheckOut.difference(defaultCheckIn).inDays;
    final totalPrice = selectedRoom.pricePerNight * nights;

    return Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      hotel: hotel,
      selectedRoom: selectedRoom,
      checkInDate: defaultCheckIn,
      checkOutDate: defaultCheckOut,
      adults: adults,
      children: children,
      totalPrice: totalPrice,
      status: BookingStatus.confirmed,
      createdAt: now,
    );
  }

  int get nights => checkOutDate.difference(checkInDate).inDays;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotel': hotel.toJson(),
      'selectedRoom': selectedRoom.toJson(),
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'adults': adults,
      'children': children,
      'totalPrice': totalPrice,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      hotel: Hotel.fromJson(json['hotel'] as Map<String, dynamic>, json['hotel']['id'] as String? ?? ''),
      selectedRoom: SelectedRoom.fromJson(json['selectedRoom'] as Map<String, dynamic>),
      checkInDate: DateTime.parse(json['checkInDate'] as String),
      checkOutDate: DateTime.parse(json['checkOutDate'] as String),
      adults: json['adults'] as int,
      children: json['children'] as int,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => BookingStatus.confirmed,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Booking copyWith({
    String? id,
    Hotel? hotel,
    SelectedRoom? selectedRoom,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? adults,
    int? children,
    double? totalPrice,
    BookingStatus? status,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      hotel: hotel ?? this.hotel,
      selectedRoom: selectedRoom ?? this.selectedRoom,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Booking(id: $id, hotel: ${hotel.name}, room: ${selectedRoom.name}, checkIn: $checkInDate, checkOut: $checkOutDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Booking && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
}
