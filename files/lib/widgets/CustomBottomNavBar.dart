import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/dynamic_config.dart';
import '../config/wp_config.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomBottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<int>? itemOrder;

  CustomBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    this.itemOrder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    return Container(
      decoration: BoxDecoration(
        color: WPConfig.navbarColor, // Use constant navbar color
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isTablet ? 32 : 25),
          topRight: Radius.circular(isTablet ? 32 : 25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: isTablet ? 24 : 15,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16, vertical: isTablet ? 12 : 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildNavItems(isTablet),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavItems(bool isTablet) {
    final keys = ['home', 'booking', 'history', 'favourite'];
    final icons = [Icons.home, Icons.book, Icons.history, Icons.favorite];
    final order = itemOrder ?? [0, 1, 2, 3];
    return order.map((i) => _buildNavItem(i, icons[i], keys[i].tr(), isTablet)).toList();
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isTablet) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 10, vertical: isTablet ? 8 : 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(isTablet ? 28 : 20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              size: isTablet ? 40 : 36, // Made icons even bigger
            ),
            SizedBox(height: isTablet ? 6 : 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                fontSize: isTablet ? 12 : 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 