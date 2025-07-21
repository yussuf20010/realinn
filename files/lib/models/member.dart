import 'dart:convert';

class Member {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role;
  final String? image;
  final DateTime? emailVerifiedAt;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? rentedPropertyId;
  final String balance;

  Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    this.image,
    this.emailVerifiedAt,
    this.fcmToken,
    required this.createdAt,
    required this.updatedAt,
    this.rentedPropertyId,
    required this.balance,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      image: json['image'],
      emailVerifiedAt: json['email_verified_at'] != null 
          ? DateTime.tryParse(json['email_verified_at']) 
          : null,
      fcmToken: json['fcm_token'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
      rentedPropertyId: json['rented_property_id'],
      balance: json['balance'] ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'role': role,
      'image': image,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'fcm_token': fcmToken,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'rented_property_id': rentedPropertyId,
      'balance': balance,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id':id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'image': image,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'fcm_token': fcmToken,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'rented_property_id': rentedPropertyId,
      'balance': balance,
    };
  }

  factory Member.fromLocal(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      image: map['image'],
      emailVerifiedAt: map['email_verified_at'] != null ? DateTime.parse(map['email_verified_at']) : null,
      fcmToken: map['fcm_token'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      rentedPropertyId: map['rented_property_id'],
      balance: map['balance'] ?? '0.00',
      role: map['role'] ?? '',
    );
  }

  factory Member.fromServer(Map<String, dynamic> map) {
    return Member(
        id: map['id'],
        firstName: map['firstName'] ?? map['first_name'] ?? '',
        lastName: map['lastName'] ?? map['last_name'] ?? '',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        image: map['image'],
        emailVerifiedAt: map['email_verified_at'] != null ? DateTime.tryParse(map['email_verified_at']) : null,
        fcmToken: map['fcm_token'],
        createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
        updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : DateTime.now(),
        rentedPropertyId: map['rented_property_id'],
        balance: map['balance'] ?? '0.00',
        role: map['role'] ?? '',
    );
  }
}


