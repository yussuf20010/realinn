import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/wp_config.dart';
import '../../config/constants/app_styles.dart';
import '../../config/constants/app_colors.dart';
import '../../config/routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/token_storage_service.dart';

class VerifyCodePage extends StatefulWidget {
  final String email;
  final int? userId;
  final int? vendorId;
  final String userType; // 'user', 'hotel', 'service_provider'

  const VerifyCodePage({
    Key? key,
    required this.email,
    required this.userId,
    this.vendorId,
    this.userType = 'user',
  }) : super(key: key);

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  late List<TextEditingController> _codeControllers;
  late List<FocusNode> _focusNodes;
  bool _isVerifying = false;
  String? _errorMessage;
  String? _successMessage;
  int _resendTimer = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _codeControllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

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

  String _getCode() {
    return _codeControllers.map((c) => c.text).join();
  }

  void _onCodeChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_getCode().length == 6) {
      _verifyCode();
    }
  }

  Future<void> _verifyCode() async {
    if (_isVerifying) return;

    final code = _getCode();
    if (code.length != 6) {
      setState(() {
        _errorMessage = 'auth.please_enter_valid_code'.tr();
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await AuthService.verifyOtp(
        userId: widget.userId,
        vendorId: widget.vendorId,
        otpCode: code,
        userType: widget.userType,
      );

      if (mounted) {
        setState(() {
          _successMessage = response.message;
        });

        // Clear temporary selected user type after successful verification
        await TokenStorageService.clearSelectedUserType();

        // If verification succeeded, user may be considered logged in (cookies set or user returned)
        // Check user type and navigate accordingly
        Future.delayed(Duration(milliseconds: 800), () async {
          if (mounted) {
            final userType = await TokenStorageService.getUserType();
            if (userType == 'hotel' || userType == 'service_provider') {
              // Navigate to initial route which will show welcome page
              Navigator.of(context).pushReplacementNamed(AppRoutes.initial);
            } else {
              // Regular users go to home page
              Navigator.of(context).pushReplacementNamed(AppRoutes.homePage);
            }
          }
        });
      }
    } catch (e) {
      String errorMsg = _extractErrorMessage(e);
      setState(() {
        _errorMessage = errorMsg;
        _isVerifying = false;
        // Clear code fields on error
        for (var controller in _codeControllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
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

  Future<void> _resendCode() async {
    if (!_canResend) return;

    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await AuthService.resendOtp(
        userId: widget.userId,
        userType: widget.userType,
      );

      if (mounted) {
        setState(() {
          _successMessage = response['message']?.toString() ??
              'Verification code resent to your email';
        });
        _startResendTimer();
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = _extractErrorMessage(e);
        setState(() {
          _errorMessage = errorMsg.isNotEmpty
              ? errorMsg
              : 'Failed to resend code. Please try again.';
        });
      }
    }
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
                colors: [Color(0xFF2D0C4E), AppColors.primary(context)],
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'auth.verify_email'.tr(),
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'auth.enter_6_digit_code'.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          widget.email,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
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
                              border: Border.all(color: Colors.green.shade200),
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
                        // Code input fields
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: TextField(
                                  controller: _codeControllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    filled: true,
                                    fillColor: AppStyles.fieldFill,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppStyles.borderRadius),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppStyles.borderRadius),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppStyles.borderRadius),
                                      borderSide: BorderSide(
                                        color: AppStyles.mainBlue,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) =>
                                      _onCodeChanged(index, value),
                                ),
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: 24.h),
                        if (_isVerifying)
                          Center(child: CircularProgressIndicator())
                        else
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF2196F3),
                                  AppColors.primary(context)
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
                                onTap:
                                    _getCode().length == 6 ? _verifyCode : null,
                                child: Opacity(
                                  opacity: _getCode().length == 6 ? 1.0 : 0.5,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 16.h),
                                    child: Center(
                                      child: Text(
                                        'auth.verify'.tr(),
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
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'auth.didnt_receive_code'.tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (_canResend)
                              GestureDetector(
                                onTap: _resendCode,
                                child: Text(
                                  'auth.resend'.tr(),
                                  style: TextStyle(
                                    color: AppStyles.mainBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              )
                            else
                              Text(
                                '${_resendTimer}s',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14.sp,
                                ),
                              ),
                          ],
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
        ],
      ),
    );
  }
}
