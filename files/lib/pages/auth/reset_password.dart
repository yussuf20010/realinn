import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/wp_config.dart';
import '../../config/constants/app_styles.dart';
import '../../config/routes/app_routes.dart';
import '../../services/auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  final String? resetToken;
  final String? email;

  const ResetPasswordPage({
    Key? key,
    this.resetToken,
    this.email,
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

  int _resendTimer = 60;
  bool _canResend = false;
  bool _isResending = false;

  void _startResendTimer() {
    _canResend = false;
    _resendTimer = 60;
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      if (mounted && _resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
        return true;
      } else {
        if (mounted) {
          setState(() {
            _canResend = true;
          });
        }
        return false;
      }
    });
  }

  Future<void> _resendCode() async {
    if (!_canResend || _isResending) return;
    if (widget.email == null || widget.email!.isEmpty) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await AuthService.forgotPassword(email: widget.email!.trim());
      if (mounted) {
        setState(() {
          _successMessage = 'Verification code has been resent to ${widget.email}';
          _isResending = false;
        });
        _startResendTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isResending = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _newPasswordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));

    if (widget.email != null && widget.email!.isNotEmpty) {
      _startResendTimer();
    }
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
    final hasToken = (widget.resetToken != null && widget.resetToken!.isNotEmpty) ||
        _codeController.text.isNotEmpty;
    return hasToken &&
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
        resetToken: widget.resetToken ?? _codeController.text.trim(),
        newPassword: _newPasswordController.text,
        newPasswordConfirmation: _confirmPasswordController.text,
      );

      if (mounted) {
        setState(() {
          _successMessage = 'auth.password_reset_success'.tr();
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
                            'auth.reset_password'.tr(),
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
                          if (widget.resetToken == null || widget.resetToken!.isEmpty)
                            TextFormField(
                              controller: _codeController,
                              decoration: AppStyles.inputDecoration(
                                label: 'auth.reset_token'.tr(),
                                icon: IconlyLight.lock,
                              ),
                              validator: (v) => (widget.resetToken == null || widget.resetToken!.isEmpty) && (v == null || v.isEmpty)
                                  ? 'auth.reset_token_required'.tr()
                                  : null,
                              textInputAction: TextInputAction.next,
                            ),
                          if (widget.resetToken == null || widget.resetToken!.isEmpty)
                            if (widget.email != null && widget.email!.isNotEmpty) ...[
                              SizedBox(height: 4.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _isResending
                                      ? SizedBox(
                                          width: 16.w,
                                          height: 16.w,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    AppStyles.mainBlue),
                                          ),
                                        )
                                      : TextButton(
                                          onPressed: _canResend ? _resendCode : null,
                                          child: Text(
                                            _canResend
                                                ? 'resend_code'.tr()
                                                : '${'resend_code'.tr()} (${_resendTimer}s)',
                                            style: TextStyle(
                                              color: _canResend
                                                  ? AppStyles.mainBlue
                                                  : Colors.grey,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ],
                          if (widget.resetToken == null || widget.resetToken!.isEmpty)
                            SizedBox(height: 12.h),
                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: !_showNewPassword,
                            decoration: AppStyles.inputDecoration(
                              label: 'auth.new_password'.tr(),
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
                                return 'auth.new_password_required'.tr();
                              }
                              if (v.length < 8) {
                                return 'auth.password_min_length'.tr();
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
                              label: 'auth.confirm_new_password'.tr(),
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
                                return 'auth.please_confirm_password'.tr();
                              }
                              if (v != _newPasswordController.text) {
                                return 'auth.passwords_do_not_match'.tr();
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
                                    'auth.passwords_do_not_match'.tr(),
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
                                              'auth.reset_password'.tr(),
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
                                'auth.back_to_sign_in'.tr(),
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
