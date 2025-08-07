import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../config/wp_config.dart';
import '../../../controllers/auth/auth_controller.dart';
import '../../../core/components/network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/constants/sizedbox_const.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/utils/ui_util.dart';
import '../dialogs/email_sent_successfully.dart';
import 'reset_password_page.dart';

class OtpPage extends StatelessWidget {
  const OtpPage({
    Key? key,
    required this.email,
  }) : super(key: key);

  final String email;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return      Scaffold(

    body: Container(
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'verify_account'.tr(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D0C4E),
                        ),
                      ),
                      const SizedBox(height: 24),
                      OTPTextFields(email: email),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }
}

class OTPTextFields extends ConsumerStatefulWidget {
  const OTPTextFields({
    Key? key,
    required this.email,
  }) : super(key: key);

  final String email;

  @override
  ConsumerState<OTPTextFields> createState() => _OTPTextFieldsState();
}

class _OTPTextFieldsState extends ConsumerState<OTPTextFields> {
  late TextEditingController otpField1;
  late TextEditingController otpField2;
  late TextEditingController otpField3;
  late TextEditingController otpField4;

  bool isVerifying = false;
  String? errorMessage;

  onFinalFieldSubmitted() async {
    if (otpField1.text.isNotEmpty &&
        otpField2.text.isNotEmpty &&
        otpField3.text.isNotEmpty &&
        otpField4.text.isNotEmpty) {
      errorMessage = null;
      isVerifying = true;
      if (mounted) setState(() {});
      final otp1 = otpField1.text;
      final otp2 = otpField2.text;
      final otp3 = otpField3.text;
      final otp4 = otpField4.text;
      final result = otp1 + otp2 + otp3 + otp4;

      ref.read(authController.notifier);
      if (true) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => ResetPasswordPage(
                        email: widget.email,
                        otp: result,
                      )),
              (v) => false);
        }
      }
    } else {
      errorMessage = null;
      Fluttertoast.showToast(msg: 'please_fill_all_fields'.tr());
    }

    isVerifying = false;
    if (mounted) setState(() {});
  }

  Future<void> _sendEmail() async {
    if (_otpResendTimeRemaining <= 0) {
      _otpResendTimeRemaining = 60;
      startTimer();
      AppUtil.dismissKeyboard(context: context);
      isVerifying = true;
      setState(() {});
      //
      // errorMessage = await ref
      //     .read(authController.notifier)
      //     .sendResetLinkToEmail(widget.email);

      if (errorMessage == null) {
        // ignore: use_build_context_synchronously
        await UiUtil.openDialog(
            context: context, widget: const EmailSentSuccessfully());
      }
      isVerifying = false;
      setState(() {});
    } else {
      Fluttertoast.showToast(
          msg: 'please_wait_seconds'.tr(args: [_otpResendTimeRemaining.toString()]));
    }
  }

  late Timer _timer;
  int _otpResendTimeRemaining = 0;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_otpResendTimeRemaining == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _otpResendTimeRemaining--;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _otpResendTimeRemaining = 60;
    startTimer();
    otpField1 = TextEditingController();
    otpField2 = TextEditingController();
    otpField3 = TextEditingController();
    otpField4 = TextEditingController();
  }

  @override
  void dispose() {
    _timer.cancel();
    otpField1.dispose();
    otpField2.dispose();
    otpField3.dispose();
    otpField4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        const SizedBox(
          height: 100,
          width: 100,
          child: NetworkImageWithLoader(
            'https://i.imgur.com/XZFpwkN.png',
            fit: BoxFit.contain,
          ),
        ),
        AppSizedBox.h16,
        Text(
          'reset_pass_message'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        AppSizedBox.h16,
        AppSizedBox.h16,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: 68,
              height: 68,
              child: TextFormField(
                onChanged: (v) {
                  if (v.length == 1) {
                    FocusScope.of(context).nextFocus();
                  } else {
                    FocusScope.of(context).previousFocus();
                  }
                },
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(1),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                controller: otpField1,
              ),
            ),
            SizedBox(
              width: 68,
              height: 68,
              child: TextFormField(
                onChanged: (v) {
                  if (v.length == 1) {
                    FocusScope.of(context).nextFocus();
                  } else {
                    FocusScope.of(context).previousFocus();
                  }
                },
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(1),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                controller: otpField2,
              ),
            ),
            SizedBox(
              width: 68,
              height: 68,
              child: TextFormField(
                onChanged: (v) {
                  if (v.length == 1) {
                    FocusScope.of(context).nextFocus();
                  } else {
                    FocusScope.of(context).previousFocus();
                  }
                },
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(1),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                controller: otpField3,
              ),
            ),
            SizedBox(
              width: 68,
              height: 68,
              child: TextFormField(
                onChanged: (v) {
                  if (v.length == 1) {
                    // FocusScope.of(context).nextFocus();
                  } else {
                    FocusScope.of(context).previousFocus();
                  }
                },
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(1),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                controller: otpField4,
                onFieldSubmitted: (v) => onFinalFieldSubmitted(),
              ),
            ),
          ],
        ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDefaults.padding),
            child: Text(
              errorMessage ?? 'Error',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.red),
            ),
          ),
        const Spacer(),
        if (isVerifying) const CircularProgressIndicator(),
        SentEmailTimeRemaining(seconds: _otpResendTimeRemaining),
        TextButton(
          onPressed: _sendEmail,
          child: Text('resend_otp'.tr()),
        ),
        AppSizedBox.h16,
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: ElevatedButton(
            onPressed: onFinalFieldSubmitted,
            child: Text('done'.tr()),
          ),
        )
      ],
    );
  }
}

class SentEmailTimeRemaining extends StatelessWidget {
  const SentEmailTimeRemaining({Key? key, required this.seconds})
      : super(key: key);

  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Text(
      'seconds_remaining'.tr(args: [seconds.toString()]),
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
