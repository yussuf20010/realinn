import 'assets.dart';

class LocalProviderImages {
  static const String _basePath = 'assets/png';

  static const List<String> images = [
    AssetsManager.taxi,
    AssetsManager.driver,
    AssetsManager.kids,
    AssetsManager.animals,
    AssetsManager.needs,
    AssetsManager.travel,
    AssetsManager.visitors,
    AssetsManager.yoga,
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
