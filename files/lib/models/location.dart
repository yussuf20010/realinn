import 'hotel.dart';

class LocationModel {
  final String? country;
  final String? capital;
  final int? numberOfHotels;
  final String? image;
  final List<Hotel>? hotels;

  LocationModel({
    this.country,
    this.capital,
    this.numberOfHotels,
    this.image,
    this.hotels,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    print('Parsing location: ${json.toString()}');
    
    // Handle the case where the data might be nested under a key
    final Map<String, dynamic> locationData;
    locationData = json;

    return LocationModel(
      country: locationData['country']?.toString(),
      capital: locationData['capital']?.toString(),
      numberOfHotels: locationData['number_of_hotels'] is int 
          ? locationData['number_of_hotels'] 
          : int.tryParse(locationData['number_of_hotels']?.toString() ?? '0'),
      image: locationData['image']?.toString(),
      hotels: locationData['hotels'] is List 
          ? (locationData['hotels'] as List).map((e) {
              if (e is Map<String, dynamic>) {
                return Hotel.fromJson(e, '');
              }
              return null;
            }).whereType<Hotel>().toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'capital': capital,
      'number_of_hotels': numberOfHotels,
      'image': image,
      'hotels': hotels?.map((e) => e.toJson()).toList(),
    };
  }
}