import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/wp_config.dart';
import '../../config/constants/app_colors.dart';
import '../../config/routes/app_routes.dart';
import '../../services/token_storage_service.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage> {
  User? _user;
  String? _userType;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await TokenStorageService.getUser();
      final userType = await TokenStorageService.getUserType();
      if (mounted) {
        setState(() {
          _user = user;
          _userType = userType;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getWelcomeTitle() {
    if (_userType == 'hotel') {
      return 'welcome.hotel_title'.tr();
    } else if (_userType == 'service_provider') {
      return 'welcome.service_provider_title'.tr();
    }
    return 'welcome.title'.tr();
  }

  String _getWelcomeMessage() {
    if (_userType == 'hotel') {
      return 'welcome.hotel_message'.tr();
    } else if (_userType == 'service_provider') {
      return 'welcome.service_provider_message'.tr();
    }
    return 'welcome.message'.tr();
  }

  IconData _getWelcomeIcon() {
    if (_userType == 'hotel') {
      return Icons.hotel;
    } else if (_userType == 'service_provider') {
      return Icons.handyman;
    }
    return Icons.person;
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'logout'.tr(),
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'are_you_sure_logout'.tr(),
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'cancel'.tr(),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: Text(
                'logout'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && mounted) {
      // Handle logout - clear all data
      await AuthService.logout();
      if (mounted) {
        // Navigate to initial route which will check auth state and route to login
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.initial, (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primary(context);
    final isTablet = MediaQuery.of(context).size.width >= 768;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Center(
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        ),
      );
    }

    return WillPopScope(
        onWillPop: () async {
          // Prevent back navigation for SP/hotel users - they should only see this page
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: primaryColor,
            elevation: 0,
            automaticallyImplyLeading: false, // Remove back button
            title: Text(
              'dashboard'.tr(),
              style: TextStyle(
                fontSize: isTablet ? 24.sp : 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: isTablet ? 26.sp : 24.sp,
                ),
                tooltip: 'logout'.tr(),
                onPressed: () => _handleLogout(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 32.w : 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 32.h),
                  // Welcome Icon
                  Center(
                    child: Container(
                      width: isTablet ? 120.w : 100.w,
                      height: isTablet ? 120.w : 100.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withOpacity(0.1),
                      ),
                      child: Icon(
                        _getWelcomeIcon(),
                        size: isTablet ? 60 : 50,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  // Welcome Title
                  Text(
                    'welcome.greeting'.tr(),
                    style: TextStyle(
                      fontSize: isTablet ? 32.sp : 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  // User Name
                  if (_user?.name != null && _user!.name!.isNotEmpty)
                    Text(
                      _user!.name!,
                      style: TextStyle(
                        fontSize: isTablet ? 24.sp : 20.sp,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  SizedBox(height: 24.h),
                  // Welcome Message
                  Container(
                    padding: EdgeInsets.all(isTablet ? 24.w : 20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getWelcomeMessage(),
                          style: TextStyle(
                            fontSize: isTablet ? 16.sp : 14.sp,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        // User Info Section
                        _buildInfoSection(
                          Icons.person,
                          'welcome.account_type'.tr(),
                          _userType == 'hotel'
                              ? 'welcome.hotel'.tr()
                              : _userType == 'service_provider'
                                  ? 'welcome.service_provider'.tr()
                                  : 'welcome.user'.tr(),
                          isTablet,
                        ),
                        if (_user?.email != null) ...[
                          SizedBox(height: 16.h),
                          _buildInfoSection(
                            Icons.email,
                            'welcome.email'.tr(),
                            _user!.email!,
                            isTablet,
                          ),
                        ],
                        if (_user?.phone != null) ...[
                          SizedBox(height: 16.h),
                          _buildInfoSection(
                            Icons.phone,
                            'welcome.phone'.tr(),
                            _user!.phone!,
                            isTablet,
                          ),
                        ],
                        if (_user?.country != null || _user?.city != null) ...[
                          SizedBox(height: 16.h),
                          _buildInfoSection(
                            Icons.location_on,
                            'welcome.location'.tr(),
                            '${_user?.city ?? ''}${_user?.city != null && _user?.country != null ? ', ' : ''}${_user?.country ?? ''}',
                            isTablet,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildInfoSection(
      IconData icon, String label, String value, bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: isTablet ? 20.sp : 18.sp,
          color: AppColors.primary(context),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isTablet ? 12.sp : 11.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: isTablet ? 14.sp : 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
