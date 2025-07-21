import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' ;
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/wp_config.dart';
import '../../../controllers/auth/auth_controller.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_form_validattors.dart';
import '../../../core/utils/app_utils.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Stack(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight,
              decoration: const BoxDecoration(
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
                      child: LoginFormSection(),
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

class LoginFormSection extends ConsumerStatefulWidget {
  const LoginFormSection({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginFormSection> createState() => _LoginFormSectionState();
}

class _LoginFormSectionState extends ConsumerState<LoginFormSection> {
  late TextEditingController _email;
  late TextEditingController _pass;
  bool _isLoggingIn = false;
  final _formKey = GlobalKey<FormState>();
  bool showPassword = false;

  void _toggleShowPassword() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  Future<void> _login() async {
    if (_isLoggingIn) return;
    bool isValid = _formKey.currentState?.validate() ?? false;
    if (isValid) {
      AppUtil.dismissKeyboard(context: context);
      setState(() {
        _isLoggingIn = true;
      });
      String? result = await ref.read(authController.notifier).login(
        email: _email.text,
        password: _pass.text,
        context: context,
      );
      if (result != null) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _pass = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _email,
            decoration: AppStyles.inputDecoration(
              label: 'email'.tr(), 
              icon: IconlyLight.message, 
              hint: 'email_hint'.tr()
            ),
            keyboardType: TextInputType.emailAddress,
            validator: AppValidators.email,
            onFieldSubmitted: (v) => _login(),
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _pass,
            obscureText: !showPassword,
            decoration: AppStyles.inputDecoration(
              label: 'password'.tr(),
              icon: IconlyLight.password,
              hint: 'password_hint'.tr(),
              suffixIcon: IconButton(
                icon: Icon(showPassword ? IconlyLight.show : IconlyLight.hide, color: AppStyles.mainBlue),
                onPressed: _toggleShowPassword,
              ),
            ),
            validator: AppValidators.password,
            onFieldSubmitted: (v) => _login(),
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.forgotPass);
              },
              style: TextButton.styleFrom(foregroundColor: AppStyles.mainBlue),
              child: Text(
                'forgot_pass'.tr(),
                style: TextStyle(
                  color: AppStyles.mainBlue,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                  inherit: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
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
                    child: _isLoggingIn
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Sign In',
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
          const SizedBox(height: 16),
          Center(child: Text('or_sign_in_using'.tr(), style: TextStyle(color: Colors.grey, inherit: true))),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: AppStyles.outlinedButton.copyWith(
                    backgroundColor: MaterialStateProperty.all(WPConfig.primaryColor),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                  ),  
                  icon: Icon(Icons.facebook, color: Colors.white),
                  label: Text('Facebook', style: TextStyle(inherit: true)),
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
                  label: Text('Google', style: TextStyle(inherit: true)),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text.rich(
                TextSpan(
                  text: 'terms'.tr(),
                  style: TextStyle(color: WPConfig.primaryColor, inherit: true),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.signup);
              },
              child: Text(
                "Don't have an account? Sign Up",
                style: TextStyle(
                  color: WPConfig.primaryColor,
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
