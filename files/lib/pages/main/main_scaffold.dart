import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:realinn/core/constants/assets.dart';
import '../home/home_page.dart';
import '../favourites/favourites_page.dart';
import '../waiting_list/waiting_list_page.dart';
import '../history/history_page.dart';
import '../../config/wp_config.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainScaffold({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _currentIndex = 0; // Start with home page (index 0)

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _pages = [
    HomePage(),
    FavouritesPage(),
    WaitingListPage(), // Waiting List page
    HistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    final primaryColor = WPConfig.navbarColor;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 768;
    final isLandscape = screenSize.width > screenSize.height;

    // Adjust heights based on orientation
    final navBarHeight =
        isLandscape ? (isTablet ? 60.h : 50.h) : (isTablet ? 80.h : 70.h);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: navBarHeight,
          padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24.w : 16.w,
              vertical: isLandscape ? 4.h : 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home, 'home'.tr(), isTablet, isLandscape,
                  primaryColor),
              _buildNavItem(1, Icons.favorite, 'favorites'.tr(), isTablet,
                  isLandscape, primaryColor),
              _buildNavItem(2, Icons.shopping_cart_outlined,
                  'waiting_list'.tr(), isTablet, isLandscape, primaryColor),
              _buildNavItem(3, Icons.history, 'history'.tr(), isTablet,
                  isLandscape, primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isTablet,
      bool isLandscape, Color primaryColor) {
    final isSelected = _currentIndex == index;

    // Adjust sizes based on orientation
    final iconSize =
        isLandscape ? (isTablet ? 20.sp : 18.sp) : (isTablet ? 28.sp : 24.sp);
    final textSize =
        isLandscape ? (isTablet ? 10.sp : 8.sp) : (isTablet ? 12.sp : 10.sp);
    final spacing =
        isLandscape ? (isTablet ? 2.h : 1.h) : (isTablet ? 6.h : 4.h);

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Use PNG image for waiting list (index 2), icon for others
          index == 2
              ? SvgPicture.asset(
                  AssetsManager.waiting,
                  width: iconSize,
                  height: iconSize,
                  color: isSelected ? primaryColor : Colors.black,
                )
              : Icon(
                  icon,
                  color: isSelected ? primaryColor : Colors.black,
                  size: iconSize,
                ),
          SizedBox(height: spacing),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? primaryColor : Colors.black,
                fontSize: textSize,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
