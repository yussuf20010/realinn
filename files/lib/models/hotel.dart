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
  });

  factory Hotel.fromJson(Map<String, dynamic> json, String id) {
    return Hotel(
      id: id,
      name: json['name'],
      location: json['location'],
      imageUrl: json['image_url'],
      rate: (json['rate'] != null) ? (json['rate'] as num).toDouble() : null,
      isOccupied: json['is_occupied'],
      description: json['description'],
      facilities: (json['facilities'] as List?)?.map((e) => e.toString()).toList(),
      roomTypes: (json['room_types'] as List?)?.map((e) => e.toString()).toList(),
      checkInTime: json['check_in_time'],
      checkOutTime: json['check_out_time'],
      priceRange: json['price_range'],
      contact: (json['contact'] as Map?)?.map((k, v) => MapEntry(k.toString(), v.toString())),
      reviews: (json['reviews'] as List?)?.map((e) => HotelReview.fromJson(e)).toList(),
      locationCoordinates: json['location_coordinates'] != null
          ? {
              'latitude': (json['location_coordinates']['latitude'] as num?)?.toDouble() ?? 0.0,
              'longitude': (json['location_coordinates']['longitude'] as num?)?.toDouble() ?? 0.0,
            }
          : null,
      bookingUrl: json['booking_url'],
      images: (json['images'] as List?)?.map((e) => e.toString()).toList(),
      category: json['category'],
      nearbyAttractions: (json['nearby_attractions'] as List?)?.map((e) => e.toString()).toList(),
      availableDates: (json['available_dates'] as List?)?.map((e) => e.toString()).toList(),
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