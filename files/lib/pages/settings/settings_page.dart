import 'package:flutter/material.dart';
import 'package:realinn/widgets/custom_app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF6F7FB);
    const cardRadius = 12.0;
    const cardMargin = EdgeInsets.symmetric(vertical: 6);
    const cardPadding = EdgeInsets.symmetric(horizontal: 16);
    const blueChevron =
        Icon(Icons.chevron_right, color: Color(0xFF2196F3), size: 26);
    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        title: 'Settings',
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        children: [
          Container(
            margin: cardMargin,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(cardRadius),
            ),
            child: SwitchListTile(
              value: true,
              onChanged: (val) {},
              title: const Text('Notifications',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
              activeColor: Color(0xFF19C37D),
              contentPadding: cardPadding,
            ),
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            title: 'Privacy Policy',
            onTap: () => Navigator.pushNamed(context, '/privacy'),
            trailing: blueChevron,
          ),
          _SettingsTile(
            title: 'Terms & conditions',
            onTap: () => Navigator.pushNamed(context, '/terms'),
            trailing: blueChevron,
          ),
          _SettingsTile(
            title: 'About app',
            onTap: () => Navigator.pushNamed(context, '/about'),
            trailing: blueChevron,
          ),
          _SettingsTile(
            title: 'Help & Support',
            onTap: () => Navigator.pushNamed(context, '/help'),
            trailing: blueChevron,
          ),
          _SettingsTile(
            title: 'Rate the Mypass app',
            onTap: () => Navigator.pushNamed(context, '/rate'),
            trailing: blueChevron,
          ),
          _SettingsTile(
            title: 'FAQ',
            onTap: () => Navigator.pushNamed(context, '/faq'),
            trailing: blueChevron,
          ),
          const SizedBox(height: 32),
          _SettingsTile(
            title: 'Logout',
            onTap: () {},
            trailing: const SizedBox.shrink(),
            isLogout: true,
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Widget trailing;
  final bool isLogout;
  const _SettingsTile(
      {required this.title,
      required this.onTap,
      required this.trailing,
      this.isLogout = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isLogout ? FontWeight.w500 : FontWeight.w500,
            color: isLogout ? Color(0xFFFF3B30) : Colors.black,
            fontSize: 16,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
