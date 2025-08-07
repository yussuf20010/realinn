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
    if (imageUrl != null && !imageUrl.startsWith('http')) {
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
        facilities = json['facilities'].map((item) => item?.toString() ?? '').toList();
      }
    }

    List<String>? roomTypes;
    if (json['room_types'] != null) {
      if (json['room_types'] is List<dynamic>) {
        roomTypes = json['room_types'].map((item) => item?.toString() ?? '').toList();
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
        nearbyAttractions = json['nearby_attractions'].map((item) => item?.toString() ?? '').toList();
      }
    }

    List<String>? availableDates;
    if (json['available_dates'] != null) {
      if (json['available_dates'] is List<dynamic>) {
        availableDates = json['available_dates'].map((item) => item?.toString() ?? '').toList();
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
      countryId: json['country_id'] is int ? json['country_id'] : (json['country_id'] is String ? int.tryParse(json['country_id']) : null),
      stateId: json['state_id'] is int ? json['state_id'] : (json['state_id'] is String ? int.tryParse(json['state_id']) : null),
      cityId: json['city_id'] is int ? json['city_id'] : (json['city_id'] is String ? int.tryParse(json['city_id']) : null),
      slug: json['slug'],
      stars: json['stars'] is int ? json['stars'] : (json['stars'] is String ? int.tryParse(json['stars']) : null),
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