import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import '../constants/app_defaults.dart';
import '../routes/app_routes.dart';
import 'headline_with_row.dart';
import '../../services/auth_service.dart';

class WhiteAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showProfileIcon;
  final bool forceElevated;
  final VoidCallback? onRefresh;

  const WhiteAppBar({
    Key? key,
    required this.title,
    this.showProfileIcon = true,
    this.forceElevated = false,
    this.onRefresh,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  _WhiteAppBarState createState() => _WhiteAppBarState();
}

class _WhiteAppBarState extends State<WhiteAppBar> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = isLoggedIn;
      });
    }
  }

  void _handleProfilePressed(BuildContext context) async {
    await _checkAuthStatus();
    if (_isLoggedIn) {
      Navigator.pushNamed(context, AppRoutes.profile);
    } else {
      Navigator.pushNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDefaults.padding,
              vertical: 8.0,
            ),
            child: HeadlineRow(headline: widget.title),
          ),
        ],
      ),
      actions: [
        if (widget.onRefresh != null)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              widget.onRefresh?.call();
            },
          ),
        if (widget.showProfileIcon)
          FutureBuilder<bool>(
            future: AuthService.isLoggedIn(),
            builder: (context, snapshot) {
              final isLoggedIn = snapshot.data ?? false;
              return IconButton(
                onPressed: () => _handleProfilePressed(context),
                icon: Icon(
                  isLoggedIn ? IconlyLight.profile : IconlyLight.login,
                  color: Colors.black,
                ),
              );
            },
          ),
      ],
    );
  }
}
