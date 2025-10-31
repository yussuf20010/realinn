import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/wp_config.dart';
import '../../config/constants/app_styles.dart';
import '../../config/routes/app_routes.dart';
import '../../services/auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String verificationCode;

  const ResetPasswordPage({
    Key? key,
    required this.email,
    required this.verificationCode,
  }) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  late TextEditingController _codeController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  bool _isResetting = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.verificationCode);
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _newPasswordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleShowNewPassword() {
    setState(() {
      _showNewPassword = !_showNewPassword;
    });
  }

  void _toggleShowConfirmPassword() {
    setState(() {
      _showConfirmPassword = !_showConfirmPassword;
    });
  }

  bool _areAllFieldsValid() {
    return _codeController.text.isNotEmpty &&
        _newPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _newPasswordController.text.length >= 8 &&
        _newPasswordController.text == _confirmPasswordController.text;
  }

  Future<void> _resetPassword() async {
    if (_isResetting) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isResetting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await AuthService.resetPassword(
        email: widget.email,
        verificationCode: _codeController.text.trim(),
        newPassword: _newPasswordController.text,
        newPasswordConfirmation: _confirmPasswordController.text,
      );

      if (mounted) {
        setState(() {
          _successMessage = 'Password reset successfully';
        });

        // Navigate to login after success
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.login);
          }
        });
      }
    } catch (e) {
      String errorMsg = _extractErrorMessage(e);
      setState(() {
        _errorMessage = errorMsg;
        _isResetting = false;
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Reset Password',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
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
                                  Icon(Icons.error_outline,
                                      color: Colors.red, size: 20.sp),
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
                          if (_successMessage != null) ...[
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8.r),
                                border:
                                    Border.all(color: Colors.green.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle_outline,
                                      color: Colors.green, size: 20.sp),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      _successMessage!,
                                      style: TextStyle(
                                        color: Colors.green.shade700,
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
                            controller: _codeController,
                            decoration: AppStyles.inputDecoration(
                              label: 'Verification Code',
                              icon: IconlyLight.lock,
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Verification code is required'
                                : null,
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: 12.h),
                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: !_showNewPassword,
                            decoration: AppStyles.inputDecoration(
                              label: 'New Password',
                              icon: IconlyLight.password,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showNewPassword
                                      ? IconlyLight.show
                                      : IconlyLight.hide,
                                  color: AppStyles.mainBlue,
                                ),
                                onPressed: _toggleShowNewPassword,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'New password is required';
                              }
                              if (v.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: 12.h),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_showConfirmPassword,
                            decoration: AppStyles.inputDecoration(
                              label: 'Confirm New Password',
                              icon: IconlyLight.password,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showConfirmPassword
                                      ? IconlyLight.show
                                      : IconlyLight.hide,
                                  color: AppStyles.mainBlue,
                                ),
                                onPressed: _toggleShowConfirmPassword,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (v != _newPasswordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            onChanged: (value) => setState(() {}),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _resetPassword(),
                          ),
                          if (_confirmPasswordController.text.isNotEmpty &&
                              _newPasswordController.text.isNotEmpty &&
                              _confirmPasswordController.text !=
                                  _newPasswordController.text) ...[
                            SizedBox(height: 4.h),
                            Padding(
                              padding: EdgeInsets.only(left: 16.w),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Passwords do not match',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          SizedBox(height: 24.h),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF2196F3),
                                  WPConfig.primaryColor
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius:
                                  BorderRadius.circular(AppStyles.borderRadius),
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
                                borderRadius: BorderRadius.circular(
                                    AppStyles.borderRadius),
                                onTap: _areAllFieldsValid() && !_isResetting
                                    ? _resetPassword
                                    : null,
                                child: Opacity(
                                  opacity: _areAllFieldsValid() ? 1.0 : 0.5,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 16.h),
                                    child: Center(
                                      child: _isResetting
                                          ? CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                          : Text(
                                              'Reset Password',
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
                          ),
                          SizedBox(height: 12.h),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.login,
                                );
                              },
                              child: Text(
                                "Back to Sign In",
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
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
