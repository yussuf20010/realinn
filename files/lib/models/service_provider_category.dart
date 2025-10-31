class ServiceProviderCategory {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? icon;
  final String? image;
  final int? parentId;
  final int status;
  final int sortOrder;
  final String? createdAt;
  final String? updatedAt;
  final int serviceProvidersCount;

  ServiceProviderCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
    this.image,
    this.parentId,
    required this.status,
    required this.sortOrder,
    this.createdAt,
    this.updatedAt,
    this.serviceProvidersCount = 0,
  });

  factory ServiceProviderCategory.fromJson(Map<String, dynamic> json) {
    return ServiceProviderCategory(
      id: json['id'] is int
          ? json['id']
          : (json['id'] is String ? int.tryParse(json['id']) ?? 0 : 0),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      icon: json['icon']?.toString(),
      image: json['image']?.toString(),
      parentId: json['parent_id'] is int
          ? json['parent_id']
          : (json['parent_id'] is String
              ? int.tryParse(json['parent_id'])
              : null),
      status: json['status'] is int
          ? json['status']
          : (json['status'] is String ? int.tryParse(json['status']) ?? 1 : 1),
      sortOrder: json['sort_order'] is int
          ? json['sort_order']
          : (json['sort_order'] is String
              ? int.tryParse(json['sort_order']) ?? 0
              : 0),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      serviceProvidersCount: json['service_providers_count'] is int
          ? json['service_providers_count']
          : (json['service_providers_count'] is String
              ? int.tryParse(json['service_providers_count']) ?? 0
              : 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'icon': icon,
      'image': image,
      'parent_id': parentId,
      'status': status,
      'sort_order': sortOrder,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'service_providers_count': serviceProvidersCount,
    };
  }
}
