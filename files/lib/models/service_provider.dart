class ServiceProvider {
  final String id;
  final String name;
  final String image;
  final String serviceType;
  final double rating;
  final String location;
  final String description;
  final List<String> services;
  final double price;
  final bool isAvailable;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.image,
    required this.serviceType,
    required this.rating,
    required this.location,
    required this.description,
    required this.services,
    required this.price,
    this.isAvailable = true,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      serviceType: json['serviceType'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      services: List<String>.from(json['services'] ?? []),
      price: (json['price'] ?? 0.0).toDouble(),
      isAvailable: json['isAvailable'] ?? true,
    );
  }
} 