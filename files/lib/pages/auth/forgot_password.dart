import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/wp_config.dart';
import '../../config/constants/app_styles.dart';
import '../../config/routes/app_routes.dart';
import '../../services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late TextEditingController _emailController;
  bool _isSending = false;
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (_isSending) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSending = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await AuthService.forgotPassword(
        email: _emailController.text.trim(),
      );

      if (mounted) {
        final verificationCode = response['verification_code']?.toString();

        // Navigate to reset password page with email and verification code
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.resetPass,
          arguments: {
            'email': _emailController.text.trim(),
            'verificationCode': verificationCode ?? '',
          },
        );
      }
    } catch (e) {
      String errorMsg = _extractErrorMessage(e);
      setState(() {
        _errorMessage = errorMsg;
        _isSending = false;
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
                            'Forgot Password',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            'forgot_pass_message'.tr(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[700],
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
                            controller: _emailController,
                            decoration: AppStyles.inputDecoration(
                              label: 'email'.tr(),
                              icon: IconlyLight.message,
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'email_required'.tr();
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(v)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _sendResetLink(),
                            autofillHints: [AutofillHints.email],
                          ),
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
                                onTap: _isSending ? null : _sendResetLink,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  child: Center(
                                    child: _isSending
                                        ? CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : Text(
                                            'Submit',
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
