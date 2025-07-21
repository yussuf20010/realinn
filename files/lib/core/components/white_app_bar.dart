import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:dio/dio.dart';
import '../constants/app_defaults.dart';
import '../repositories/auth/auth_repository.dart';
import '../routes/app_routes.dart';
import 'headline_with_row.dart';

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
    return _userToken != null && _userToken!.isNotEmpty;
  }

  void _handleProfilePressed(BuildContext context) {
    bool isLoggedIn = checkIfLoggedIn();
    if (isLoggedIn) {
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
              _loadUserToken();
              widget.onRefresh?.call();
            },
          ),
        if (widget.showProfileIcon)
          IconButton(
            onPressed: () => _handleProfilePressed(context),
            icon: const Icon(IconlyLight.profile, color: Colors.black),
          ),
      ],
    );
  }
} 