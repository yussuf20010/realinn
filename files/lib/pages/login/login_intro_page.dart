import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/wp_config.dart';
import '../../config/dynamic_config.dart';
import '../../core/components/app_logo.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/constants/sizedbox_const.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/responsive.dart';
import 'components/dont_have_account_button.dart';

class LoginIntroPage extends ConsumerWidget {
  const LoginIntroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    return  Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
            child: Column(
              children: [


                /// Header
                const LoginIntroHeader(),

                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(AppDefaults.padding),
                  child: Column(
                    children: [
                      Responsive(
                        mobile: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: const AppLogo(),
                        ),
                        tablet: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: const AppLogo(),
                        ),
                      ),
                      AppSizedBox.h16,
                      AppSizedBox.h16,
                      Text(
                        '${'welcome_newspro'.tr()} ${dynamicConfig.appName ?? WPConfig.appName}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      Responsive(
                        mobile: Padding(
                          padding: const EdgeInsets.all(16),
                          child: AutoSizeText(
                            'welcome_message'.tr(),
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        tablet: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: AutoSizeText(
                              'welcome_message'.tr(),
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // const AppSignInWithAppleButton(),
                // const SignInWithGoogleButton(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppDefaults.margin),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      child: Text('sign_in_continue'.tr()),
                    ),
                  ),
                ),
                const DontHaveAccountButton(),
              ],
            ),
          ),
        ),
    );
  }
}

class LoginIntroHeader extends ConsumerWidget {
  const LoginIntroHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Change Locale Button
        // IconButton(
        //   onPressed: () {
        //     UiUtil.openBottomSheet(
        //         context: context, widget: const ChangeLanguageDialog());
        //   },
        //   icon: const Icon(Icons.language_rounded),
        // ),
        const Spacer(),
        TextButton(
          onPressed: () {

            Navigator.pushNamed(context, AppRoutes.entryPoint);

          },
          child: Text('skip'.tr(),
              style: TextStyle(fontSize:18,fontWeight: FontWeight.bold,color: AppColors.primary)),
        ),

      ],
    );
  }
}
