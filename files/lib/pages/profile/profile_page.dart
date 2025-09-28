import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/wp_config.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = WPConfig.navbarColor;
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: _buildCustomAppBar(context, primaryColor, isTablet),
      ),
      body: _buildMainContent(isTablet, primaryColor),
    );
  }

  Widget _buildCustomAppBar(
      BuildContext context, Color primaryColor, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            primaryColor.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 90,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Back button with enhanced design
              Container(
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile image
                    Container(
                      width: isTablet ? 36 : 32,
                      height: isTablet ? 36 : 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        color: primaryColor,
                        size: isTablet ? 20 : 18,
                      ),
                    ),
                    SizedBox(width: 8),
                    // Profile name
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mahmoud Ahmed',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'mahmoud.ahmed@email.com',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: isTablet ? 14 : 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isTablet, Color primaryColor) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          isTablet ? 20.w : 16.w, 20.h, isTablet ? 20.w : 16.w, isTablet ? 40.h : 30.h),
      child: Column(
        children: [
          // Menu items
          _buildMenuSection(
            title: 'account'.tr(),
            items: [
              _buildMenuItem(
                icon: Icons.person_outline,
                title: 'personal_information'.tr(),
                subtitle: 'update_profile_details'.tr(),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('personal_information'.tr())),
                  );
                },
                isTablet: isTablet,
                primaryColor: primaryColor,
              ),
              _buildMenuItem(
                icon: Icons.lock_outline,
                title: 'security'.tr(),
                subtitle: 'password_privacy_settings'.tr(),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('security_settings'.tr())),
                  );
                },
                isTablet: isTablet,
                primaryColor: primaryColor,
              ),
              _buildMenuItem(
                icon: Icons.notifications_outlined,
                title: 'notifications'.tr(),
                subtitle: 'notification_preferences'.tr(),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('notification_preferences'.tr())),
                  );
                },
                isTablet: isTablet,
                primaryColor: primaryColor,
              ),
            ],
            isTablet: isTablet,
            primaryColor: primaryColor,
          ),
          SizedBox(height: 24.h),

          _buildMenuSection(
            title: 'travel'.tr(),
            items: [
              _buildMenuItem(
                icon: Icons.favorite_outline,
                title: 'saved_hotels_title'.tr(),
                subtitle: 'favorite_accommodations'.tr(),
                onTap: () {
                  Navigator.pushNamed(context, '/favourites');
                },
                isTablet: isTablet,
                primaryColor: primaryColor,
              ),
              _buildMenuItem(
                icon: Icons.book_online_outlined,
                title: 'my_bookings'.tr(),
                subtitle: 'view_manage_trips'.tr(),
                onTap: () {
                  Navigator.pushNamed(context, '/bookings');
                },
                isTablet: isTablet,
                primaryColor: primaryColor,
              ),
              _buildMenuItem(
                icon: Icons.history,
                title: 'travel_history'.tr(),
                subtitle: 'past_trips_experiences'.tr(),
                onTap: () {
                  Navigator.pushNamed(context, '/history');
                },
                isTablet: isTablet,
                primaryColor: primaryColor,
              ),
              _buildMenuItem(
                icon: Icons.bookmark_outline,
                title: 'waiting_list'.tr(),
                subtitle: 'saved_for_later'.tr(),
                onTap: () {
                  Navigator.pushNamed(context, '/waiting-list');
                },
                isTablet: isTablet,
                primaryColor: primaryColor,
              ),
            ],
            isTablet: isTablet,
            primaryColor: primaryColor,
          ),
          SizedBox(height: 24.h),

          _buildMenuSection(
            title: 'support'.tr(),
            items: [
              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'help_center'.tr(),
                subtitle: 'find_answers_common_questions'.tr(),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('help_center'.tr())),
                  );
                },
                isTablet: isTablet,
                primaryColor: primaryColor,
              ),
              _buildMenuItem(
                icon: Icons.support_agent,
                title: 'contact_support'.tr(),
                subtitle: 'get_help_from_team'.tr(),
                onTap: () {
                  Navigator.pushNamed(context, '/customer-service');
                },
                isTablet: isTablet,
                primaryColor: primaryColor,
              ),
            ],
            isTablet: isTablet,
            primaryColor: primaryColor,
          ),
          SizedBox(height: 24.h),

          // Logout button
          SizedBox(
            width: double.infinity,
            height: isTablet ? 80 : 65,
            child: ElevatedButton(
              onPressed: () {
                _showLogoutDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: BorderSide(color: primaryColor, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'logout'.tr(),
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<Widget> items,
    required bool isTablet,
    required Color primaryColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isTablet,
    required Color primaryColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.black,
                size: isTablet ? 24 : 20,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: isTablet ? 20 : 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'logout'.tr(),
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'are_you_sure_logout'.tr(),
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'cancel'.tr(),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Handle logout
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('logged_out_successfully'.tr())),
                );
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: Text(
                'logout'.tr(),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
