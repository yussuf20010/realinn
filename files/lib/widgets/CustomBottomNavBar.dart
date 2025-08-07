import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/dynamic_config.dart';
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
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final primaryColor = dynamicConfig.primaryColor ?? Color(0xFF7371FC);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    return Container(
      decoration: BoxDecoration(
        color: primaryColor, // Use primary color as background
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
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 36 : 20, vertical: isTablet ? 18 : 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildNavItems(primaryColor, isTablet),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavItems(Color primaryColor, bool isTablet) {
    final keys = ['home', 'booking', 'history', 'favourite'];
    final icons = [Icons.home, Icons.book, Icons.history, Icons.favorite];
    final order = itemOrder ?? [0, 1, 2, 3];
    return order.map((i) => _buildNavItem(i, icons[i], keys[i].tr(), primaryColor, isTablet)).toList();
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color primaryColor, bool isTablet) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 12, vertical: isTablet ? 12 : 8),
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
              size: isTablet ? 32 : 24,
            ),
            SizedBox(height: isTablet ? 8 : 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                fontSize: isTablet ? 14 : 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 