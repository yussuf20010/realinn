import 'assets.dart';

class LocalProviderImages {
  static const String _basePath = 'assets/png';

  static const List<String> images = [
    AssetsManager.taxi,
    AssetsManager.driver,
    AssetsManager.kids,
    AssetsManager.animals,
    AssetsManager.needs,
    AssetsManager.provider6,
    AssetsManager.provider2,
    AssetsManager.provider3,
    AssetsManager.provider9,
    AssetsManager.provider10,
  ];

  static String getImagePath(int index) {
    return images[index % images.length];
  }

  static String getImagePathByName(String name) {
    name = name.toLowerCase();
    if (name.contains('taxi')) return AssetsManager.taxi;
    if (name.contains('driver')) return AssetsManager.driver;
    if (name.contains('kids') || name.contains('child') || name.contains('nanny')) return AssetsManager.kids;
    if (name.contains('animal') || name.contains('pet')) return AssetsManager.animals;
    if (name.contains('need') || name.contains('special')) return AssetsManager.needs;
    
    // Default to index-based if no match found
    return getImagePath(name.length);
  }
}
