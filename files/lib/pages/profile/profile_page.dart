import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              // Title
              Expanded(
                child: Center(
                  child: Text(
                    'Profile',
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      child: Column(
        children: [
          // Profile header
          _buildProfileHeader(isTablet, primaryColor),
          SizedBox(height: 24),

          // Menu items
          _buildMenuSection(
            title: 'Account',
            items: [
              _buildMenuItem(
                icon: Icons.person_outline,
                title: 'Personal Information',
                subtitle: 'Update your profile details',
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
                title: 'Security',
                subtitle: 'Password and privacy settings',
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
                title: 'Notifications',
                subtitle: 'Manage your notification preferences',
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
            title: 'Travel',
            items: [
              _buildMenuItem(
                icon: Icons.favorite_outline,
                title: 'Saved Hotels',
                subtitle: 'Your favorite accommodations',
                onTap: () {
                  Navigator.pushNamed(context, '/favourites');
                },
                isTablet: isTablet,
                primaryColor: primaryColor,
              ),
              _buildMenuItem(
                icon: Icons.book_online_outlined,
                title: 'My Bookings',
                subtitle: 'View and manage your trips',
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
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isTablet, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile picture
          Container(
            width: isTablet ? 100 : 80,
            height: isTablet ? 100 : 80,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: isTablet ? 50 : 40,
            ),
          ),
          SizedBox(height: 16),

          // User info
          Text(
            'Mahmoud Ahmed',
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'mahmoud.ahmed@email.com',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Genius Level 1',
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
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
                  color: primaryColor,
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
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
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
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
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
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
