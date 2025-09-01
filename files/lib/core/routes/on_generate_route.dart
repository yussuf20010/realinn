import 'package:flutter/cupertino.dart';
import 'package:realinn/pages/profile/profile_page.dart';
import '../../pages/customer_service/customer_service_page.dart';
import '../../pages/entrypoint/loading_app_page.dart';
import '../../pages/history/history_page.dart';
import '../../pages/hotels/hotel_details_page.dart';
import '../../pages/hotels/hotels_search_page.dart';
import '../../pages/login/login_animation.dart';
import '../../pages/login/login_intro_page.dart';
import '../../pages/login/pages/forgot_password_page.dart';
import '../../pages/login/pages/login_page.dart';
import '../../pages/login/pages/signup_page.dart';
import '../../pages/main/main_scaffold.dart';
import '../../pages/notifications/notifications_page.dart';
import '../../pages/settings/pages/rate_review_page.dart';
import '../../pages/settings/pages/faq_page.dart';
import '../../pages/chat/chat_page.dart';
import '../../pages/favourites/favourites_page.dart';
import '../../pages/bookings/bookings_page.dart';
import 'app_routes.dart';
import 'unknown_page.dart';
import '../../pages/settings/settings_page.dart';
import '../../pages/settings/pages/privacy_policy_page.dart';
import '../../pages/settings/pages/terms_conditions_page.dart';
import '../../pages/settings/pages/about_page.dart';
import '../../pages/settings/pages/help_support_page.dart';
import '../../models/hotel.dart';
import '../../pages/bookings/create_booking_page.dart';
import '../../models/selected_room.dart';
import '../../models/booking.dart';

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

      case '/customer-service':
        return CupertinoPageRoute(builder: (_) => const CustomerServicePage());

      case '/chat':
        return CupertinoPageRoute(builder: (_) => const ChatPage());

      case '/favourites':
        return CupertinoPageRoute(builder: (_) => const FavouritesPage());

      case '/bookings':
        return CupertinoPageRoute(builder: (_) => const BookingsPage());

      case '/create-booking':
        final args = settings.arguments as Map<String, dynamic>?;
        final hotel = args?['hotel'] as Hotel?;
        final selectedRoom = args?['selectedRoom'] as SelectedRoom?;
        final booking = args?['booking'] as Booking?;

        if (hotel != null && selectedRoom != null) {
          return CupertinoPageRoute(
            builder: (_) => CreateBookingPage(
              hotel: hotel,
              selectedRoom: selectedRoom,
              booking: booking,
            ),
          );
        }
        return errorRoute();

      case '/history':
        return CupertinoPageRoute(builder: (_) => const HistoryPage());

      case '/search-results':
        final args = settings.arguments as Map<String, dynamic>?;
        final hotels = args?['hotels'] as List<Hotel>? ?? [];
        final searchQuery = args?['searchQuery'] as String? ?? '';
        final checkInDate = args?['checkInDate'] as DateTime?;
        final checkOutDate = args?['checkOutDate'] as DateTime?;
        final rooms = args?['rooms'] as int?;
        return CupertinoPageRoute(
          builder: (_) => HotelsSearchPage(
            searchQuery: searchQuery,
            initialHotels: hotels,
            checkInDate: checkInDate,
            checkOutDate: checkOutDate,
            rooms: rooms,
          ),
        );

      case '/all-hotels':
        return CupertinoPageRoute(builder: (_) => const HotelsSearchPage());

      case '/city-hotels':
        final cityName = settings.arguments as String? ?? '';
        return CupertinoPageRoute(
          builder: (_) => HotelsSearchPage(cityName: cityName),
        );

      case '/country-hotels':
        final countryName = settings.arguments as String? ?? '';
        return CupertinoPageRoute(
          builder: (_) => HotelsSearchPage(countryName: countryName),
        );

      case '/hotel-details':
        final args = settings.arguments as Map<String, dynamic>?;
        final hotel = args?['hotel'] as Hotel?;
        final checkInDate = args?['checkInDate'] as DateTime?;
        final checkOutDate = args?['checkOutDate'] as DateTime?;
        final rooms = args?['rooms'] as int?;

        if (hotel != null) {
          return CupertinoPageRoute(
            builder: (_) => HotelDetailsPage(
              hotel: hotel,
              checkInDate: checkInDate,
              checkOutDate: checkOutDate,
              rooms: rooms,
            ),
          );
        }
        return errorRoute();

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
