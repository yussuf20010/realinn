import 'package:flutter/cupertino.dart';
import 'package:realinn/pages/profile/profile_page.dart';
import '../../pages/entrypoint/loading_app_page.dart';
import '../../pages/login/login_animation.dart';
import '../../pages/login/login_intro_page.dart';
import '../../pages/login/pages/forgot_password_page.dart';
import '../../pages/login/pages/login_page.dart';
import '../../pages/login/pages/signup_page.dart';
import '../../pages/settings/pages/notifications_page.dart';
import 'app_routes.dart';
import 'unknown_page.dart';
import '../../pages/main/main_scaffold.dart';
import '../../pages/settings/settings_page.dart';
import '../../pages/settings/pages/privacy_policy_page.dart';
import '../../pages/settings/pages/terms_conditions_page.dart';
import '../../pages/settings/pages/about_page.dart';
import '../../pages/settings/pages/help_support_page.dart';
import '../../pages/settings/pages/rate_review_page.dart';
import '../../pages/settings/pages/faq_page.dart';

class RouteGenerator {
  static Route? onGenerate(RouteSettings settings) {
    final route = settings.name;

    switch (route) {
      case AppRoutes.initial:
        return CupertinoPageRoute(builder: (_) => const LoadingAppPage());



      case AppRoutes.explore:
        return CupertinoPageRoute(builder: (_) => MainScaffold());


      case AppRoutes.loadingApp:
        return CupertinoPageRoute(builder: (_) => const LoadingAppPage());

      case AppRoutes.login:
        return CupertinoPageRoute(builder: (_) => const LoginPage());

      case AppRoutes.loginAnimation:
        return CupertinoPageRoute(builder: (_) => const LoggingInAnimation());


      case AppRoutes.loginIntro:
        return CupertinoPageRoute(builder: (_) => const LoginIntroPage());

      case AppRoutes.signup:
        return CupertinoPageRoute(builder: (_) => const SignUpPage());

      case AppRoutes.forgotPass:
        return CupertinoPageRoute(builder: (_) => const ForgotPasswordPage());


      case AppRoutes.homePage:
        return CupertinoPageRoute(builder: (_) => MainScaffold());
      case AppRoutes.profile:
        return CupertinoPageRoute(builder: (_) => const ProfilePage());

      case AppRoutes.settings:
        return CupertinoPageRoute(builder: (_) => const SettingsPage());
      case AppRoutes.notifications:
        return CupertinoPageRoute(builder: (_) => const NotificationsPage());
      case AppRoutes.privacy:
        return CupertinoPageRoute(builder: (_) => const PrivacyPolicyPage());
      case AppRoutes.terms:
        return CupertinoPageRoute(builder: (_) => const TermsConditionsPage());
      case AppRoutes.about:
        return CupertinoPageRoute(builder: (_) => const AboutPage());
      case AppRoutes.help:
        return CupertinoPageRoute(builder: (_) => const HelpSupportPage());
      case AppRoutes.rate:
        return CupertinoPageRoute(builder: (_) => const RateReviewPage());
      case AppRoutes.faq:
        return CupertinoPageRoute(builder: (_) => const FaqPage());

      default:
        return errorRoute();
    }
  }

  static Route? errorRoute() =>
      CupertinoPageRoute(builder: (_) => const UnknownPage());
}
