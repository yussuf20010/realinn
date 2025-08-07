import 'hotel.dart';

// Country Model
class Country {
  final int? id;
  final int? languageId;
  final String? name;
  final String? createdAt;
  final String? updatedAt;

  Country({
    this.id,
    this.languageId,
    this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] is int ? json['id'] : (json['id'] is String ? int.tryParse(json['id']) : null),
      languageId: json['language_id'] is int ? json['language_id'] : (json['language_id'] is String ? int.tryParse(json['language_id']) : null),
      name: json['name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'language_id': languageId,
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// State Model
class State {
  final int? id;
  final int? languageId;
  final int? countryId;
  final String? name;
  final String? createdAt;
  final String? updatedAt;

  State({
    this.id,
    this.languageId,
    this.countryId,
    this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory State.fromJson(Map<String, dynamic> json) {
    return State(
      id: json['id'] is int ? json['id'] : (json['id'] is String ? int.tryParse(json['id']) : null),
      languageId: json['language_id'] is int ? json['language_id'] : (json['language_id'] is String ? int.tryParse(json['language_id']) : null),
      countryId: json['country_id'] is int ? json['country_id'] : (json['country_id'] is String ? int.tryParse(json['country_id']) : null),
      name: json['name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'language_id': languageId,
      'country_id': countryId,
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// City Model
class City {
  final int? id;
  final int? languageId;
  final int? countryId;
  final int? stateId;
  final String? featureImage;
  final String? name;
  final String? createdAt;
  final String? updatedAt;

  City({
    this.id,
    this.languageId,
    this.countryId,
    this.stateId,
    this.featureImage,
    this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] is int ? json['id'] : (json['id'] is String ? int.tryParse(json['id']) : null),
      languageId: json['language_id'] is int ? json['language_id'] : (json['language_id'] is String ? int.tryParse(json['language_id']) : null),
      countryId: json['country_id'] is int ? json['country_id'] : (json['country_id'] is String ? int.tryParse(json['country_id']) : null),
      stateId: json['state_id'] is int ? json['state_id'] : (json['state_id'] is String ? int.tryParse(json['state_id']) : null),
      featureImage: json['feature_image'],
      name: json['name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'language_id': languageId,
      'country_id': countryId,
      'state_id': stateId,
      'feature_image': featureImage,
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// Location Response Model (for the entire API response)
class LocationResponse {
  final Map<String, dynamic>? seoInfo;
  final Map<String, dynamic>? currencyInfo;
  final List<Map<String, dynamic>>? categories;
  final List<Map<String, dynamic>>? vendors;
  final List<Country>? countries;
  final List<State>? states;
  final List<City>? cities;
  final List<Map<String, dynamic>>? bookingHours;
  final List<Map<String, dynamic>>? featuredContents;
  final List<Hotel>? hotels;
  final int? total;
  final int? perPage;
  final int? currentPage;

  LocationResponse({
    this.seoInfo,
    this.currencyInfo,
    this.categories,
    this.vendors,
    this.countries,
    this.states,
    this.cities,
    this.bookingHours,
    this.featuredContents,
    this.hotels,
    this.total,
    this.perPage,
    this.currentPage,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    return LocationResponse(
      seoInfo: json['seoInfo'],
      currencyInfo: json['currencyInfo'],
      categories: json['categories'] != null 
          ? List<Map<String, dynamic>>.from(json['categories'])
          : null,
      vendors: json['vendors'] != null 
          ? List<Map<String, dynamic>>.from(json['vendors'])
          : null,
      countries: json['countries'] != null 
          ? (json['countries'] as List).map((e) => Country.fromJson(e)).toList()
          : null,
      states: json['states'] != null 
          ? (json['states'] as List).map((e) => State.fromJson(e)).toList()
          : null,
      cities: json['cities'] != null 
          ? (json['cities'] as List).map((e) => City.fromJson(e)).toList()
          : null,
      bookingHours: json['bookingHours'] != null 
          ? List<Map<String, dynamic>>.from(json['bookingHours'])
          : null,
      featuredContents: json['featured_contents'] != null 
          ? List<Map<String, dynamic>>.from(json['featured_contents'])
          : null,
      hotels: json['hotels'] != null 
          ? (json['hotels'] as List).map((e) => Hotel.fromJson(e, e['id']?.toString() ?? '')).toList()
          : null,
      total: json['total'] is int ? json['total'] : (json['total'] is String ? int.tryParse(json['total']) : null),
      perPage: json['perPage'] is int ? json['perPage'] : (json['perPage'] is String ? int.tryParse(json['perPage']) : null),
      currentPage: json['currentPage'] is int ? json['currentPage'] : (json['currentPage'] is String ? int.tryParse(json['currentPage']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seoInfo': seoInfo,
      'currencyInfo': currencyInfo,
      'categories': categories,
      'vendors': vendors,
      'countries': countries?.map((e) => e.toJson()).toList(),
      'states': states?.map((e) => e.toJson()).toList(),
      'cities': cities?.map((e) => e.toJson()).toList(),
      'bookingHours': bookingHours,
      'featured_contents': featuredContents,
      'hotels': hotels?.map((e) => e.toJson()).toList(),
      'total': total,
      'perPage': perPage,
      'currentPage': currentPage,
    };
  }
}

// Legacy LocationModel for backward compatibility
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