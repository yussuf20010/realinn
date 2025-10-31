import 'package:flutter/cupertino.dart';
import 'package:realinn/pages/profile/profile_page.dart';
import '../../pages/customer_service/customer_service_page.dart';
import '../../pages/entrypoint/loading_app_page.dart';
// import '../../pages/history/history_page.dart';
import '../../pages/hotels/hotel_details_page.dart';
import '../../pages/hotels/hotels_search_page.dart';
import '../../pages/auth/forgot_password.dart';
import '../../pages/auth/login.dart';
import '../../pages/auth/register.dart';
import '../../pages/auth/verify_code.dart';
import '../../pages/auth/reset_password.dart';
import '../../pages/main/main_scaffold.dart';
import '../../pages/notifications/notifications_page.dart';
import '../../pages/favourites/favourites_page.dart';
// import '../../pages/waiting_list/waiting_list_page.dart';
import 'app_routes.dart';
import 'unknown_page.dart';
import '../../models/hotel.dart';
// import '../../models/selected_room.dart';
import '../../pages/service_providers/pages/categories_page.dart';

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

      case AppRoutes.signup:
        return CupertinoPageRoute(builder: (_) => const RegisterPage());

      case AppRoutes.forgotPass:
        return CupertinoPageRoute(builder: (_) => const ForgotPasswordPage());

      case AppRoutes.verifyCode:
        final args = settings.arguments;
        String email = '';
        int userId = 0;
        if (args is Map<String, dynamic>) {
          email = (args['email'] as String?) ?? '';
          userId = (args['userId'] as int?) ?? 0;
        } else if (args is String) {
          email = args;
        }
        return CupertinoPageRoute(
            builder: (_) => VerifyCodePage(email: email, userId: userId));

      case AppRoutes.resetPass:
        final args = settings.arguments as Map<String, String>?;
        return CupertinoPageRoute(
            builder: (_) => ResetPasswordPage(
                  email: args?['email'] ?? '',
                  verificationCode: args?['verificationCode'] ?? '',
                ));

      case AppRoutes.homePage:
        return CupertinoPageRoute(builder: (_) => MainScaffold());
      case AppRoutes.profile:
        return CupertinoPageRoute(builder: (_) => const ProfilePage());

      case AppRoutes.notifications:
        return CupertinoPageRoute(builder: (_) => const NotificationsPage());

      case '/customer-service':
        return CupertinoPageRoute(builder: (_) => const CustomerServicePage());

      case '/favourites':
        return CupertinoPageRoute(builder: (_) => const FavouritesPage());

      case '/waiting-list':
        return CupertinoPageRoute(
            builder: (_) => MainScaffold(initialIndex: 2));

      case '/history':
        return CupertinoPageRoute(
            builder: (_) => MainScaffold(initialIndex: 3));

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

      case AppRoutes.serviceProviderCategories:
        return CupertinoPageRoute(builder: (_) => const CategoriesPage());

      default:
        return errorRoute();
    }
  }

  static Route? errorRoute() =>
      CupertinoPageRoute(builder: (_) => const UnknownPage());
}
