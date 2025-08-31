import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/home_page.dart';
import '../favourites/favourites_page.dart';
import '../bookings/bookings_page.dart';
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
    BookingsPage(),
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
    final isTablet = MediaQuery.of(context).size.width >= 768;

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
          height: isTablet ? 80 : 70,
          padding:
              EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home, 'Home', isTablet, primaryColor),
              _buildNavItem(1, Icons.favorite, 'Fav', isTablet, primaryColor),
              _buildNavItem(2, Icons.book, 'Booking', isTablet, primaryColor),
              _buildNavItem(
                  3, Icons.history, 'History', isTablet, primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isTablet,
      Color primaryColor) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? primaryColor : Colors.grey[600],
            size: isTablet ? 28 : 24,
          ),
          SizedBox(height: isTablet ? 6 : 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? primaryColor : Colors.grey[600],
              fontSize: isTablet ? 12 : 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
