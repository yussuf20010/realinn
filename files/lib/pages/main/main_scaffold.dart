import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/home_page.dart';
import '../favorites/favorites_page.dart';
import '../history/history_page.dart';
import '../booking/booking_page.dart';
import '../profile/profile_page.dart';
import '../notifications/notifications_page.dart';
import '../settings/pages/customer_support_page.dart';
import '../../widgets/CustomBottomNavBar.dart';
import '../../config/dynamic_config.dart';

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _currentIndex = 0; // Start with home page (index 0)

  final List<Widget> _pages = [
    HomePage(),
    BookingPage(),
    HistoryPage(),
    FavoritesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    print('=== MAIN SCAFFOLD BUILD ===');
    print('Current index: $_currentIndex');
    print('Building page: ${_pages[_currentIndex].runtimeType}');
    
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          print('Bottom nav tapped: $index');
          setState(() {
            _currentIndex = index;
          });
        },
        itemOrder: const [0, 1, 2, 3], // Home, Booking, History, Favorites
      ),
    );
  }
}
