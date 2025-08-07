import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../config/wp_config.dart';
import '../config/dynamic_config.dart';
import '../pages/settings/pages/customer_support_page.dart';
import '../pages/profile/profile_page.dart';

class CustomAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onChatPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onNotificationPressed;
  final bool minimal; // Add this line

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.onChatPressed,
    this.onProfilePressed,
    this.onNotificationPressed,
    this.minimal = false, // Add this line
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(70); // Increased height by 10px

  @override
  ConsumerState<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends ConsumerState<CustomAppBar> {
  void _toggleLanguage() async {
    final currentLocale = context.locale;
    final newLocale = currentLocale.languageCode == 'ar'
        ? Locale('en', 'US')
        : Locale('ar', 'SA');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Language'),
        content: Text('Do you want to change the app language?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('OK'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await context.setLocale(newLocale);
      // Reload the app by pushing replacement to HomePage
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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
        builder: (context) => CustomerSupportPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final primaryColor = dynamicConfig.primaryColor ?? WPConfig.primaryColor;

    if (widget.minimal) {
      return AppBar(
        backgroundColor: primaryColor,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        toolbarHeight: 70,
        leading: widget.showBackButton
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: Center(
          child: Text(
            'Chat',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 24 : 20,
            ),
          ),
        ),
        centerTitle: true,
      );
    }

    return AppBar(
      backgroundColor: primaryColor,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      toolbarHeight: 70, // Increased height
      leading: null,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Profile and Chat
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: isTablet ? 26 : 22,
                ),
                onPressed: widget.onProfilePressed ?? _openProfile,
              ),
              IconButton(
                icon: Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: isTablet ? 26 : 22,
                ),
                onPressed: widget.onChatPressed ?? _openCustomerSupport,
              ),
            ],
          ),
          // Center: Title or Logo
          Expanded(
            child: Center(
              child: Builder(
                builder: (context) {
                  if (dynamicConfig.logoUrl != null && dynamicConfig.logoUrl!.isNotEmpty) {
                    return Image.network(
                      dynamicConfig.logoUrl!,
                      height: isTablet ? 30 : 25,
                      fit: BoxFit.contain,
                    );
                  } else if (dynamicConfig.appName != null) {
                    return Text(
                      dynamicConfig.appName!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: isTablet ? 24 : 20,
                      ),
                    );
                  } else {
                    return Text(
                      widget.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 24 : 20,
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          // Right side: Language and Notification
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _toggleLanguage,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(
                        context.locale.languageCode == 'ar' ? 'AR' : 'EN',
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
              if (widget.onNotificationPressed != null)
                IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: isTablet ? 26 : 22,
                  ),
                  onPressed: widget.onNotificationPressed,
                ),
            ],
          ),
        ],
      ),
      centerTitle: true,
      actions: [SizedBox(width: 8)],
    );
  }
} 