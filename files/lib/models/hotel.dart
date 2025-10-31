import '../config/wp_config.dart';

class Hotel {
  final String? id;
  final String? name;
  final String? location;
  final String? imageUrl;
  final double? rate;
  final bool? isOccupied;
  final String? description;
  final List<String>? facilities;
  final List<String>? roomTypes;
  final String? checkInTime;
  final String? checkOutTime;
  final String? priceRange;
  final Map<String, String>? contact;
  final List<HotelReview>? reviews;
  final Map<String, double>? locationCoordinates;
  final String? bookingUrl;
  final List<String>? images;
  final String? category;
  final List<String>? nearbyAttractions;
  final List<String>? availableDates;

  // New location fields
  final String? country;
  final String? state;
  final String? city;
  final int? countryId;
  final int? stateId;
  final int? cityId;

  // Additional fields from API
  final String? slug;
  final int? stars;
  final String? categorySlug;
  final double? latitude;
  final double? longitude;
  final String? oldPrice;
  final String? dealLabel;

  Hotel({
    this.id,
    this.name,
    this.location,
    this.imageUrl,
    this.rate,
    this.isOccupied,
    this.description,
    this.facilities,
    this.roomTypes,
    this.checkInTime,
    this.checkOutTime,
    this.priceRange,
    this.contact,
    this.reviews,
    this.locationCoordinates,
    this.bookingUrl,
    this.images,
    this.category,
    this.nearbyAttractions,
    this.availableDates,
    this.country,
    this.state,
    this.city,
    this.countryId,
    this.stateId,
    this.cityId,
    this.slug,
    this.stars,
    this.categorySlug,
    this.latitude,
    this.longitude,
    this.oldPrice,
    this.dealLabel,
  });

