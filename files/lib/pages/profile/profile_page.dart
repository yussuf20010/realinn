import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
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
      color: primaryColor,
      child: SafeArea(
        child: Container(
          height: 80,
          child: Row(
            children: [
              // Back button
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              // Title
              Expanded(
                child: Center(
                  child: Text(
                    'profile'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 20 : 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Placeholder for symmetry
              SizedBox(width: 56),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isTablet, Color primaryColor) {
    return Column(
      children: [
        // Profile header - non-scrollable
        Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: _buildProfileHeader(isTablet, primaryColor),
        ),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                isTablet ? 20 : 16, 0, isTablet ? 20 : 16, isTablet ? 40 : 30),
            child: Column(
              children: [
                SizedBox(height: 24),

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
                          SnackBar(content: Text('Personal Information')),
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
                          SnackBar(content: Text('Security Settings')),
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
                          SnackBar(content: Text('Notification Settings')),
                        );
                      },
                      isTablet: isTablet,
                      primaryColor: primaryColor,
                    ),
                  ],
                  isTablet: isTablet,
                  primaryColor: primaryColor,
                ),
                SizedBox(height: 24),

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
                      title: 'Travel History',
                      subtitle: 'Past trips and experiences',
                      onTap: () {
                        Navigator.pushNamed(context, '/history');
                      },
                      isTablet: isTablet,
                      primaryColor: primaryColor,
                    ),
                  ],
                  isTablet: isTablet,
                  primaryColor: primaryColor,
                ),
                SizedBox(height: 24),

                _buildMenuSection(
                  title: 'Support',
                  items: [
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: 'Help Center',
                      subtitle: 'Find answers to common questions',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Help Center')),
                        );
                      },
                      isTablet: isTablet,
                      primaryColor: primaryColor,
                    ),
                    _buildMenuItem(
                      icon: Icons.support_agent,
                      title: 'Contact Support',
                      subtitle: 'Get help from our team',
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
                SizedBox(height: 24),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  height: isTablet ? 65 : 50,
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
                      'Logout',
                      style: TextStyle(
                        fontSize: isTablet ? 25 : 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(bool isTablet, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Profile picture with enhanced styling
          Container(
            width: isTablet ? 80 : 70,
            height: isTablet ? 80 : 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.8),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
            ),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: isTablet ? 40 : 35,
            ),
          ),
          SizedBox(height: 16),

          // User info with enhanced styling
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Mahmoud Ahmed',
                  style: TextStyle(
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      color: Colors.grey[600],
                      size: isTablet ? 18 : 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'mahmoud.ahmed@email.com',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.black,
                  size: isTablet ? 24 : 20,
                ),
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
            'Logout',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
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
                  SnackBar(content: Text('Logged out successfully')),
                );
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Logout',
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
