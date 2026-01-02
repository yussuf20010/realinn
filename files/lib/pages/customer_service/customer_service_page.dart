import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/constants/app_colors.dart';
import '../../services/site_settings_controller.dart';

class CustomerServicePage extends ConsumerStatefulWidget {
  const CustomerServicePage({Key? key}) : super(key: key);

  @override
  ConsumerState<CustomerServicePage> createState() =>
      _CustomerServicePageState();
}

class _CustomerServicePageState extends ConsumerState<CustomerServicePage> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primary(context);
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: Colors.white,
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
                    'customer_service'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 28 : 24,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'how_can_we_help'.tr(),
            style: TextStyle(
              fontSize: isTablet ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'get_in_touch_support'.tr(),
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: isTablet ? 32 : 24),

          // Email and Phone support options from site settings
          Consumer(
            builder: (context, ref, child) {
              final siteSettingsAsync = ref.watch(siteSettingsProvider);
              return siteSettingsAsync.when(
                data: (siteSettings) {
                  return Column(
                    children: [
                      // Email support
                      if (siteSettings.emailAddress != null && siteSettings.emailAddress!.isNotEmpty)
                        _buildSupportOption(
                          icon: Icons.email,
                          title: 'email_support'.tr(),
                          subtitle: siteSettings.emailAddress!,
                          action: 'send_email'.tr(),
                          onTap: () async {
                            final email = siteSettings.emailAddress!;
                            final uri = Uri.parse('mailto:$email');
                            try {
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('cannot_open_email'.tr())),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('error_opening_email'.tr())),
                              );
                            }
                          },
                          isTablet: isTablet,
                          primaryColor: primaryColor,
                        ),
                      if (siteSettings.emailAddress != null && siteSettings.emailAddress!.isNotEmpty)
                        SizedBox(height: 16),
                      // Phone support
                      if (siteSettings.contactNumber != null && siteSettings.contactNumber!.isNotEmpty)
                        _buildSupportOption(
                          icon: Icons.phone,
                          title: 'call_us'.tr(),
                          subtitle: siteSettings.contactNumber!,
                          action: 'call_now'.tr(),
                          onTap: () async {
                            final phoneNumber = siteSettings.contactNumber!;
                            final uri = Uri.parse('tel:$phoneNumber');
                            try {
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('cannot_make_call'.tr())),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('error_making_call'.tr())),
                              );
                            }
                          },
                          isTablet: isTablet,
                          primaryColor: primaryColor,
                        ),
                    ],
                  );
                },
                loading: () => Center(child: CircularProgressIndicator()),
                error: (_, __) => Text('error_loading_contact_info'.tr()),
              );
            },
          ),
        ],
      ),
    );
  }


  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String action,
    required VoidCallback onTap,
    required bool isTablet,
    required Color primaryColor,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.grey[600],
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
          TextButton(
            onPressed: onTap,
            child: Text(
              action,
              style: TextStyle(
                color: primaryColor,
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