  factory Hotel.fromJson(Map<String, dynamic> json, String id) {
    // Handle image URL
    String? imageUrl = json['image_url'] ?? json['logo'] ?? json['image'];
    if (imageUrl == null || imageUrl.toString().trim().isEmpty) {
      // Fallback placeholder to avoid NetworkImage("") errors
      imageUrl =
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=300&fit=crop';
    } else if (!imageUrl.startsWith('http')) {
      // Prefix domain when not absolute
      imageUrl = WPConfig.imageBaseUrl + imageUrl;
    }

    // Handle price range
    String? priceRange;
    if (json['min_price'] != null && json['max_price'] != null) {
      priceRange = '${json['min_price']} - ${json['max_price']}';
    } else if (json['min_price'] != null) {
      priceRange = json['min_price'].toString();
    } else if (json['price_range'] != null) {
      priceRange = json['price_range'].toString();
    }

    // Handle rate conversion safely
    double? rate;
    final rateValue = json['rate'] ?? json['average_rating'];
    if (rateValue != null) {
      if (rateValue is num) {
        rate = rateValue.toDouble();
      } else if (rateValue is String) {
        rate = double.tryParse(rateValue);
      }
    }

    // Handle coordinates safely
    double? latitude;
    double? longitude;
    if (json['latitude'] != null) {
      if (json['latitude'] is num) {
        latitude = json['latitude'].toDouble();
      } else if (json['latitude'] is String) {
        latitude = double.tryParse(json['latitude']);
      }
    }
    if (json['longitude'] != null) {
      if (json['longitude'] is num) {
        longitude = json['longitude'].toDouble();
      } else if (json['longitude'] is String) {
        longitude = double.tryParse(json['longitude']);
      }
    }

    // Handle coordinates map
    Map<String, double>? coordinates;
    if (latitude != null && longitude != null) {
      coordinates = {
        'latitude': latitude,
        'longitude': longitude,
      };
    }

    // Handle List<String> fields safely
    List<String>? facilities;
    if (json['facilities'] != null) {
      if (json['facilities'] is List<dynamic>) {
        facilities =
            json['facilities'].map((item) => item?.toString() ?? '').toList();
      }
    }

    List<String>? roomTypes;
    if (json['room_types'] != null) {
      if (json['room_types'] is List<dynamic>) {
        roomTypes =
            json['room_types'].map((item) => item?.toString() ?? '').toList();
      }
    }

    List<String>? images;
    if (json['images'] != null) {
      if (json['images'] is List<dynamic>) {
        images = json['images'].map((item) => item?.toString() ?? '').toList();
      }
    }

    List<String>? nearbyAttractions;
    if (json['nearby_attractions'] != null) {
      if (json['nearby_attractions'] is List<dynamic>) {
        nearbyAttractions = json['nearby_attractions']
            .map((item) => item?.toString() ?? '')
            .toList();
      }
    }

    List<String>? availableDates;
    if (json['available_dates'] != null) {
      if (json['available_dates'] is List<dynamic>) {
        availableDates = json['available_dates']
            .map((item) => item?.toString() ?? '')
            .toList();
      }
    }

    return Hotel(
      id: id.isNotEmpty ? id : json['id']?.toString(),
      name: json['name'] ?? json['title'],
      location: json['location'] ?? json['address'],
      imageUrl: imageUrl,
      rate: rate,
      priceRange: priceRange,
      category: json['category'] ?? json['categoryName'],
      facilities: facilities,
      roomTypes: roomTypes,
      images: images,
      nearbyAttractions: nearbyAttractions,
      availableDates: availableDates,
      country: json['country'],
      state: json['state'],
      city: json['city'],
      countryId: json['country_id'] is int
          ? json['country_id']
          : (json['country_id'] is String
              ? int.tryParse(json['country_id'])
              : null),
      stateId: json['state_id'] is int
          ? json['state_id']
          : (json['state_id'] is String
              ? int.tryParse(json['state_id'])
              : null),
      cityId: json['city_id'] is int
          ? json['city_id']
          : (json['city_id'] is String ? int.tryParse(json['city_id']) : null),
      slug: json['slug'],
      stars: json['stars'] is int
          ? json['stars']
          : (json['stars'] is String ? int.tryParse(json['stars']) : null),
      categorySlug: json['categorySlug'],
      latitude: latitude,
      longitude: longitude,
      locationCoordinates: coordinates,
      oldPrice: json['old_price']?.toString(),
      dealLabel: json['deal_label']?.toString(),
      // Map other fields as needed
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'image_url': imageUrl,
      'rate': rate,
      'is_occupied': isOccupied,
      'description': description,
      'facilities': facilities,
      'room_types': roomTypes,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'price_range': priceRange,
      'contact': contact,
      'reviews': reviews?.map((e) => e.toJson()).toList(),
      'location_coordinates': locationCoordinates,
      'booking_url': bookingUrl,
      'images': images,
      'category': category,
      'nearby_attractions': nearbyAttractions,
      'available_dates': availableDates,
      'country': country,
      'state': state,
      'city': city,
      'country_id': countryId,
      'state_id': stateId,
      'city_id': cityId,
      'slug': slug,
      'stars': stars,
      'categorySlug': categorySlug,
      'latitude': latitude,
      'longitude': longitude,
      'old_price': oldPrice,
      'deal_label': dealLabel,
    };
  }
}

class HotelReview {
  final String? user;
  final int? rating;
  final String? comment;

  HotelReview({this.user, this.rating, this.comment});

  factory HotelReview.fromJson(Map<String, dynamic> json) {
    return HotelReview(
      user: json['user'],
      rating: json['rating'],
      comment: json['comment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'rating': rating,
      'comment': comment,
    };
  }
}

// Inline Location Models (to avoid separate location.dart)

class CountryModel {
  final int? id;
  final int? languageId;
  final String? name;
  final String? createdAt;
  final String? updatedAt;

  CountryModel(
      {this.id, this.languageId, this.name, this.createdAt, this.updatedAt});

