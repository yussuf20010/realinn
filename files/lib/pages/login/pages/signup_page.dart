import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../config/wp_config.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/routes/app_routes.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return  Scaffold(
        body: Stack(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight,
              decoration:  BoxDecoration(
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
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                      child: SignupForm(),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 24,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.homePage);
                },
                child: Text(
                  'skip'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }
}

class SignupForm extends ConsumerStatefulWidget {
  const SignupForm({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends ConsumerState<SignupForm> {
  late TextEditingController _fullName;
  late TextEditingController _email;
  late TextEditingController _phone;
  late TextEditingController _pass;
  String _countryCode = '+225';
  bool _isCreating = false;
  bool showPassword = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fullName = TextEditingController();
    _email = TextEditingController();
    _phone = TextEditingController();
    _pass = TextEditingController();
  }

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _toggleShowPassword() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  Future<void> _signUp() async {
    if (_isCreating) return;
    bool isValid = _formKey.currentState?.validate() ?? false;
    if (isValid) {
      setState(() => _isCreating = true);
      // Call your signup logic here
      setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _fullName,
            decoration: AppStyles.inputDecoration(
              label: 'full_name'.tr(),
              icon: IconlyLight.profile
            ),
            validator: (v) => v == null || v.isEmpty ? 'full_name_required'.tr() : null,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            decoration: AppStyles.inputDecoration(
              label: 'email'.tr(),
              icon: IconlyLight.message
            ),
            validator: (v) => v == null || v.isEmpty ? 'email_required'.tr() : null,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 90,
                child: DropdownButtonFormField<String>(
                  value: _countryCode,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                    filled: true,
                    fillColor: AppStyles.fieldFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  icon: Icon(Icons.arrow_drop_down, color: AppStyles.mainBlue),
                  items: ['+971', '+966', '+02']
                      .map((code) => DropdownMenuItem(value: code, child: Text(code)))
                      .toList(),
                  onChanged: (val) => setState(() => _countryCode = val ?? '+225'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _phone,
                  decoration: AppStyles.inputDecoration(
                    label: 'mobile_number'.tr(),
                    icon: IconlyLight.call
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'phone_required'.tr() : null,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _pass,
            obscureText: !showPassword,
            decoration: AppStyles.inputDecoration(
              label: 'password'.tr(),
              icon: IconlyLight.password,
              suffixIcon: IconButton(
                icon: Icon(showPassword ? IconlyLight.show : IconlyLight.hide, color: AppStyles.mainBlue),
                onPressed: _toggleShowPassword,
              ),
            ),
            validator: (v) => v == null || v.isEmpty ? 'password_required'.tr() : null,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 24),
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
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.homePage);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: _isCreating
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              inherit: true,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
                          Center(child: Text('or_sign_in_using'.tr(), style: TextStyle(color: Colors.black))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: AppStyles.outlinedButton.copyWith(
                    backgroundColor: MaterialStateProperty.all(Color(0xFF1877F3)),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  icon: Icon(Icons.facebook, color: Colors.white),
                  label: Text('Facebook'),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: AppStyles.outlinedButton.copyWith(
                    backgroundColor: MaterialStateProperty.all(Color(0xFFEA4335)),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  icon: Icon(Icons.g_mobiledata, color: Colors.white),
                  label: Text('Google'),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text.rich(
                TextSpan(
                  text: 'terms'.tr(),
                  style: TextStyle(color: AppStyles.mainBlue, decoration: TextDecoration.underline),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              },
              child: Text(
                "Already have an account? Sign In",
                style: TextStyle(
                  color: AppStyles.mainBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  inherit: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
