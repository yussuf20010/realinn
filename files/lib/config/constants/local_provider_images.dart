import 'assets.dart';

class LocalProviderImages {
  static const String _basePath = 'assets/png';

  static const List<String> images = [
    AssetsManager.provider1,
    AssetsManager.provider2,
    AssetsManager.provider3,
    AssetsManager.provider4,
    AssetsManager.provider5,
    AssetsManager.provider6,
    AssetsManager.provider7,
    AssetsManager.provider8,
    AssetsManager.provider9,
    AssetsManager.provider10,
    AssetsManager.provider11,
    AssetsManager.provider12,
  ];

  static String getImagePath(int index) {
    return images[index % images.length];
  }

  static String getImagePathByName(String name) {
    // Distribute images "randomly" but stably using the name's hash
    final index = name.hashCode;
    return getImagePath(index.abs());
  }
}