  factory CountryModel.fromJson(Map<String, dynamic> json) => CountryModel(
        id: json['id'] is int
            ? json['id']
            : (json['id'] is String ? int.tryParse(json['id']) : null),
        languageId: json['language_id'] is int
            ? json['language_id']
            : (json['language_id'] is String
                ? int.tryParse(json['language_id'])
                : null),
        name: json['name'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'language_id': languageId,
        'name': name,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

class StateModel {
  final int? id;
  final int? languageId;
  final int? countryId;
  final String? name;
  final String? createdAt;
  final String? updatedAt;

  StateModel(
      {this.id,
      this.languageId,
      this.countryId,
      this.name,
      this.createdAt,
      this.updatedAt});

  factory StateModel.fromJson(Map<String, dynamic> json) => StateModel(
        id: json['id'] is int
            ? json['id']
            : (json['id'] is String ? int.tryParse(json['id']) : null),
        languageId: json['language_id'] is int
            ? json['language_id']
            : (json['language_id'] is String
                ? int.tryParse(json['language_id'])
                : null),
        countryId: json['country_id'] is int
            ? json['country_id']
            : (json['country_id'] is String
                ? int.tryParse(json['country_id'])
                : null),
        name: json['name'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'language_id': languageId,
        'country_id': countryId,
        'name': name,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

class CityModel {
  final int? id;
  final int? languageId;
  final int? countryId;
  final int? stateId;
  final String? featureImage;
  final String? name;
  final String? createdAt;
  final String? updatedAt;

  CityModel({
    this.id,
    this.languageId,
    this.countryId,
    this.stateId,
    this.featureImage,
    this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
        id: json['id'] is int
            ? json['id']
            : (json['id'] is String ? int.tryParse(json['id']) : null),
        languageId: json['language_id'] is int
            ? json['language_id']
            : (json['language_id'] is String
                ? int.tryParse(json['language_id'])
                : null),
        countryId: json['country_id'] is int
            ? json['country_id']
            : (json['country_id'] is String
                ? int.tryParse(json['country_id'])
                : null),
        stateId: json['state_id'] is int
            ? json['state_id']
            : (json['state_id'] is String
                ? int.tryParse(json['state_id'])
                : null),
        featureImage: json['feature_image'],
        name: json['name'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );

  Map<String, dynamic> toJson() => {
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

class LocationResponseModel {
  final Map<String, dynamic>? seoInfo;
  final Map<String, dynamic>? currencyInfo;
  final List<Map<String, dynamic>>? categories;
  final List<Map<String, dynamic>>? vendors;
  final List<CountryModel>? countries;
  final List<StateModel>? states;
  final List<CityModel>? cities;
  final List<Map<String, dynamic>>? bookingHours;
  final List<Map<String, dynamic>>? featuredContents;
  final List<Hotel>? hotels;
  final int? total;
  final int? perPage;
  final int? currentPage;

  LocationResponseModel({
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

  factory LocationResponseModel.fromJson(Map<String, dynamic> json) =>
      LocationResponseModel(
        seoInfo: json['seoInfo'],
        currencyInfo: json['currencyInfo'],
        categories: json['categories'] != null
            ? List<Map<String, dynamic>>.from(json['categories'])
            : null,
        vendors: json['vendors'] != null
            ? List<Map<String, dynamic>>.from(json['vendors'])
            : null,
        countries: json['countries'] != null
            ? (json['countries'] as List)
                .map((e) => CountryModel.fromJson(e))
                .toList()
            : null,
        states: json['states'] != null
            ? (json['states'] as List)
                .map((e) => StateModel.fromJson(e))
                .toList()
            : null,
        cities: json['cities'] != null
            ? (json['cities'] as List)
                .map((e) => CityModel.fromJson(e))
                .toList()
            : null,
        bookingHours: json['bookingHours'] != null
            ? List<Map<String, dynamic>>.from(json['bookingHours'])
            : null,
        featuredContents: json['featured_contents'] != null
            ? List<Map<String, dynamic>>.from(json['featured_contents'])
            : null,
        hotels: json['hotels'] != null
            ? (json['hotels'] as List)
                .map((e) => Hotel.fromJson(e, e['id']?.toString() ?? ''))
                .toList()
            : null,
        total: json['total'] is int
            ? json['total']
            : (json['total'] is String ? int.tryParse(json['total']) : null),
        perPage: json['perPage'] is int
            ? json['perPage']
            : (json['perPage'] is String
                ? int.tryParse(json['perPage'])
                : null),
        currentPage: json['currentPage'] is int
            ? json['currentPage']
            : (json['currentPage'] is String
                ? int.tryParse(json['currentPage'])
                : null),
      );

  Map<String, dynamic> toJson() => {
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
