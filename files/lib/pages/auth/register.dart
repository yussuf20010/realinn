import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/wp_config.dart';
import '../../config/constants/app_styles.dart';
import '../../config/routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../models/country.dart';
import '../home/components/country_selector_widget.dart';

enum PasswordStrength {
  empty,
  weak,
  medium,
  strong,
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _countryCodeController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  Country? _selectedCountry;
  bool _isCreating = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _countryCodeController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
    _usernameController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    _phoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleShowPassword() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  void _toggleShowConfirmPassword() {
    setState(() {
      _showConfirmPassword = !_showConfirmPassword;
    });
  }

  PasswordStrength _getPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.empty;
    if (password.length < 8) return PasswordStrength.weak;

    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    if (strength <= 2) return PasswordStrength.weak;
    if (strength <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  bool _areAllFieldsValid() {
    return _usernameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text.length >= 8 &&
        _passwordController.text == _confirmPasswordController.text;
  }

  Future<void> _register() async {
    if (_isCreating) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final phone = _selectedCountry != null && _phoneController.text.isNotEmpty
          ? '${_selectedCountry!.dialCode}${_phoneController.text.trim()}'
          : null;

      final res = await AuthService.signup(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phone: phone,
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );

      if (mounted) {
        // Navigate to verify page with email
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.verifyCode,
          arguments: {
            'email': _emailController.text.trim(),
            'userId': res.userId ?? res.user?.id ?? 0,
          },
        );
      }
    } catch (e) {
      String errorMsg = _extractErrorMessage(e);
      setState(() {
        _errorMessage = errorMsg;
        _isCreating = false;
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

  Widget _buildPasswordStrengthIndicator() {
    final strength = _getPasswordStrength(_passwordController.text);

    String label;
    Color color;
    double percentage;

    switch (strength) {
      case PasswordStrength.empty:
        return SizedBox.shrink();
      case PasswordStrength.weak:
        label = 'Weak';
        color = Colors.red;
        percentage = 0.33;
        break;
      case PasswordStrength.medium:
        label = 'Medium';
        color = Colors.orange;
        percentage = 0.66;
        break;
      case PasswordStrength.strong:
        label = 'Strong';
        color = Colors.green;
        percentage = 1.0;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(2.r),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percentage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          _getPasswordRequirements(_passwordController.text),
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getPasswordRequirements(String password) {
    List<String> missing = [];

    if (password.length < 8) {
      missing.add('8+ characters');
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      missing.add('lowercase');
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      missing.add('uppercase');
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      missing.add('number');
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      missing.add('special character');
    }

    if (missing.isEmpty) {
      return '✓ Password meets all requirements';
    }

    return 'Need: ${missing.join(", ")}';
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
                            'Create Account',
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
                            controller: _usernameController,
                            decoration: AppStyles.inputDecoration(
                              label: 'username'.tr(),
                              icon: IconlyLight.profile,
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'username_required'.tr()
                                : null,
                            textInputAction: TextInputAction.next,
                            onChanged: (value) => setState(() {}),
                          ),
                          SizedBox(height: 12.h),
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
                            textInputAction: TextInputAction.next,
                            onChanged: (value) => setState(() {}),
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: GestureDetector(
                                  onTap: () {
                                    CountrySelectorModal.show(
                                      context,
                                      selectedDialCode:
                                          _selectedCountry?.dialCode,
                                      onCountrySelected: (country) {
                                        setState(() {
                                          _selectedCountry = country;
                                          _countryCodeController.text =
                                              country.dialCode;
                                        });
                                      },
                                    );
                                  },
                                  child: AbsorbPointer(
                                    child: TextFormField(
                                      readOnly: true,
                                      controller: _countryCodeController,
                                      decoration: InputDecoration(
                                        labelText: 'country_code'.tr(),
                                        hintText: 'country_code'.tr(),
                                        filled: true,
                                        fillColor: AppStyles.fieldFill,
                                        prefixIcon: _selectedCountry != null
                                            ? Padding(
                                                padding:
                                                    EdgeInsets.only(left: 16.w),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 12.h),
                                                  child: Text(
                                                    _selectedCountry!.flag,
                                                    style: TextStyle(
                                                        fontSize: 18.sp),
                                                  ),
                                                ),
                                              )
                                            : Icon(
                                                IconlyLight.call,
                                                color: AppStyles.mainBlue,
                                              ),
                                        suffixIcon: Icon(
                                          Icons.arrow_drop_down,
                                          color: AppStyles.mainBlue,
                                          size: 24.sp,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              AppStyles.borderRadius),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              AppStyles.borderRadius),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              AppStyles.borderRadius),
                                          borderSide: BorderSide(
                                              color: AppStyles.mainBlue,
                                              width: 2),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 18.h, horizontal: 16.w),
                                      ),
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: _phoneController,
                                  decoration: AppStyles.inputDecoration(
                                      label:
                                          'mobile_number'.tr() + ' (Optional)',
                                      icon: IconlyLight.call),
                                  validator: (v) => null, // Phone is optional
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (value) => setState(() {}),
                                ),
                              ),
                            ],
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
                                  _showPassword
                                      ? IconlyLight.show
                                      : IconlyLight.hide,
                                  color: AppStyles.mainBlue,
                                ),
                                onPressed: _toggleShowPassword,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'password_required'.tr();
                              }
                              if (v.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),
                          if (_passwordController.text.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            _buildPasswordStrengthIndicator(),
                          ],
                          SizedBox(height: 12.h),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_showConfirmPassword,
                            decoration: AppStyles.inputDecoration(
                              label: 'confirm_password'.tr(),
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
                                return 'confirm_password_required'.tr();
                              }
                              if (v != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _register(),
                            onChanged: (value) => setState(() {}),
                          ),
                          if (_confirmPasswordController.text.isNotEmpty &&
                              _passwordController.text.isNotEmpty &&
                              _confirmPasswordController.text !=
                                  _passwordController.text) ...[
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
                                onTap: _areAllFieldsValid() && !_isCreating
                                    ? _register
                                    : null,
                                child: Opacity(
                                  opacity: _areAllFieldsValid() ? 1.0 : 0.5,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 16.h),
                                    child: Center(
                                      child: _isCreating
                                          ? CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                          : Text(
                                              'Create Account',
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
                                "Already have an account? Sign In",
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
}
