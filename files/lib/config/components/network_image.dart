import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config/wp_config.dart';
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
    final url = _getImageUrl(imageUrl);
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(AppDefaults.radius)),
      child: SizedBox(
        width: width,
        height: height,
        child: FutureBuilder<bool>(
          future: _urlExists(url),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildPlaceholder();
            }
            final exists = snapshot.data == true;
            if (!exists) {
              return _buildError();
            }
            return CachedNetworkImage(
              imageUrl: url,
              fit: fit,
              width: width,
              height: height,
              memCacheWidth: cacheWidth,
              memCacheHeight: cacheHeight,
              placeholder: (context, _) => _buildPlaceholder(),
              errorWidget: (context, _, __) => _buildError(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.grey,
          size: 40,
        ),
      ),
    );
  }

  Future<bool> _urlExists(String url) async {
    try {
      final uri = Uri.parse(url);
      final res = await http.head(uri).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) return true;
      // Some CDNs disallow HEAD; fall back to lightweight GET with range
      final get = await http.get(uri, headers: {'Range': 'bytes=0-0'}).timeout(const Duration(seconds: 3));
      return get.statusCode == 200 || get.statusCode == 206;
    } catch (_) {
      return false;
    }
  }
}
