import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/site_settings_controller.dart';

class WhatsAppFloatingButton extends ConsumerWidget {
  const WhatsAppFloatingButton({Key? key}) : super(key: key);

  Future<void> _openWhatsApp(String phoneNumber, String? message) async {
    // Remove any non-digit characters except +
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Ensure it starts with country code
    if (!cleanNumber.startsWith('+')) {
      cleanNumber = '+$cleanNumber';
    }

    final url = message != null && message.isNotEmpty
        ? 'https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}'
        : 'https://wa.me/$cleanNumber';

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('Could not launch WhatsApp: $url');
      }
    } catch (e) {
      print('Error launching WhatsApp: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final siteSettingsAsync = ref.watch(siteSettingsProvider);

    return siteSettingsAsync.when(
      data: (siteSettings) {
        // Check if WhatsApp is enabled
        if (siteSettings.whatsappStatus != 1 ||
            siteSettings.whatsappNumber == null ||
            siteSettings.whatsappNumber!.isEmpty) {
          return SizedBox.shrink(); // Don't show if disabled or no number
        }

        return Positioned(
          bottom: 80.h,
          right: 20.w,
          child: Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: Color(0xFF25D366), // WhatsApp green
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF25D366).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _openWhatsApp(
                    siteSettings.whatsappNumber!,
                    siteSettings.whatsappHeaderTitle ?? 'whatsapp_default_message'.tr(),
                  );
                },
                borderRadius: BorderRadius.circular(30),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Main phone icon
                      Icon(
                        Icons.phone,
                        color: Colors.white,
                        size: 28.sp,
                      ),
                      // WhatsApp chat bubble indicator on top right
                      Positioned(
                        right: 6.w,
                        top: 6.h,
                        child: Container(
                          width: 14.w,
                          height: 14.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Color(0xFF25D366), width: 1.5),
                          ),
                          child: Icon(
                            Icons.chat_bubble,
                            color: Color(0xFF25D366),
                            size: 8.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => SizedBox.shrink(),
      error: (_, __) => SizedBox.shrink(),
    );
  }
}
