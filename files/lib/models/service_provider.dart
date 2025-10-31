import 'service_provider_category.dart';
import '../config/wp_config.dart';

class ServiceProvider {
  final String id;
  final int userId;
  final String name;
  final String? tagline;
  final String? description;
  final String? profileImage;
  final String? coverImage;
  final String? country;
  final String? city;
  final double? latitude;
  final double? longitude;
  final int? mainCategoryId;
  final String? skills;
  final double rating;
  final int reviewCount;
  final int completedOrders;
  final double responseRate;
  final double onTimeDeliveryRate;
  final double minPrice;
  final double maxPrice;
  final String currency;
  final String status;
  final bool isVerified;
  final bool availableForWork;
  final String? joinedAt;
  final String? createdAt;
  final String? updatedAt;
  final ServiceProviderCategory? mainCategory;

  // Legacy fields for backward compatibility
  String get category => mainCategory?.name ?? '';
  String get imageUrl => profileImage != null && profileImage!.isNotEmpty
      ? (profileImage!.startsWith('http')
          ? profileImage!
          : '${WPConfig.imageBaseUrl}$profileImage')
      : '';
  int get completedJobs => completedOrders;
  double get pricePerHour => minPrice;
  bool get isAvailable => availableForWork;

  ServiceProvider({
    required this.id,
    required this.userId,
    required this.name,
    this.tagline,
    this.description,
    this.profileImage,
    this.coverImage,
    this.country,
    this.city,
    this.latitude,
    this.longitude,
    this.mainCategoryId,
    this.skills,
    required this.rating,
    required this.reviewCount,
    required this.completedOrders,
    required this.responseRate,
    required this.onTimeDeliveryRate,
    required this.minPrice,
    required this.maxPrice,
    required this.currency,
    required this.status,
    required this.isVerified,
    required this.availableForWork,
    this.joinedAt,
    this.createdAt,
    this.updatedAt,
    this.mainCategory,
  });

  factory ServiceProvider.fromApi(Map<String, dynamic> json) {
    final dynamic ratingRaw = json['average_rating'] ?? json['ratings'] ?? 0;
    final double rating = ratingRaw is num
        ? ratingRaw.toDouble()
        : double.tryParse(ratingRaw.toString()) ?? 0.0;

    final dynamic reviewCountRaw = json['review_count'] ?? 0;
    final int reviewCount = reviewCountRaw is int
        ? reviewCountRaw
        : (reviewCountRaw is String ? int.tryParse(reviewCountRaw) ?? 0 : 0);

    final dynamic ordersRaw =
        json['completed_orders'] ?? json['orders_count'] ?? 0;
    final int completedOrders =
        ordersRaw is int ? ordersRaw : int.tryParse(ordersRaw.toString()) ?? 0;

    final dynamic responseRateRaw = json['response_rate'] ?? 0;
    final double responseRate = responseRateRaw is num
        ? responseRateRaw.toDouble()
        : double.tryParse(responseRateRaw.toString()) ?? 0.0;

    final dynamic onTimeRateRaw = json['on_time_delivery_rate'] ?? 0;
    final double onTimeDeliveryRate = onTimeRateRaw is num
        ? onTimeRateRaw.toDouble()
        : double.tryParse(onTimeRateRaw.toString()) ?? 0.0;

    final dynamic minPriceRaw = json['min_price'] ?? 0;
    final double minPrice = minPriceRaw is num
        ? minPriceRaw.toDouble()
        : double.tryParse(minPriceRaw.toString()) ?? 0.0;

    final dynamic maxPriceRaw = json['max_price'] ?? 0;
    final double maxPrice = maxPriceRaw is num
        ? maxPriceRaw.toDouble()
        : double.tryParse(maxPriceRaw.toString()) ?? 0.0;

    final dynamic latRaw = json['latitude'];
    final double? latitude = latRaw != null
        ? (latRaw is num
            ? latRaw.toDouble()
            : double.tryParse(latRaw.toString()))
        : null;

    final dynamic lngRaw = json['longitude'];
    final double? longitude = lngRaw != null
        ? (lngRaw is num
            ? lngRaw.toDouble()
            : double.tryParse(lngRaw.toString()))
        : null;

    ServiceProviderCategory? mainCategory;
    if (json['main_category'] != null) {
      mainCategory = ServiceProviderCategory.fromJson(
          json['main_category'] as Map<String, dynamic>);
    }

    return ServiceProvider(
      id: (json['id'] ?? '').toString(),
      userId: json['user_id'] is int
          ? json['user_id']
          : (json['user_id'] is String
              ? int.tryParse(json['user_id']) ?? 0
              : 0),
      name: (json['display_name'] ?? json['name'] ?? '').toString(),
      tagline: json['tagline']?.toString(),
      description: json['description']?.toString(),
      profileImage: json['profile_image']?.toString(),
      coverImage: json['cover_image']?.toString(),
      country: json['country']?.toString(),
      city: json['city']?.toString(),
      latitude: latitude,
      longitude: longitude,
      mainCategoryId: json['main_category_id'] is int
          ? json['main_category_id']
          : (json['main_category_id'] is String
              ? int.tryParse(json['main_category_id'])
              : null),
      skills: json['skills']?.toString(),
      rating: rating,
      reviewCount: reviewCount,
      completedOrders: completedOrders,
      responseRate: responseRate,
      onTimeDeliveryRate: onTimeDeliveryRate,
      minPrice: minPrice,
      maxPrice: maxPrice,
      currency: (json['currency'] ?? 'USD').toString(),
      status: (json['status'] ?? 'active').toString(),
      isVerified: json['is_verified'] == true,
      availableForWork: json['available_for_work'] == true,
      joinedAt: json['joined_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      mainCategory: mainCategory,
    );
  }
}
