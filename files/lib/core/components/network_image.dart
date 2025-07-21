import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../config/wp_config.dart';
import '../constants/app_colors.dart';
import '../constants/app_defaults.dart';

class NetworkImageWithLoader extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final int? cacheWidth;
  final int? cacheHeight;

  /// This widget is used for displaying network image with a placeholder
  const NetworkImageWithLoader(
    this.imageUrl, {
    Key? key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.cacheWidth,
    this.cacheHeight,
  }) : super(key: key);

  String _getImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    if (!imagePath.startsWith('/')) {
      imagePath = '/$imagePath';
    }
    return '${WPConfig.siteStorageUrl}$imagePath';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(AppDefaults.radius)),
      child: SizedBox(
        width: width,
        height: height,
        child: CachedNetworkImage(
          imageUrl: _getImageUrl(imageUrl),
          fit: fit,
          width: width,
          height: height,
          memCacheWidth: cacheWidth,
          memCacheHeight: cacheHeight,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.grey,
                size: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
