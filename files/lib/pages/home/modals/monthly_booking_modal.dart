import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../controllers/hotel_controller.dart';
import '../../../../controllers/location_controller.dart';
import '../../../../models/hotel.dart';
import '../../../../models/location.dart' as location_model;
import '../../../../config/dynamic_config.dart';
import '../../booking/booking_page.dart';
import '../../../config/wp_config.dart';
import '../../../core/utils/app_utils.dart';
import '../components/hotels_list.dart';

class MonthlyBookingModal extends ConsumerStatefulWidget {
  @override
  ConsumerState<MonthlyBookingModal> createState() => _MonthlyBookingModalState();
}

class _MonthlyBookingModalState extends ConsumerState<MonthlyBookingModal> {
  int currentStep = 0;
  DateTime? startDate;
  DateTime? endDate;
  String? selectedCountry;
  String? selectedCity;
  String? selectedHotel;
  String locationSearchQuery = '';
  int selectedRoomIndex = 0;
  final List<Map<String, dynamic>> roomOptions = const [
    {
      'name': 'Studio',
      'price': 70.0,
      'maxAdults': 2,
      'maxChildren': 1,
      'amenities': ['WiFi', 'Kitchenette']
    },
    {
      'name': 'One-Bedroom Suite',
      'price': 95.0,
      'maxAdults': 3,
      'maxChildren': 2,
      'amenities': ['WiFi', 'Kitchen', 'Washer']
    },
    {
      'name': 'Two-Bedroom Apartment',
      'price': 140.0,
      'maxAdults': 4,
      'maxChildren': 3,
      'amenities': ['WiFi', 'Full Kitchen', 'Balcony']
    },
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = ref.watch(dynamicConfigProvider).primaryColor;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Text(
                  'Monthly Booking',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Progress indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: List.generate(5, (index) => Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: index <= currentStep ? primaryColor : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              )),
            ),
          ),
          
          // Content
          Flexible(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: _buildStepContent(),
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                if (currentStep > 0)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => currentStep--),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                      ),
                      child: Text('Back'),
                    ),
                  ),
                if (currentStep > 0) SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canProceed() ? _nextStep : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(currentStep == 4 ? 'Finish' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case 0:
        return _buildDateStep();
      case 1:
        return _buildCountryStep();
      case 2:
        return _buildCityStep();
      case 3:
        return _buildHotelStep();
      case 4:
        return _buildRoomStep();
      default:
        return Container();
    }
  }

  Widget _buildDateStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Dates',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        SizedBox(height: 12),
        ListTile(
          leading: Icon(Icons.calendar_today, color: Colors.black),
          title: Text('Start Date', style: TextStyle(color: Colors.black)),
          subtitle: Text(startDate?.toString().split(' ')[0] ?? 'Select start date', style: TextStyle(color: Colors.black)),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );
            if (date != null) {
              setState(() => startDate = date);
            }
          },
        ),
        ListTile(
          leading: Icon(Icons.calendar_today, color: Colors.black),
          title: Text('End Date', style: TextStyle(color: Colors.black)),
          subtitle: Text(endDate?.toString().split(' ')[0] ?? 'Select end date', style: TextStyle(color: Colors.black)),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: startDate ?? DateTime.now(),
              firstDate: startDate ?? DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );
            if (date != null) {
              setState(() => endDate = date);
            }
          },
        ),
      ],
    );
  }

  Widget _buildCountryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Country',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        SizedBox(height: 12),
        // Search field
        TextField(
          decoration: InputDecoration(
            hintText: 'Search for countries...',
            prefixIcon: Icon(Icons.search, color: Colors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) => setState(() => locationSearchQuery = value.toLowerCase()),
        ),
        SizedBox(height: 12),
        Flexible(
          child: Consumer(
            builder: (context, ref, child) {
              final locationResponseAsync = ref.watch(locationProvider);
              return locationResponseAsync.when(
                data: (locationResponse) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Show All Hotels option
                    ListTile(
                      leading: Icon(Icons.hotel, color: Colors.black),
                      title: Text('Show All Hotels', style: TextStyle(color: Colors.black)),
                      subtitle: Text('Skip location filtering'),
                      selected: selectedCountry == null,
                      selectedTileColor: selectedCountry == null ? Colors.blue.withOpacity(0.15) : Colors.grey[100],
                      onTap: () => setState(() => selectedCountry = null),
                    ),
                    Divider(),
                    // Countries list
                    if (locationResponse.countries?.isNotEmpty == true) ...[
                      Text(
                        'Countries',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 8),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: locationResponse.countries!.length,
                          itemBuilder: (context, index) {
                            final country = locationResponse.countries![index];
                            final countryName = country.name ?? '';
                            if (locationSearchQuery.isNotEmpty && 
                                !countryName.toLowerCase().contains(locationSearchQuery)) {
                              return SizedBox.shrink();
                            }
                            
                            // Count hotels in this country
                            final hotelCount = locationResponse.hotels?.where((hotel) => 
                              hotel.countryId == country.id
                            ).length ?? 0;
                            
                            return ListTile(
                              leading: Icon(Icons.location_on, color: Colors.black),
                              title: Text(countryName, style: TextStyle(color: Colors.black)),
                              subtitle: Text('Country'),
                              trailing: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.hotel, size: 14, color: Colors.blue),
                                    SizedBox(width: 4),
                                    Text(
                                      '$hotelCount',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              selected: selectedCountry == countryName,
                              selectedTileColor: selectedCountry == countryName ? Colors.blue.withOpacity(0.15) : Colors.grey[100],
                              onTap: () => setState(() => selectedCountry = countryName),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
                loading: () => Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error loading countries', style: TextStyle(color: Colors.black)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select City',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        if (selectedCountry != null)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Cities in $selectedCountry',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        SizedBox(height: 12),
        // Search field
        TextField(
          decoration: InputDecoration( 
            hintText: 'Search for cities...',
            prefixIcon: Icon(Icons.search, color: Colors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) => setState(() => locationSearchQuery = value.toLowerCase()),
        ),
        SizedBox(height: 12),
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final locationResponseAsync = ref.watch(locationProvider);
              return locationResponseAsync.when(
                data: (locationResponse) {
                  // Find the selected country ID
                  final selectedCountryId = locationResponse.countries
                      ?.firstWhere((c) => c.name == selectedCountry, orElse: () => location_model.Country())
                      .id;
                  
                  // Filter cities by selected country
                  final citiesInCountry = locationResponse.cities
                      ?.where((city) => city.countryId == selectedCountryId)
                      .toList() ?? [];
                  
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Show All Hotels option
                      ListTile(
                        leading: Icon(Icons.hotel, color: Colors.black),
                        title: Text('Show All Hotels', style: TextStyle(color: Colors.black)),
                        subtitle: Text('Skip location filtering'),
                        selected: selectedCity == null,
                        selectedTileColor: selectedCity == null ? Colors.blue.withOpacity(0.15) : Colors.grey[100],
                        onTap: () => setState(() => selectedCity = null),
                      ),
                      Divider(),
                      // Cities list
                      if (citiesInCountry.isNotEmpty) ...[
                        Text(
                          'Cities in $selectedCountry',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        SizedBox(height: 8),
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: citiesInCountry.length,
                            itemBuilder: (context, index) {
                              final city = citiesInCountry[index];
                              final cityName = city.name ?? '';
                              if (locationSearchQuery.isNotEmpty && 
                                  !cityName.toLowerCase().contains(locationSearchQuery)) {
                                return SizedBox.shrink();
                              }
                              
                              // Count hotels in this city
                              final hotelCount = locationResponse.hotels?.where((hotel) => 
                                hotel.cityId == city.id
                              ).length ?? 0;
                              
                              return ListTile(
                                leading: Icon(Icons.location_city, color: Colors.black),
                                title: Text(cityName, style: TextStyle(color: Colors.black)),
                                subtitle: Text('City'),
                                trailing: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.hotel, size: 14, color: Colors.blue),
                                      SizedBox(width: 4),
                                      Text(
                                        '$hotelCount',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                selected: selectedCity == cityName,
                                selectedTileColor: selectedCity == cityName ? Colors.blue.withOpacity(0.15) : Colors.grey[100],
                                onTap: () => setState(() => selectedCity = cityName),
                              );
                            },
                          ),
                        ),
                      ] else ...[
                        Flexible(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_city_outlined, size: 64, color: Colors.grey[400]),
                                SizedBox(height: 12),
                                Text(
                                  'No cities found in $selectedCountry',
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Try selecting a different country',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
                loading: () => Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error loading cities', style: TextStyle(color: Colors.black)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHotelStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Hotel',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        if (selectedCity != null)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Hotels in $selectedCity',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        SizedBox(height: 12),
        Flexible(
          child: Consumer(
            builder: (context, ref, child) {
              final hotelsAsync = ref.watch(hotelProvider);
              return hotelsAsync.when(
                data: (hotels) {
                  // Filter hotels based on selected location using helper function
                  final filteredHotels = _filterHotelsForMonthlyBooking(hotels, selectedCity, ref);
                  
                  if (filteredHotels.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.hotel_outlined, size: 64, color: Colors.grey[400]),
                          SizedBox(height: 12),
                          Text(
                            selectedCity != null 
                                ? 'No hotels found in $selectedCity'
                                : 'No hotels available',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Total hotels loaded: ${hotels.length}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          ),
                          if (selectedCity != null) ...[
                            SizedBox(height: 8),
                            Text(
                              'Try selecting a different city or check if hotels have location data',
                              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                            ),
                            SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => setState(() => selectedCity = null),
                              child: Text('Show All Hotels'),
                            ),
                          ],
                        ],
                      ),
                    );
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary header
                      Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedCity != null 
                                    ? 'Found ${filteredHotels.length} hotels in "$selectedCity"'
                                    : 'Showing all ${filteredHotels.length} hotels',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredHotels.length,
                          itemBuilder: (context, index) {
                            final hotel = filteredHotels[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[200],
                                child: hotel.imageUrl != null && hotel.imageUrl!.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          hotel.imageUrl!,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Icon(
                                            Icons.hotel,
                                            color: Colors.black,
                                            size: 20,
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.hotel,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                              ),
                              title: Text(hotel.name ?? '', style: TextStyle(color: Colors.white)),
                              subtitle: Text(hotel.city ?? hotel.country ?? hotel.category ?? hotel.location ?? '', style: TextStyle(color: Colors.black)),
                              selected: selectedHotel == hotel.name,
                              selectedTileColor: Colors.grey[100],
                              onTap: () => setState(() => selectedHotel = hotel.name),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error loading hotels', style: TextStyle(color: Colors.black)),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _canProceed() {
    switch (currentStep) {
      case 0:
        return startDate != null && endDate != null;
      case 1:
        return selectedCountry != null;
      case 2:
        return selectedCity != null;
      case 3:
        return selectedHotel != null;
      case 4:
        return true; // default selection exists
      default:
        return false;
    }
  }

  void _nextStep() {
    if (currentStep < 4) {
      setState(() => currentStep++);
    } else {
      // Create booking and add to booking page
      _createBooking();
    }
  }

  void _createBooking() {
    // Find the selected hotel
    final hotelsAsync = ref.read(hotelProvider);
    hotelsAsync.whenData((hotels) {
      final selectedHotelData = hotels.firstWhere(
        (hotel) => hotel.name == selectedHotel,
        orElse: () => hotels.first,
      );

      // Prepare selected room from options
      final int seed = (selectedHotelData.id?.hashCode ?? selectedHotelData.name?.hashCode ?? 0).abs();
      final selectedRoom = roomOptions[selectedRoomIndex];
      final booking = Booking(
        hotel: selectedHotelData,
        selectedRoom: SelectedRoom(
          name: selectedRoom['name'] as String,
          pricePerNight: selectedRoom['price'] as double,
          maxAdults: selectedRoom['maxAdults'] as int,
          maxChildren: selectedRoom['maxChildren'] as int,
          imageUrl: 'https://source.unsplash.com/featured/?hotel,monthly&sig=${seed + 21 + selectedRoomIndex}',
          amenities: List<String>.from(selectedRoom['amenities'] as List),
        ),
        checkIn: startDate!,
        checkOut: endDate!,
        adults: 1,
        children: 0,
        rooms: 1,
        status: 'upcoming',
      );

      // Add booking to provider
      ref.read(bookingsProvider.notifier).addBooking(booking);

      // Show success message and navigate to booking page
      Navigator.pop(context);
      AppUtil.showSafeSnackBar(
        context,
        message: 'Monthly booking added successfully!',
        backgroundColor: WPConfig.navbarColor,
        actionLabel: 'View Bookings',
        onActionPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BookingPage()),
          );
        },
      );
    });
  }

  // Helper function for Monthly booking modal
  List<Hotel> _filterHotelsForMonthlyBooking(List<Hotel> hotels, String? selectedCity, WidgetRef ref) {
    if (selectedCity == null) return hotels;
    
    print('Monthly Booking - Total hotels before filtering: ${hotels.length}');
    print('Monthly Booking - Selected city: $selectedCity');
    
    return hotels.where((hotel) {
      // Get city ID from location data
      final locationResponse = ref.read(locationProvider).value;
      final selectedCityData = locationResponse?.cities
          ?.firstWhere((c) => c.name == selectedCity, orElse: () => location_model.City());
      final selectedCityId = selectedCityData?.id;
      
      print('Monthly Booking - Filtering hotel: ${hotel.name}');
      print('Monthly Booking - Hotel city_id: ${hotel.cityId}'); 
      print('Monthly Booking - Selected city_id: $selectedCityId');
      
      // Match by city_id first, then fallback to name matching
      final matches = (hotel.cityId == selectedCityId) ||
                     (hotel.city?.toLowerCase().trim() == selectedCity.toLowerCase().trim());
      
      print('Monthly Booking - Hotel ${hotel.name} matches: $matches');
      return matches;
    }).toList();
  }

  Widget _buildRoomStep() {
    final primaryColor = ref.watch(dynamicConfigProvider).primaryColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Room',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        SizedBox(height: 12),
        ...List.generate(roomOptions.length, (index) {
          final option = roomOptions[index];
          final isSelected = index == selectedRoomIndex;
          return Container(
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor.withOpacity(0.06) : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? primaryColor : Colors.grey[300]!),
            ),
            child: RadioListTile<int>(
              value: index,
              groupValue: selectedRoomIndex,
              onChanged: (v) => setState(() => selectedRoomIndex = v ?? 0),
              activeColor: primaryColor,
              title: Text(option['name'] as String, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    'USD ${(option['price'] as double).toStringAsFixed(0)} / night',
                    style: TextStyle(color: Colors.black87),
                  ),
                  SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: -6,
                    children: List<Widget>.from(
                      (option['amenities'] as List).map((a) => Chip(
                        label: Text(a, style: TextStyle(fontSize: 10)),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )),
                    ),
                  ),
                ],
              ),
            ),
          );
        })
      ],
    );
  }
}

