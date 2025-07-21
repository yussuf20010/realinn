import 'package:flutter/foundation.dart';

class ProfileModel {
  final String userId;
  final String username;
  final String email;
  final String userType;
  final DateTime createdAt;
  final String profilePicture;
  final String? mobile;
  final String? name;
  final String? avatar;
  final String? createdSince;
  final Location? location;

  ProfileModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.userType,
    required this.createdAt,
    required this.profilePicture,
    this.mobile,
    this.name,
    this.avatar,
    this.createdSince,
    this.location,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    print('ProfileModel: Parsing profile data: $json');
    
    // Helper function to safely parse DateTime
    DateTime parseDateTime(dynamic value) {
      try {
        if (value is String) {
          return DateTime.parse(value);
        } else if (value is int) {
          return DateTime.fromMillisecondsSinceEpoch(value);
        } else {
          print('ProfileModel: Invalid date format: $value');
          return DateTime.now(); // Fallback to current time
        }
      } catch (e) {
        print('ProfileModel: Error parsing date: $e');
        return DateTime.now(); // Fallback to current time
      }
    }

    // Helper function to safely get string value
    String getString(dynamic value, {String defaultValue = ''}) {
      if (value == null) return defaultValue;
      return value.toString();
    }

    try {
      final profile = ProfileModel(
        userId: getString(json['userId']),
        username: getString(json['username']),
        email: getString(json['email']),
        userType: getString(json['userType']),
        createdAt: parseDateTime(json['createdAt']),
        profilePicture: getString(json['profilePicture']),
        mobile: json['mobile']?.toString(),
        name: json['name']?.toString(),
        avatar: json['avatar']?.toString(),
        createdSince: json['createdSince']?.toString(),
        location: json['location'] != null ? Location.fromJson(json['location']) : null,
      );
      
      print('ProfileModel: Successfully parsed profile for ${profile.username}');
      return profile;
    } catch (e, stack) {
      print('ProfileModel: Error creating profile: $e');
      print('ProfileModel: Stack trace: $stack');
      rethrow;
    }
  }
}

class Location {
  final String city;
  final String country;

  Location({required this.city, required this.country});

  factory Location.fromJson(Map<String, dynamic> json) {
    print('Location: Parsing location data: $json');
    
    try {
      final location = Location(
        city: json['city']?.toString() ?? '',
        country: json['country']?.toString() ?? '',
      );
      
      print('Location: Successfully parsed location for ${location.city}, ${location.country}');
      return location;
    } catch (e, stack) {
      print('Location: Error creating location: $e');
      print('Location: Stack trace: $stack');
      rethrow;
    }
  }
} 