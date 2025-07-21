import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:realinn/pages/profile/profile_page.dart';
import 'package:realinn/pages/booking/booking_page.dart';
import 'package:realinn/pages/favorites/favorites_page.dart';
import '../../core/repositories/auth/auth_repository.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/CustomBottomNavBar.dart';
import '../home/home_page.dart';
import '../settings/settings_page.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final Widget? child;
  const MainScaffold({Key? key, this.child}) : super(key: key);

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _selectedIndex = 0;
  final AuthRepository _authRepository = AuthRepository(Dio());
  String? _userToken;

  @override
  void initState() {
    super.initState();
    _loadUserToken();
  }

  Future<void> _loadUserToken() async {
    _userToken = await _authRepository.getToken();
    setState(() {});
  }

  bool checkIfLoggedIn() {
    final isLoggedIn = _userToken != null && _userToken!.isNotEmpty;
    return isLoggedIn;
  }

  void _handleNavigation(int newIndex) {
    if (newIndex >= 0 && newIndex < _pages.length) {
      if (newIndex == 3) { // Profile tab index
        setState(() {
          _selectedIndex = newIndex;
        });
      } else {
        setState(() {
          _selectedIndex = newIndex;
        });
      }
    }
  }

  final List<Widget> _pages = [
    HomePage(),
    BookingPage(),
    FavoritesPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    print('MainScaffold: Building with selected index $_selectedIndex');
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _handleNavigation,
      ),
    );
  }
}
