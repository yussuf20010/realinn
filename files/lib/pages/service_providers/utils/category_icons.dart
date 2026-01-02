import 'package:flutter/material.dart';

class CategoryIcons {
  static IconData getIcon(String categoryName) {
    final name = categoryName.toLowerCase();

    if (name.contains('web') || name.contains('development')) {
      return Icons.code;
    } else if (name.contains('mobile') || name.contains('app')) {
      return Icons.smartphone;
    } else if (name.contains('graphic') || name.contains('design')) {
      return Icons.brush;
    } else if (name.contains('digital') || name.contains('marketing')) {
      return Icons.trending_up;
    } else if (name.contains('content') || name.contains('writing')) {
      return Icons.create;
    } else if (name.contains('photography')) {
      return Icons.camera_alt;
    } else if (name.contains('video') || name.contains('production')) {
      return Icons.videocam;
    } else if (name.contains('business') || name.contains('consulting')) {
      return Icons.business;
    } else if (name.contains('translation')) {
      return Icons.translate;
    } else if (name.contains('data') || name.contains('entry')) {
      return Icons.input;
    }

    return Icons.work;
  }

  static Color getColor(String categoryName) {
    final name = categoryName.toLowerCase();

    if (name.contains('web') || name.contains('development')) {
      return Colors.blue;
    } else if (name.contains('mobile') || name.contains('app')) {
      return Colors.green;
    } else if (name.contains('graphic') || name.contains('design')) {
      return Colors.grey; // Will be replaced with primary color dynamically
    } else if (name.contains('digital') || name.contains('marketing')) {
      return Colors.orange;
    } else if (name.contains('content') || name.contains('writing')) {
      return Colors.teal;
    } else if (name.contains('photography')) {
      return Colors.pink;
    } else if (name.contains('video') || name.contains('production')) {
      return Colors.red;
    } else if (name.contains('business') || name.contains('consulting')) {
      return Colors.indigo;
    } else if (name.contains('translation')) {
      return Colors.cyan;
    } else if (name.contains('data') || name.contains('entry')) {
      return Colors.amber;
    }

    return Colors.grey;
  }
}
