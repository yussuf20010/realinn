import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../controllers/auth/auth_controller.dart';
import '../../../core/components/headline_with_row.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/constants/sizedbox_const.dart';
import '../../../core/utils/app_form_validattors.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({
    Key? key,
    required this.email,
    required this.otp,
  }) : super(key: key);

  final String email;
  final String otp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        appBar: AppBar(),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ResetPasswordForm(
                email: email,
                otp: otp,
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: TextButton(
            onPressed: () {
              SystemNavigator.pop(animated: true);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.adaptive.arrow_back_rounded, size: 16),
                AppSizedBox.w5,
                Text('go_back'.tr(),
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),

    );
  }
}

class ResetPasswordForm extends ConsumerStatefulWidget {
  const ResetPasswordForm({
    Key? key,
    required this.email,
    required this.otp,
  }) : super(key: key);

  final String email;
  final String otp;

  @override
  ConsumerState<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends ConsumerState<ResetPasswordForm> {
  String email = '';
  String? errorMessage;

  late TextEditingController _firstPass;
  late TextEditingController _secondPass;
  bool _isPasswordResetting = false;

  Future<void> _resetPassword() async {
    final authProvider = ref.read(authController.notifier);

    bool isValid = _formKey.currentState?.validate() ?? false;
    if (isValid) {
      _isPasswordResetting = true;
      setState(() {});

      // bool passwordReseted = await authProvider.resetPassword(
      //   newPassword: _firstPass.text,
      //   email: email,
      //   otp: widget.otp,
      // );

      // if (passwordReseted) {
      if (true) {
        // ignore: use_build_context_synchronously
        await authProvider.login(
          email: email,
          password: _firstPass.text,
          context: context,
        );
      } else {
        Fluttertoast.showToast(msg: 'having_problems_logging_in'.tr());
      }
      _isPasswordResetting = false;
      setState(() {});
    }
  }

  /// Formkey
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    email = widget.email;
    _firstPass = TextEditingController();
    _secondPass = TextEditingController();
  }

  @override
  void dispose() {
    _firstPass.dispose();
    _secondPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                HeadlineRow(
                  fontColor: AppColors.primary, headline: '',
                ),
                AppSizedBox.h16,
                Text(
                  'reset_pass_message'.tr(),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                AppSizedBox.h16,
                AppSizedBox.h16,
                TextFormField(
                  controller: _firstPass,
                  decoration: InputDecoration(
                    labelText: 'password'.tr(),
                    prefixIcon: const Icon(IconlyLight.password),
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  validator: AppValidators.password,
                ),
                AppSizedBox.h16,
                TextFormField(
                  controller: _secondPass,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'confirm_password'.tr(),
                    prefixIcon: const Icon(IconlyLight.password),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  validator: (v) =>
                      AppValidators.passwordMatcher(v ?? '', _secondPass.text),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppDefaults.margin),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _resetPassword,
              child: _isPasswordResetting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('reset_pass'.tr()),
            ),
          ),
        ),
      ],
    );
  }
}
