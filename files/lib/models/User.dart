class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role;
  final String image;
  final DateTime? emailVerifiedAt;
  final String fcmToken;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.image,
    this.emailVerifiedAt, // ✅ No `required`, as it can be null
    required this.fcmToken,
  });

  // ✅ Convert from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      image: json['image'] ?? '',
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.tryParse(json['email_verified_at'])
          : null, // ✅ Handle null safely
      fcmToken: json['fcm_token'] ?? '',
    );
  }

  // ✅ Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'role': role,
      'image': image,
      'email_verified_at': emailVerifiedAt?.toIso8601String(), // ✅ Convert safely
      'fcm_token': fcmToken,
    };
  }
}
