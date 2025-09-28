import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../config/wp_config.dart';
import '../config/dynamic_config.dart';
import '../core/constants/assets.dart';
import '../pages/profile/profile_page.dart';
import '../pages/customer_service/customer_service_page.dart';

class CustomAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onChatPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onNotificationPressed;
  final bool minimal; // Add this line
  final bool backAndLogoOnly;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.onChatPressed,
    this.onProfilePressed,
    this.onNotificationPressed,
    this.minimal = false, // Add this line
    this.backAndLogoOnly = false,
  }) : super(key: key);

  @override
  Size get preferredSize =>
      Size.fromHeight(70); // base; overridden in build for tablets

  @override
  ConsumerState<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends ConsumerState<CustomAppBar> {
  void _toggleLanguage() async {
    final currentLocale = context.locale;
    final newLocale = currentLocale.languageCode == 'ar'
        ? Locale('en', 'US')
        : Locale('ar', 'SA');

    print('=== LANGUAGE TOGGLE DEBUG ===');
    print('Current locale: ${currentLocale.languageCode}');
    print('Current full locale: $currentLocale');
    print('New locale: ${newLocale.languageCode}');
    print('New full locale: $newLocale');
    print('Context mounted: ${context.mounted}');

    try {
      // Set the new locale directly without confirmation
      print('Setting new locale...');
      await context.setLocale(newLocale);
      print('Locale set successfully to: ${newLocale.languageCode}');

      // Force a rebuild by calling setState
      print('Calling setState...');
      setState(() {});

      // Also force a rebuild of the entire app to ensure RTL is applied
      if (context.mounted) {
        print('Navigating to home page to force app rebuild...');
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      } else {
        print('Context not mounted, cannot navigate');
      }
    } catch (e) {
      print('Error setting locale: $e');
      print('Error stack trace: ${StackTrace.current}');
      // Show error dialog
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to change language: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(),
      ),
    );
  }

  void _openCustomerSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerServicePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final toolbarHeight = isTablet ? 80.0 : 64.0;
    ref.watch(dynamicConfigProvider);
    final primaryColor = WPConfig.navbarColor; // Use constant color directly

    if (widget.backAndLogoOnly) {
      return AppBar(
        backgroundColor: primaryColor,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        toolbarHeight: toolbarHeight,
        leading: widget.showBackButton
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: Image.asset(
          AssetsManager.appbar,
          height: isTablet ? 64 : 40,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          // Simple Language Toggle for backAndLogoOnly mode
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _toggleLanguage,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    context.locale.languageCode.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (widget.minimal) {
      return AppBar(
        backgroundColor: primaryColor,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        toolbarHeight: toolbarHeight,
        leading: widget.showBackButton
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: Center(
          child: Text(
            'chat'.tr(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 26 : 20,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          // Simple Language Toggle for minimal mode
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _toggleLanguage,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    context.locale.languageCode.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return AppBar(
      backgroundColor: primaryColor,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      toolbarHeight: toolbarHeight,
      leading: widget.showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : !widget.showBackButton
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.person_outline,
                          color: Colors.white, size: isTablet ? 24 : 20),
                      onPressed: _openProfile,
                    ),
                    IconButton(
                      icon: Icon(Icons.support_agent_outlined,
                          color: Colors.white, size: isTablet ? 24 : 20),
                      onPressed: _openCustomerSupport,
                    ),
                  ],
                )
              : null,
      leadingWidth: widget.showBackButton ? null : (isTablet ? 120 : 100),
      title: Image.asset(
        AssetsManager.appbar,
        height: isTablet ? 30 : 30,
        fit: BoxFit.contain,
      ),
      centerTitle: true,
      actions: [
        if (widget.onNotificationPressed != null)
          IconButton(
            icon: Icon(Icons.notifications_outlined,
                color: Colors.white, size: isTablet ? 24 : 20),
            onPressed: widget.onNotificationPressed,
          ),
      ],
    );
  }
}
