import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/hotel.dart';
import '../../models/selected_room.dart';
import '../../models/booking.dart';
import '../../core/constants/assets.dart';

class CreateBookingPage extends ConsumerStatefulWidget {
  final Hotel hotel;
  final SelectedRoom selectedRoom;
  final List<SelectedRoom>? selectedRooms;
  final Booking? booking;

  const CreateBookingPage({
    Key? key,
    required this.hotel,
    required this.selectedRoom,
    this.selectedRooms,
    this.booking,
  }) : super(key: key);

  @override
  ConsumerState<CreateBookingPage> createState() => _CreateBookingPageState();
}

class _CreateBookingPageState extends ConsumerState<CreateBookingPage> {
  DateTime? checkInDate;
  DateTime? checkOutDate;
  int adults = 2;
  int children = 0;
  int rooms = 1;
  List<SelectedRoom> allSelectedRooms = [];

  @override
  void initState() {
    super.initState();
    // Set default dates
    checkInDate = DateTime.now().add(Duration(days: 1));
    checkOutDate = DateTime.now().add(Duration(days: 2));

    // Initialize selected rooms list
    allSelectedRooms = widget.selectedRooms ?? [widget.selectedRoom];
    rooms = allSelectedRooms.length;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          'Create Booking',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 24 : 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: isTablet ? 28 : 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel Information Card
            _buildHotelCard(isTablet),
            SizedBox(height: 24),

            // Room Information Card
            _buildRoomCard(isTablet),
            SizedBox(height: 24),

            // Date Selection Card
            _buildDateSelectionCard(isTablet),
            SizedBox(height: 24),

            // Guest Selection Card
            _buildGuestSelectionCard(isTablet),
            SizedBox(height: 24),

            // Price Summary Card
            _buildPriceSummaryCard(isTablet),
            SizedBox(height: 32),

            // Confirm Booking Button
            _buildConfirmButton(isTablet, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelCard(bool isTablet) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            // Hotel Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.hotel.imageUrl ??
                    'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=200&h=150&fit=crop',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: Icon(Icons.hotel, size: 40, color: Colors.grey[600]),
                  );
                },
              ),
            ),
            SizedBox(width: 16),
            // Hotel Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.hotel.name ?? 'Hotel Name',
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  if (widget.hotel.city != null)
                    Text(
                      widget.hotel.city!,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      SizedBox(width: 4),
                      Text(
                        '${widget.hotel.rate ?? 4.5}',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(bool isTablet) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Room',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            // Display all selected rooms
            ...allSelectedRooms
                .map((room) => Container(
                      margin: EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          // Room Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              room.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.bed,
                                      size: 30, color: Colors.grey[600]),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          // Room Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  room.name,
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '\$${room.pricePerNight.toStringAsFixed(2)} per night',
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Max ${room.maxAdults} adults, ${room.maxChildren} children',
                                  style: TextStyle(
                                    fontSize: isTablet ? 12 : 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelectionCard(bool isTablet) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Dates',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    'Check-in',
                    checkInDate,
                    (date) => setState(() => checkInDate = date),
                    isTablet,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    'Check-out',
                    checkOutDate,
                    (date) => setState(() => checkOutDate = date),
                    isTablet,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date,
      Function(DateTime) onDateSelected, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );
            if (selectedDate != null) {
              onDateSelected(selectedDate);
            }
          },
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
                SizedBox(width: 8),
                Text(
                  date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : 'Select Date',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestSelectionCard(bool isTablet) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Guests & Rooms',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12),
            _buildCounterRow('Rooms', rooms,
                (value) => setState(() => rooms = value), isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterRow(
      String label, int value, Function(int) onChanged, bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: value > 1 ? () => onChanged(value - 1) : null,
              icon: Icon(Icons.remove_circle_outline,
                  color: value > 1 ? Colors.blue : Colors.grey),
            ),
            Text(
              '$value',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            IconButton(
              onPressed: () => onChanged(value + 1),
              icon: Icon(Icons.add_circle_outline, color: Colors.blue),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSummaryCard(bool isTablet) {
    final nights = checkOutDate != null && checkInDate != null
        ? checkOutDate!.difference(checkInDate!).inDays
        : 1;
    // Calculate base price from selected rooms, then multiply by room count
    final basePrice =
        allSelectedRooms.fold(0.0, (sum, room) => sum + room.pricePerNight);
    final totalPrice = basePrice * nights * rooms;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Summary',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            // Show breakdown for each room
            ...allSelectedRooms
                .map((room) => Container(
                      margin: EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${room.name}',
                              style: TextStyle(
                                fontSize: isTablet ? 12 : 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Text(
                            '\$${(room.pricePerNight * rooms).toStringAsFixed(2)}/night',
                            style: TextStyle(
                              fontSize: isTablet ? 12 : 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nights',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '$nights',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rooms',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '$rooms',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton(bool isTablet, Color primaryColor) {
    return SizedBox(
      width: double.infinity,
      height: isTablet ? 64 : 56,
      child: ElevatedButton(
        onPressed: () {
          // Handle booking confirmation
          _confirmBooking();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: primaryColor.withOpacity(0.3),
        ),
        child: Text(
          'Confirm Booking',
          style: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _confirmBooking() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking Confirmed!'),
        content: Text('Your booking has been successfully created.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to hotel details
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
