import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/wp_config.dart';
import '../../../core/components/headline_with_row.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/constants/sizedbox_const.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_form_validattors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/utils/ui_util.dart';
import '../dialogs/email_sent_successfully.dart';
import 'otp_page.dart';
import 'package:intl/intl.dart' hide TextDirection;

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

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
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                      child: ForgotPassForm(),
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

/// Forgot Password Form
class ForgotPassForm extends ConsumerStatefulWidget {
  const ForgotPassForm({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotPassForm> createState() => _ForgotPassFormState();
}

class _ForgotPassFormState extends ConsumerState<ForgotPassForm> {
  bool _isSendingEmail = false;

  String? errorMessage;

  Future<void> _sendEmail() async {
    bool isValid = _formKey.currentState?.validate() ?? false;
    if (isValid) {
      AppUtil.dismissKeyboard(context: context);
      _isSendingEmail = true;
      setState(() {});

      // errorMessage = await ref
      //     .read(authController.notifier)
      //     .sendResetLinkToEmail(_email.text);

      if (errorMessage == null) {
        // ignore: use_build_context_synchronously
        await UiUtil.openDialog(
            context: context, widget: const EmailSentSuccessfully());

        if (mounted) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => OtpPage(
                        email: _email.text,
                      )),
              (v) => false);
        }
      }

      _isSendingEmail = false;
      setState(() {});
    }
  }

  late TextEditingController _email;

  /// Formkey
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
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
                  'forgot_pass_message'.tr(),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                AppSizedBox.h16,
                AppSizedBox.h16,
                AutofillGroup(
                  child: TextFormField(
                    controller: _email,
                    decoration: AppStyles.inputDecoration(
                      label: 'email'.tr(),
                      icon: IconlyLight.message,
                      hint: 'you@email.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: AppValidators.email,
                    onFieldSubmitted: (v) => _sendEmail(),
                    autofillHints: const [AutofillHints.email],
                  ),
                ),
              ],
            ),
          ),
        ),
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
              onTap: _sendEmail,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: _isSendingEmail
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Submit',
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
        const SizedBox(height: 8),
        Center(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
            child: Text(
              "Back to Sign In",
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
    );
  }
}
