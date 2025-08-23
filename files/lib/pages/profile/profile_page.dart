import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/auth/user_controller.dart';
import '../../config/wp_config.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../controllers/auth/auth_controller.dart';
import '../login/pages/login_page.dart';
import '../../widgets/ProfileCompletionWidget.dart';
import '../../widgets/custom_app_bar.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final userAsync = ref.watch(userControllerProvider);
        final authNotifier = ref.read(authController.notifier);
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(title: 'Profile', showBackButton: true, backAndLogoOnly: true),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Blue header with user info
                Container(
                  color: WPConfig.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 36, color: WPConfig.primaryColor),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: userAsync.when(
                          data: (user) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user != null ? 'Hi, ${user.firstName}' : 'Hi, Guest',
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Genius Level 1',
                                style: TextStyle(color: Colors.yellow[200], fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          loading: () => SizedBox(height: 32),
                          error: (e, _) => Text('Hi, Guest', style: TextStyle(color: Colors.white, fontSize: 20)),
                        ),
                      ),
                      Icon(Icons.notifications_none, color: Colors.white, size: 28),
                    ],
                  ),
                ),
                // Genius rewards card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('You have 3 Genius rewards', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text('10% discounts and so much more!', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text("You're 5 bookings away from Genius Level 2", style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                        ],
                      ),
                    ),
                  ),
                ),
                // Credits/vouchers card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.card_giftcard, color: Colors.blue, size: 32),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text('No Credits or vouchers yet', style: TextStyle(fontSize: 15)),
                          ),
                          Text('€ 0', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
                // Profile completion card

                // Login Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _navigateToLogin('your account'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WPConfig.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Sign in to access all features',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('Payment information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.wallet_giftcard, color: WPConfig.primaryColor),
                        title: Text('Rewards & Wallet'),
                        onTap: () => _navigateToLogin('Rewards & Wallet'),
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.payment, color: WPConfig.primaryColor),
                        title: Text('Payment methods'),
                        onTap: () => _navigateToLogin('Payment methods'),
                      ),
                    ],
                  ),
                ),
                // Section: Manage account
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('Manage account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.person_outline, color: WPConfig.primaryColor),
                        title: Text('Personal details'),
                        onTap: () => _navigateToLogin('Personal details'),
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.lock_outline, color: WPConfig.primaryColor),
                        title: Text('Security settings'),
                        onTap: () => _navigateToLogin('Security settings'),
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.group_outlined, color: WPConfig.primaryColor),
                        title: Text('Other travellers'),
                        onTap: () => _navigateToLogin('Other travellers'),
                      ),
                    ],
                  ),
                ),
                // Section: Preferences
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.devices_other, color: WPConfig.primaryColor),
                        title: Text('Device preferences'),
                        onTap: () => _navigateToLogin('Device preferences'),
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.flight, color: WPConfig.primaryColor),
                        title: Text('Travel preferences'),
                        onTap: () => _navigateToLogin('Travel preferences'),
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.email_outlined, color: WPConfig.primaryColor),
                        title: Text('Email preferences'),
                        onTap: () => _navigateToLogin('Email preferences'),
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.language),
                        title: Text('language'.tr()),
                        subtitle: Text(context.locale.languageCode == 'ar' ? 'العربية' : 'English'),
                        onTap: () {
                          final currentLocale = context.locale;
                          final newLocale = currentLocale.languageCode == 'ar'
                              ? Locale('en', 'US')
                              : Locale('ar', 'SA');
                          _showLanguageChangeDialog(context, newLocale);
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToLogin(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please log in to access $feature'),
        backgroundColor: WPConfig.primaryColor,
        duration: Duration(seconds: 2),
      ),
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  void _showLanguageChangeDialog(BuildContext context, Locale newLocale) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Language'),
        content: Text('Do you want to change the app language?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('OK'),
          ),
        ],
      ),
    );
    if (result == true) {
      await context.setLocale(newLocale);
      // Reload the app by popping all routes and pushing main
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  Widget _buildProfileSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: WPConfig.primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
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

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: WPConfig.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: WPConfig.primaryColor),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
