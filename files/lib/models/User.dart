class User {
  final int id;
  final String? username;
  final String? email;
  final String? name;
  final String? image;
  final String? phone;
  final String? country;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? address;
  final String? emailVerifiedAt;
  final int? status;
  final String? createdAt;
  final String? updatedAt;

  User({
    required this.id,
    this.username,
    this.email,
    this.name,
    this.image,
    this.phone,
    this.country,
    this.city,
    this.state,
    this.zipCode,
    this.address,
    this.emailVerifiedAt,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int
          ? json['id']
          : (json['id'] is String ? int.tryParse(json['id']) ?? 0 : 0),
      username: json['username']?.toString(),
      email: json['email']?.toString(),
      name: json['name']?.toString(),
      image: json['image']?.toString(),
      phone: json['phone']?.toString(),
      country: json['country']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      zipCode: json['zip_code']?.toString(),
      address: json['address']?.toString(),
      emailVerifiedAt: json['email_verified_at']?.toString(),
      status: json['status'] is int
          ? json['status']
          : (json['status'] is String ? int.tryParse(json['status']) : null),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'image': image,
      'phone': phone,
      'country': country,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'address': address,
      'email_verified_at': emailVerifiedAt,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class AuthResponse {
  final String message;
  final User? user;
  final String? redirect;
  final int? userId;
  final int? otpExpiresIn;

  AuthResponse({
    required this.message,
    this.user,
    this.redirect,
    this.userId,
    this.otpExpiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message']?.toString() ?? '',
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      redirect: json['redirect']?.toString(),
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : (json['user_id'] is String
              ? int.tryParse(json['user_id'] as String)
              : null),
      otpExpiresIn: json['otp_expires_in'] is int
          ? json['otp_expires_in'] as int
          : (json['otp_expires_in'] is String
              ? int.tryParse(json['otp_expires_in'] as String)
              : null),
    );
  }
}
