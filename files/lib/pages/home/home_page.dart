import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/dynamic_config.dart';
import '../../widgets/custom_app_bar.dart';
import '../notifications/notifications_page.dart';
import 'components/booking_type_selector.dart';
import 'components/promotional_cards.dart';
import 'components/more_for_you_section.dart';
import 'components/hotels_section_header.dart';
import 'components/hotels_list.dart';
import 'modals/daily_booking_modal.dart';
import 'modals/monthly_booking_modal.dart';
import 'providers/home_providers.dart';
import '../../core/utils/responsive.dart';
import '../../config/wp_config.dart'; // Added import for WPConfig

class HomePage extends ConsumerWidget {
  HomePage({Key? key}) : super(key: key);

  void _showDailyBookingModal(BuildContext context, WidgetRef ref) {
    print('=== DAILY BOOKING MODAL SHOWING ===');
    showModalBottomSheet( 
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DailyBookingModal(),
    );
  }

  void _showMonthlyBookingModal(BuildContext context, WidgetRef ref) {
    print('=== MONTHLY BOOKING MODAL SHOWING ===');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MonthlyBookingModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('=== HOME PAGE BUILD ===');
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final primaryColor = WPConfig.navbarColor; // Use constant color directly
    print('Dynamic config loaded: ${dynamicConfig.appName}');
    print('Primary color: $primaryColor');
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: dynamicConfig.appName ?? 'RealInn',
        showBackButton: false,
        onNotificationPressed: () {
          print('Notification button pressed');
          Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsPage()));
        },
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        child: _buildLayout(context, ref),
      ),
    );
  }

  Widget _buildLayout(BuildContext context, WidgetRef ref) {
    final isTablet = MediaQuery.of(context).size.width >= 768;
    
    return Column(
      children: [
        // Booking type selector
        BookingTypeSelector(
          onDailyBookingTap: () {
            print('Daily booking tapped');
            _showDailyBookingModal(context, ref);
          },
          onMonthlyBookingTap: () {
            print('Monthly booking tapped');
            _showMonthlyBookingModal(context, ref);
          },
        ), 

        // Promotional cards
        PromotionalCards(),

        // More for you section
        MoreForYouSection(),

        // Hotels section
        HotelsSectionHeader(),
        HotelsList(),
      ],
    );
  }
}







