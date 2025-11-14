import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/wp_config.dart';
import '../../config/constants/app_styles.dart';
import '../../config/routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/token_storage_service.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  bool _isLoggingIn = false;
  bool _showPassword = false;
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  String? _selectedUserType; // 'user', 'hotel', 'service_provider'
  bool _showLoginForm = false; // Track if we're on step 2

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _loadSelectedUserType();
  }

  Future<void> _loadSelectedUserType() async {
    final savedType = await TokenStorageService.getSelectedUserType();
    if (savedType != null && mounted) {
      setState(() {
        _selectedUserType = savedType;
        _showLoginForm =
            true; // Automatically show login form if type was saved
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleShowPassword() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  Future<void> _login() async {
    if (_isLoggingIn) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoggingIn = true;
      _errorMessage = null;
    });

    try {
      await AuthService.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      // Save user type if selected (permanent)
      if (_selectedUserType != null) {
        await TokenStorageService.saveUserType(_selectedUserType!);
      }

      // Clear temporary selected user type after successful login
      await TokenStorageService.clearSelectedUserType();

      if (mounted) {
        // Check user type and navigate accordingly
        final userType = await TokenStorageService.getUserType();
        if (userType == 'hotel' || userType == 'service_provider') {
          // Navigate to initial route which will show welcome page
          Navigator.of(context).pushReplacementNamed(AppRoutes.initial);
        } else {
          // Regular users go to home page
          Navigator.of(context).pushReplacementNamed(AppRoutes.homePage);
        }
      }
    } catch (e) {
      String errorMsg = _extractErrorMessage(e);
      setState(() {
        _errorMessage = errorMsg;
        _isLoggingIn = false;
      });
    }
  }

  String _extractErrorMessage(dynamic error) {
    String errorString = error.toString();
    // Remove "Exception: " prefix if present
    errorString = errorString.replaceAll('Exception: ', '');
    // Check if it's a JSON string that can be parsed
    try {
      if (errorString.contains('{') && errorString.contains('}')) {
        final jsonMatch = RegExp(r'\{[^}]+\}').firstMatch(errorString);
        if (jsonMatch != null) {
          final jsonStr = jsonMatch.group(0);
          if (jsonStr != null) {
            final json = jsonDecode(jsonStr) as Map<String, dynamic>;
            // Try to get error message from common API error formats
            return json['error']?.toString() ??
                json['message']?.toString() ??
                json['errors']?.toString() ??
                json['detail']?.toString() ??
                errorString;
          }
        }
      }
    } catch (_) {
      // If parsing fails, return original message
    }
    return errorString;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: screenWidth,
            height: screenHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2D0C4E), WPConfig.primaryColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 8,
                  margin: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
                    child: _showLoginForm
                        ? _buildLoginForm()
                        : _buildUserTypeSelection(),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40.h,
            right: 24.w,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.homePage);
              },
              child: Text(
                'skip'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'auth.select_user_type'.tr(),
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32.h),
        // Three buttons of same size
        _buildUserTypeButton(
          label: 'auth.user'.tr(),
          type: 'user',
          icon: Icons.person,
        ),
        SizedBox(height: 16.h),
        _buildUserTypeButton(
          label: 'auth.hotel'.tr(),
          type: 'hotel',
          icon: Icons.hotel,
        ),
        SizedBox(height: 16.h),
        _buildUserTypeButton(
          label: 'auth.service_provider'.tr(),
          type: 'service_provider',
          icon: Icons.business,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () async {
                  // Clear selected user type when going back
                  await TokenStorageService.clearSelectedUserType();
                  setState(() {
                    _showLoginForm = false;
                    _selectedUserType = null;
                    _errorMessage = null;
                  });
                },
              ),
              Expanded(
                child: Text(
                  'auth.sign_in'.tr(),
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 48.w), // Balance the back button
            ],
          ),
          SizedBox(height: 8.h),
          // Show selected user type
          if (_selectedUserType != null)
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: WPConfig.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _selectedUserType == 'user'
                        ? Icons.person
                        : _selectedUserType == 'hotel'
                            ? Icons.hotel
                            : Icons.business,
                    color: WPConfig.primaryColor,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _selectedUserType == 'user'
                        ? 'auth.user'.tr()
                        : _selectedUserType == 'hotel'
                            ? 'auth.hotel'.tr()
                            : 'auth.service_provider'.tr(),
                    style: TextStyle(
                      color: WPConfig.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 24.h),
          if (_errorMessage != null) ...[
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],
          TextFormField(
            controller: _usernameController,
            decoration: AppStyles.inputDecoration(
              label: 'username'.tr(),
              icon: IconlyLight.profile,
            ),
            validator: (v) =>
                v == null || v.isEmpty ? 'username_required'.tr() : null,
            textInputAction: TextInputAction.next,
            autofillHints: [AutofillHints.username],
          ),
          SizedBox(height: 12.h),
          TextFormField(
            controller: _passwordController,
            obscureText: !_showPassword,
            decoration: AppStyles.inputDecoration(
              label: 'password'.tr(),
              icon: IconlyLight.password,
              suffixIcon: IconButton(
                icon: Icon(
                  _showPassword ? IconlyLight.show : IconlyLight.hide,
                  color: AppStyles.mainBlue,
                ),
                onPressed: _toggleShowPassword,
              ),
            ),
            validator: (v) =>
                v == null || v.isEmpty ? 'password_required'.tr() : null,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _login(),
            autofillHints: [AutofillHints.password],
          ),
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.forgotPass);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppStyles.mainBlue,
              ),
              child: Text(
                'forgot_pass'.tr(),
                style: TextStyle(
                  color: AppStyles.mainBlue,
                  fontSize: 14.sp,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2196F3), WPConfig.primaryColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(AppStyles.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                onTap: _isLoggingIn ? null : _login,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Center(
                    child: _isLoggingIn
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            'auth.sign_in'.tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterPage(
                      initialUserType: _selectedUserType,
                    ),
                  ),
                );
              },
              child: Text(
                'auth.dont_have_account'.tr(),
                style: TextStyle(
                  color: AppStyles.mainBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeButton({
    required String label,
    required String type,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () async {
        // Save selected user type
        await TokenStorageService.saveSelectedUserType(type);
        setState(() {
          _selectedUserType = type;
          _showLoginForm = true;
        });
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: WPConfig.primaryColor,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
