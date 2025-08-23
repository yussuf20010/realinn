import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageCacheConfig {
  static const Duration cacheDuration = Duration(days: 7);
  static const int maxWidth = 1080;
  static const int maxHeight = 1080;
  static const int maxSizeBytes = 50 * 1024 * 1024; // 50MB

  static Widget buildCachedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Widget? errorWidget,
    String? hotelName,
  }) {
    if (imageUrl.isEmpty) {
      return _buildHotelPlaceholder(
        width: width,
        height: height,
        borderRadius: borderRadius,
        hotelName: hotelName,
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: maxWidth,
      memCacheHeight: maxHeight,
      maxWidthDiskCache: maxWidth,
      maxHeightDiskCache: maxHeight,
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          image: DecorationImage(
            image: imageProvider,
            fit: fit,
          ),
        ),
      ),
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius,
          ),
        ),
      ),
      errorWidget: (context, url, error) => _buildHotelPlaceholder(
        width: width,
        height: height,
        borderRadius: borderRadius,
        hotelName: hotelName,
      ),
    );
  }

  static Widget _buildHotelPlaceholder({
    double? width,
    double? height,
    BorderRadius? borderRadius,
    String? hotelName,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[200]!,
            Colors.grey[300]!,
          ],
        ),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.hotel,
                color: Colors.grey[600],
                size: width != null && width < 100 ? 20 : 28,
              ),
            ),
            if (hotelName != null && hotelName.isNotEmpty) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hotelName.split(' ').take(2).join(' '),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: width != null && width < 100 ? 10 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget buildShimmerPlaceholder({
    required double width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  static Future<void> clearCache() async {
    final cacheManager = DefaultCacheManager();
    await cacheManager.emptyCache();
  }

  static Future<void> preloadImage(String imageUrl) async {
    if (imageUrl.isEmpty) return;
    
    try {
      final cacheManager = DefaultCacheManager();
      await cacheManager.getSingleFile(imageUrl);
    } catch (e) {
      print('Error preloading image: $e');
    }
  }

  static Future<bool> isImageCached(String imageUrl) async {
    if (imageUrl.isEmpty) return false;
    
    try {
      final cacheManager = DefaultCacheManager();
      final file = await cacheManager.getFileFromCache(imageUrl);
      return file != null;
    } catch (e) {
      print('Error checking image cache: $e');
      return false;
    }
  }
} 