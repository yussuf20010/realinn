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
  final String? initialUserType; // User type selected from outside (login page)
  
  const RegisterPage({Key? key, this.initialUserType}) : super(key: key);

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
  // User type specific controllers
  late TextEditingController _nameController;
  late TextEditingController _hotelNameController;
  late TextEditingController _addressController;
  late TextEditingController _zipCodeController;
  late TextEditingController _displayNameController;
  late TextEditingController _taglineController;
  late TextEditingController _descriptionController;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  late TextEditingController _currencyController;
  Country? _selectedCountry;
  String? _selectedUserType; // 'user', 'hotel', 'service_provider'
  String? _selectedState;
  String? _selectedCity;
  int? _selectedCategoryId;
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
    _nameController = TextEditingController();
    _hotelNameController = TextEditingController();
    _addressController = TextEditingController();
    _zipCodeController = TextEditingController();
    _displayNameController = TextEditingController();
    _taglineController = TextEditingController();
    _descriptionController = TextEditingController();
    _minPriceController = TextEditingController();
    _maxPriceController = TextEditingController();
    _currencyController = TextEditingController(text: 'USD');
    // Use initialUserType from widget if provided, otherwise default to 'user'
    _selectedUserType = widget.initialUserType ?? 'user';

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
    _nameController.dispose();
    _hotelNameController.dispose();
    _addressController.dispose();
    _zipCodeController.dispose();
    _displayNameController.dispose();
    _taglineController.dispose();
    _descriptionController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _currencyController.dispose();
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
    bool baseValid = _usernameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text.length >= 8 &&
        _passwordController.text == _confirmPasswordController.text;
    
    if (_selectedUserType == 'hotel') {
      return baseValid && _hotelNameController.text.isNotEmpty;
    }
    
    return baseValid;
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

      Map<String, dynamic> response;
      int? userId;
      int? vendorId;
      String userType;

      if (_selectedUserType == 'hotel') {
        response = await AuthService.registerHotel(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
          phone: phone,
          hotelName: _hotelNameController.text.trim(),
          country: _selectedCountry?.name,
          city: _selectedCity,
          state: _selectedState,
          address: _addressController.text.trim(),
          zipCode: _zipCodeController.text.trim(),
        );
        vendorId = response['vendor_id'] is int
            ? response['vendor_id']
            : (response['vendor_id'] is String
                ? int.tryParse(response['vendor_id'])
                : null);
        userType = 'hotel';
      } else if (_selectedUserType == 'service_provider') {
        final skills = _descriptionController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        response = await AuthService.registerServiceProvider(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
          name: _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : null,
          displayName: _displayNameController.text.trim().isNotEmpty
              ? _displayNameController.text.trim()
              : null,
          tagline: _taglineController.text.trim().isNotEmpty
              ? _taglineController.text.trim()
              : null,
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          country: _selectedCountry?.name,
          city: _selectedCity,
          mainCategoryId: _selectedCategoryId,
          skills: skills.isNotEmpty ? skills : null,
          minPrice: _minPriceController.text.trim().isNotEmpty
              ? double.tryParse(_minPriceController.text.trim())
              : null,
          maxPrice: _maxPriceController.text.trim().isNotEmpty
              ? double.tryParse(_maxPriceController.text.trim())
              : null,
          currency: _currencyController.text.trim().isNotEmpty
              ? _currencyController.text.trim()
              : 'USD',
        );
        userId = response['user_id'] is int
            ? response['user_id']
            : (response['user_id'] is String
                ? int.tryParse(response['user_id'])
                : null);
        userType = 'service_provider';
      } else {
        // Default to user
        response = await AuthService.registerUser(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
          name: _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : null,
        );
        userId = response['user_id'] is int
            ? response['user_id']
            : (response['user_id'] is String
                ? int.tryParse(response['user_id'])
                : null);
        userType = 'user';
      }

      if (mounted) {
        // Navigate to verify page
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.verifyCode,
          arguments: {
            'email': _emailController.text.trim(),
            'userId': userId,
            'vendorId': vendorId,
            'userType': userType,
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
        label = 'auth.password_strength_weak'.tr();
        color = Colors.red;
        percentage = 0.33;
        break;
      case PasswordStrength.medium:
        label = 'auth.password_strength_medium'.tr();
        color = Colors.orange;
        percentage = 0.66;
        break;
      case PasswordStrength.strong:
        label = 'auth.password_strength_strong'.tr();
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
      missing.add('auth.password_8_chars'.tr());
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      missing.add('auth.password_lowercase'.tr());
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      missing.add('auth.password_uppercase'.tr());
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      missing.add('auth.password_number'.tr());
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      missing.add('auth.password_special'.tr());
    }

    if (missing.isEmpty) {
      return 'auth.password_meets_requirements'.tr();
    }

    return 'auth.password_requirements'.tr(args: [missing.join(", ")]);
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
                            'auth.create_account'.tr(),
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24.h),
                          // User Type Selection - only show if not provided from outside
                          if (widget.initialUserType == null) ...[
                            Text(
                              'auth.register_as'.tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildUserTypeButton(
                                    label: 'auth.user'.tr(),
                                    type: 'user',
                                    icon: Icons.person,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: _buildUserTypeButton(
                                    label: 'auth.hotel'.tr(),
                                    type: 'hotel',
                                    icon: Icons.hotel,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: _buildUserTypeButton(
                                    label: 'auth.service_provider'.tr(),
                                    type: 'service_provider',
                                    icon: Icons.business,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),
                          ] else ...[
                            // Show selected user type badge if provided from outside
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
                          ],
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
                          // Name field (for user and service provider)
                          if (_selectedUserType == 'user' || _selectedUserType == 'service_provider')
                            TextFormField(
                              controller: _nameController,
                              decoration: AppStyles.inputDecoration(
                                label: 'auth.full_name'.tr(),
                                icon: IconlyLight.profile,
                              ),
                              textInputAction: TextInputAction.next,
                              onChanged: (value) => setState(() {}),
                            ),
                          if (_selectedUserType == 'user' || _selectedUserType == 'service_provider')
                            SizedBox(height: 12.h),
                          // Hotel Name (for hotel)
                          if (_selectedUserType == 'hotel')
                            TextFormField(
                              controller: _hotelNameController,
                              decoration: AppStyles.inputDecoration(
                                label: 'auth.hotel_name_label'.tr(),
                                icon: Icons.hotel,
                              ),
                              validator: (v) => _selectedUserType == 'hotel' && (v == null || v.isEmpty)
                                  ? 'auth.hotel_name_required'.tr()
                                  : null,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) => setState(() {}),
                            ),
                          if (_selectedUserType == 'hotel')
                            SizedBox(height: 12.h),
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
                                return 'auth.valid_email_required'.tr();
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
                              // Circular country code button
                              Container(
                                width: 56.w,
                                height: 56.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppStyles.fieldFill,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(28.w),
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
                                    child: Center(
                                      child: _selectedCountry != null
                                          ? Text(
                                              _selectedCountry!.flag,
                                              style: TextStyle(fontSize: 24.sp),
                                            )
                                          : Icon(
                                              IconlyLight.call,
                                              color: AppStyles.mainBlue,
                                              size: 20.sp,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
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
                          // Hotel/Service Provider specific fields
                          if (_selectedUserType == 'hotel') ...[
                            TextFormField(
                              controller: _addressController,
                              decoration: AppStyles.inputDecoration(
                                label: 'auth.address'.tr(),
                                icon: Icons.location_on,
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            SizedBox(height: 12.h),
                            TextFormField(
                              controller: _zipCodeController,
                              decoration: AppStyles.inputDecoration(
                                label: 'auth.zip_code'.tr(),
                                icon: Icons.pin,
                              ),
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                            ),
                            SizedBox(height: 12.h),
                          ],
                          if (_selectedUserType == 'service_provider') ...[
                            TextFormField(
                              controller: _displayNameController,
                              decoration: AppStyles.inputDecoration(
                                label: 'auth.display_name'.tr(),
                                icon: Icons.badge,
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            SizedBox(height: 12.h),
                            TextFormField(
                              controller: _taglineController,
                              decoration: AppStyles.inputDecoration(
                                label: 'auth.tagline'.tr(),
                                icon: Icons.tag,
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            SizedBox(height: 12.h),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: AppStyles.inputDecoration(
                                label: 'auth.description_skills'.tr(),
                                icon: Icons.description,
                              ),
                              maxLines: 3,
                              textInputAction: TextInputAction.next,
                            ),
                            SizedBox(height: 12.h),
                            // Currency field first
                            TextFormField(
                              controller: _currencyController,
                              decoration: AppStyles.inputDecoration(
                                label: 'auth.currency'.tr(),
                                icon: Icons.currency_exchange,
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            SizedBox(height: 12.h),
                            // Min and Max price fields below currency
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _minPriceController,
                                    decoration: AppStyles.inputDecoration(
                                      label: 'auth.min_price'.tr(),
                                      icon: Icons.attach_money,
                                    ),
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: TextFormField(
                                    controller: _maxPriceController,
                                    decoration: AppStyles.inputDecoration(
                                      label: 'auth.max_price'.tr(),
                                      icon: Icons.attach_money,
                                    ),
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                          ],
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
                                return 'auth.password_min_length'.tr();
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
                                return 'auth.passwords_do_not_match'.tr();
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
                                              'auth.create_account'.tr(),
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
                                'auth.already_have_account'.tr(),
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

  Widget _buildUserTypeButton({
    required String label,
    required String type,
    required IconData icon,
  }) {
    final isSelected = _selectedUserType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedUserType = type;
        });
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isSelected
              ? WPConfig.primaryColor.withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? WPConfig.primaryColor
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? WPConfig.primaryColor
                  : Colors.grey[600],
              size: 20.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? WPConfig.primaryColor
                    : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
