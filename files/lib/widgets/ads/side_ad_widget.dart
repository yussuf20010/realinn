import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/ads_service.dart';
import 'ad_banner_widget.dart';

class SideAdWidget extends StatelessWidget {
  final String page;
  final double? width;
  final double? height;

  const SideAdWidget({
    Key? key,
    required this.page,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 768;
    
    final bannerAds = StaticAd.getAdsByType(AdType.banner, page)
        .where((ad) => ad.position == AdPosition.sidebar)
        .toList();

    if (bannerAds.isEmpty) {
      return SizedBox.shrink();
    }

    // Better sizing for tablets
    final defaultWidth = isTablet ? 100.w : 120.w;
    final defaultHeight = isTablet ? 180.h : 200.h;
    final spacing = isTablet ? 12.h : 16.h;

    return Container(
      width: width ?? defaultWidth,
      margin: EdgeInsets.symmetric(vertical: isTablet ? 4.h : 8.h),
      child: Column(
        children: bannerAds.map((ad) {
          return Padding(
            padding: EdgeInsets.only(bottom: spacing),
            child: AdBannerWidget(
              ad: ad,
              width: width ?? defaultWidth,
              height: height ?? defaultHeight,
            ),
          );
        }).toList(),
      ),
    );
  }
}

