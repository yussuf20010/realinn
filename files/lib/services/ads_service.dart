// Static Ads Service
// This service manages different types of ads throughout the app

class AdType {
  static const String popup = 'popup';
  static const String banner = 'banner';
  static const String interstitial = 'interstitial';
  static const String native = 'native';
}

class AdPosition {
  static const String top = 'top';
  static const String bottom = 'bottom';
  static const String middle = 'middle';
  static const String sidebar = 'sidebar';
}

class StaticAd {
  final String id;
  final String type; // popup, banner, interstitial, native
  final String? imageUrl;
  final String? title;
  final String? description;
  final String? linkUrl;
  final String position; // top, bottom, middle, sidebar
  final String page; // home, hotel, profile, etc.
  final int? displayDuration; // For popups in seconds
  final bool isActive;

  StaticAd({
    required this.id,
    required this.type,
    this.imageUrl,
    this.title,
    this.description,
    this.linkUrl,
    required this.position,
    required this.page,
    this.displayDuration,
    this.isActive = true,
  });

  // Static ads data with real images - can be replaced with API call later
  static List<StaticAd> getStaticAds() {
    return [
      // Popup ads for home page
      StaticAd(
        id: 'popup_home_1',
        type: AdType.popup,
        imageUrl: 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&h=300&fit=crop',
        title: 'Special Offer',
        description: 'Get 20% off on your next booking!',
        linkUrl: 'https://example.com/offer',
        position: AdPosition.middle,
        page: 'home',
        displayDuration: 5,
      ),
      StaticAd(
        id: 'popup_home_2',
        type: AdType.popup,
        imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=300&fit=crop',
        title: 'Summer Sale',
        description: 'Book now and save up to 30%!',
        linkUrl: 'https://example.com/summer',
        position: AdPosition.middle,
        page: 'home',
        displayDuration: 5,
      ),
      // Popup ads for hotel page
      StaticAd(
        id: 'popup_hotel_1',
        type: AdType.popup,
        imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=300&fit=crop',
        title: 'Luxury Stay',
        description: 'Experience premium accommodations',
        linkUrl: 'https://example.com/luxury',
        position: AdPosition.middle,
        page: 'hotel',
        displayDuration: 5,
      ),
      // Banner ads
      StaticAd(
        id: 'banner_home_1',
        type: AdType.banner,
        imageUrl: 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=728&h=90&fit=crop',
        linkUrl: 'https://example.com',
        position: AdPosition.top,
        page: 'home',
      ),
      StaticAd(
        id: 'banner_home_2',
        type: AdType.banner,
        imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=728&h=90&fit=crop',
        linkUrl: 'https://example.com',
        position: AdPosition.bottom,
        page: 'home',
      ),
      StaticAd(
        id: 'banner_hotel_1',
        type: AdType.banner,
        imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=728&h=90&fit=crop',
        linkUrl: 'https://example.com',
        position: AdPosition.top,
        page: 'hotel',
      ),
      // Side ads for login/register pages
      StaticAd(
        id: 'banner_login_1',
        type: AdType.banner,
        imageUrl: 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=200&h=300&fit=crop',
        linkUrl: 'https://example.com',
        position: AdPosition.sidebar,
        page: 'login',
      ),
      StaticAd(
        id: 'banner_register_1',
        type: AdType.banner,
        imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=200&h=300&fit=crop',
        linkUrl: 'https://example.com',
        position: AdPosition.sidebar,
        page: 'register',
      ),
      // Interstitial ads
      StaticAd(
        id: 'interstitial_profile_1',
        type: AdType.interstitial,
        imageUrl: 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=600&h=800&fit=crop',
        title: 'Premium Membership',
        description: 'Unlock exclusive features',
        linkUrl: 'https://example.com/premium',
        position: AdPosition.middle,
        page: 'profile',
      ),
      // Native ads
      StaticAd(
        id: 'native_home_1',
        type: AdType.native,
        imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=300&h=200&fit=crop',
        title: 'Best Deals',
        description: 'Check out our latest offers',
        linkUrl: 'https://example.com/deals',
        position: AdPosition.middle,
        page: 'home',
      ),
    ];
  }

  static List<StaticAd> getAdsForPage(String page) {
    return getStaticAds().where((ad) => ad.page == page && ad.isActive).toList();
  }

  static List<StaticAd> getAdsByType(String type, String page) {
    return getStaticAds()
        .where((ad) => ad.type == type && ad.page == page && ad.isActive)
        .toList();
  }
}

