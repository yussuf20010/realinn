import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/auth/user_controller.dart';
import '../../config/wp_config.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../controllers/auth/auth_controller.dart';
import '../login/pages/login_page.dart';

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
          appBar: AppBar(
            backgroundColor: WPConfig.primaryColor,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Profile header
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        WPConfig.primaryColor,
                        WPConfig.primaryColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: WPConfig.primaryColor,
                          ),
                        ),
                        SizedBox(height: 16),
                        userAsync.when(
                          data: (user) {
                            if (user != null) {
                              return Column(
                                children: [
                                  Text(
                                    '${user.firstName} ${user.lastName}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    user.email,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  Text(
                                    'Guest',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                          loading: () => CircularProgressIndicator(color: Colors.white),
                          error: (e, _) => Text('Guest', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
                // Profile content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildProfileSection(
                        title: 'account_settings'.tr(),
                        items: [
                          _buildProfileItem(
                            icon: Icons.person_outline,
                            title: 'personal_information'.tr(),
                            onTap: () {},
                          ),
                          _buildProfileItem(
                            icon: Icons.notifications_outlined,
                            title: 'notifications'.tr(),
                            onTap: () {},
                          ),
                          _buildProfileItem(
                            icon: Icons.lock_outline,
                            title: 'security'.tr(),
                            onTap: () {},
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      _buildProfileSection(
                        title: 'preferences'.tr(),
                        items: [
                          ListTile(
                            leading: Icon(Icons.language),
                            title: Text('language'.tr()),
                            subtitle: Text(context.locale.languageCode == 'ar' ? 'العربية' : 'English'),
                            onTap: () {
                              final currentLocale = context.locale;
                              if (currentLocale.languageCode == 'ar') {
                                context.setLocale(Locale('en', 'US'));
                              } else {
                                context.setLocale(Locale('ar', 'SA'));
                              }
                            },
                          ),
                          _buildProfileItem(
                            icon: Icons.currency_exchange,
                            title: 'currency'.tr(),
                            subtitle: 'USD',
                            onTap: () {},
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      _buildProfileSection(
                        title: 'support'.tr(),
                        items: [
                          _buildProfileItem(
                            icon: Icons.help_outline,
                            title: 'help_center'.tr(),
                            onTap: () {},
                          ),
                          _buildProfileItem(
                            icon: Icons.info_outline,
                            title: 'about'.tr(),
                            onTap: () {},
                          ),
                        ],
                      ),
                      userAsync.when(
                        data: (user) {
                          if (user != null) {
                            // Logged in: show logout
                            return ElevatedButton(
                              onPressed: () async {
                                await authNotifier.logout(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'sign_out'.tr(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          } else {
                            // Not logged in: show login
                            return ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => LoginPage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: WPConfig.primaryColor,
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'login'.tr(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                        },
                        loading: () => SizedBox.shrink(),
                        error: (e, _) => ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => LoginPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WPConfig.primaryColor,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'login'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                                             ),
                       SizedBox(height: 24), // Add extra padding at bottom for nav bar
                     ],
                   ),
                 ),
               ],
             ),
           ),
         );
       },
     );
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
        SizedBox(height: 16),
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
          padding: const EdgeInsets.all(16),
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
