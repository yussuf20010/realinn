import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../controllers/location_controller.dart';
import '../../../../models/location.dart' as location_model;

class LocationFilterModal extends ConsumerStatefulWidget {
  @override
  ConsumerState<LocationFilterModal> createState() => _LocationFilterModalState();
}

class _LocationFilterModalState extends ConsumerState<LocationFilterModal> {
  List<String> selected = [];
  String? selectedCountry;
  List<String> selectedCities = [];
  
  @override
  Widget build(BuildContext context) {
    final locationResponseAsync = ref.watch(locationProvider);
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (selectedCountry != null)
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => setState(() {
                      selectedCountry = null;
                      selectedCities.clear();
                    }),
                  ),
                Expanded(
                  child: Text(
                    selectedCountry != null ? 'Select Cities in $selectedCountry' : 'Filter by Location',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            locationResponseAsync.when(
              data: (locationResponse) {
                final countries = locationResponse.countries ?? [];
                final cities = locationResponse.cities ?? [];
                final hotels = locationResponse.hotels ?? [];
                
                // Debug prints
                print('Loaded data:');
                print('- Countries: ${countries.length}');
                print('- Cities: ${cities.length}');
                print('- Hotels: ${hotels.length}');
                
                if (countries.isNotEmpty) {
                  print('Sample country: ${countries.first.toJson()}');
                }
                if (cities.isNotEmpty) {
                  print('Sample city: ${cities.first.toJson()}');
                }
                if (hotels.isNotEmpty) {
                  print('Sample hotel: ${hotels.first.toJson()}');
                  print('Hotel fields:');
                  print('- countryId: ${hotels.first.countryId}');
                  print('- stateId: ${hotels.first.stateId}');
                  print('- cityId: ${hotels.first.cityId}');
                  print('- country: ${hotels.first.country}');
                  print('- state: ${hotels.first.state}');
                  print('- city: ${hotels.first.city}');
                }
                
                if (selectedCountry != null) {
                  // Show cities for selected country
                  final selectedCountryObj = countries.firstWhere(
                    (c) => c.name == selectedCountry,
                    orElse: () => location_model.Country(),
                  );
                  print('Selected country: ${selectedCountryObj.toJson()}');
                  
                  final countryCities = cities.where((city) {
                    print('Checking city: ${city.name} (countryId: ${city.countryId}) against selected country ID: ${selectedCountryObj.id}');
                    // Try exact match first
                    if (city.countryId == selectedCountryObj.id) return true;
                    // Fallback to name matching if IDs don't match
                    if (city.name != null && selectedCountryObj.name != null) {
                      // This is a fallback - cities don't typically have country names, but we can check
                      return false; // Skip this fallback for cities
                    }
                    return false;
                  }).toList();
                  
                  print('Found ${countryCities.length} cities for country ${selectedCountry}');
                  
                  return Expanded(
                    child: Column(
                      children: [
                        // Show selected country
                        Container(
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'Country: $selectedCountry',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: countryCities.length,
                            itemBuilder: (context, index) {
                              final city = countryCities[index];
                              final hotelCount = hotels.where((hotel) {
                                // Debug print to see the values
                                print('Comparing hotel.cityId: ${hotel.cityId} (${hotel.cityId.runtimeType}) with city.id: ${city.id} (${city.id.runtimeType})');
                                // Try exact match first
                                if (hotel.cityId == city.id) return true;
                                // Fallback to name matching if IDs don't match
                                if (hotel.city != null && city.name != null) {
                                  return hotel.city!.toLowerCase() == city.name!.toLowerCase();
                                }
                                return false;
                              }).length;
                              
                              final isSelected = selectedCities.contains(city.name ?? '');
                              return ListTile(
                                leading: Icon(Icons.location_city, color: Colors.black),
                                title: Text(city.name ?? ''),
                                subtitle: Text('$hotelCount hotels'),
                                trailing: isSelected
                                  ? Icon(Icons.check_box, color: Theme.of(context).primaryColor)
                                  : Icon(Icons.check_box_outline_blank),
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      selectedCities.remove(city.name ?? '');
                                    } else {
                                      selectedCities.add(city.name ?? '');
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Show countries
                  return Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: countries.length,
                      itemBuilder: (context, index) {
                        final country = countries[index];
                        final hotelCount = hotels.where((hotel) {
                          // Debug print to see the values
                          print('Comparing hotel.countryId: ${hotel.countryId} (${hotel.countryId.runtimeType}) with country.id: ${country.id} (${country.id.runtimeType})');
                          // Try exact match first
                          if (hotel.countryId == country.id) return true;
                          // Fallback to name matching if IDs don't match
                          if (hotel.country != null && country.name != null) {
                            return hotel.country!.toLowerCase() == country.name!.toLowerCase();
                          }
                          return false;
                        }).length;
                        
                        return ListTile(
                          leading: Icon(Icons.location_on, color: Colors.black),
                          title: Text(country.name ?? ''),
                          subtitle: Text('$hotelCount hotels'),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            setState(() {
                              selectedCountry = country.name;
                            });
                          },
                        );
                      },
                    ),
                  );
                }
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (e, _) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error loading locations: $e'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(locationProvider),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                    ),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final selectedLocations = selectedCountry != null 
                          ? selectedCities 
                          : selected;
                      Navigator.pop(context, selectedLocations);
                    },
                    child: Text('Apply Filter'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

