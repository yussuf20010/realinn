import 'package:flutter/material.dart';
import '../../services/ads_service.dart';
import 'ad_banner_widget.dart';
import 'ad_popup_widget.dart';

class AdsManager {
  // Show popup ads for a specific page
  static void showPopupAds(BuildContext context, String page) {
    final popupAds = StaticAd.getAdsByType(AdType.popup, page);
    if (popupAds.isNotEmpty) {
      // Show first popup ad
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AdPopupWidget(
          ad: popupAds.first,
          onClose: () => Navigator.of(context).pop(),
        ),
      );
    }
  }

  // Get banner ads for a specific page and position
  static List<Widget> getBannerAds(String page, String position) {
    final ads = StaticAd.getAdsByType(AdType.banner, page)
        .where((ad) => ad.position == position)
        .toList();
    
    return ads.map((ad) => AdBannerWidget(ad: ad)).toList();
  }

  // Get all ads for a page
  static List<StaticAd> getAllAdsForPage(String page) {
    return StaticAd.getAdsForPage(page);
  }
}

