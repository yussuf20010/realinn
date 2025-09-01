import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../config/wp_config.dart';

class CustomerServicePage extends ConsumerStatefulWidget {
  const CustomerServicePage({Key? key}) : super(key: key);

  @override
  ConsumerState<CustomerServicePage> createState() =>
      _CustomerServicePageState();
}

class _CustomerServicePageState extends ConsumerState<CustomerServicePage> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = WPConfig.navbarColor;
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

          // Chat option
          _buildChatOption(isTablet, primaryColor),
          SizedBox(height: 20),

          // Other support options
          _buildSupportOption(
            icon: Icons.phone,
            title: 'call_us'.tr(),
            subtitle: 'speak_directly_team'.tr(),
            action: 'call_now'.tr(),
            onTap: () {
              // Handle phone call
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('calling_customer_service'.tr())),
              );
            },
            isTablet: isTablet,
            primaryColor: primaryColor,
          ),
          SizedBox(height: 16),

          _buildSupportOption(
            icon: Icons.email,
            title: 'email_support'.tr(),
            subtitle: 'send_detailed_message'.tr(),
            action: 'send_email'.tr(),
            onTap: () {
              // Handle email
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('opening_email_client'.tr())),
              );
            },
            isTablet: isTablet,
            primaryColor: primaryColor,
          ),
          SizedBox(height: 16),

          _buildSupportOption(
            icon: Icons.help_outline,
            title: 'faq'.tr(),
            subtitle: 'find_common_answers'.tr(),
            action: 'browse_faq'.tr(),
            onTap: () {
              // Handle FAQ
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('opening_faq_section'.tr())),
              );
            },
            isTablet: isTablet,
            primaryColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildChatOption(bool isTablet, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.chat_bubble,
                  color: Colors.white,
                  size: isTablet ? 28 : 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                                         Text(
                       'live_chat'.tr(),
                       style: TextStyle(
                         fontSize: isTablet ? 22 : 20,
                         fontWeight: FontWeight.bold,
                         color: Colors.black,
                       ),
                     ),
                    SizedBox(height: 4),
                                         Text(
                       'chat_support_real_time'.tr(),
                       style: TextStyle(
                         fontSize: isTablet ? 16 : 14,
                         color: Colors.grey[600],
                       ),
                     ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: isTablet ? 56 : 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/chat');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
                             child: Text(
                 'start_chat'.tr(),
                 style: TextStyle(
                   fontSize: isTablet ? 18 : 16,
                   fontWeight: FontWeight.bold,
                 ),
               ),
            ),
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
