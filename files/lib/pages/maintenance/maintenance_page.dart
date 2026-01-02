import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/site_settings.dart';

class MaintenancePage extends StatelessWidget {
  final SiteSettings siteSettings;

  const MaintenancePage({
    Key? key,
    required this.siteSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40.h),
                // Maintenance Image
                if (siteSettings.maintenanceImg != null &&
                    siteSettings.maintenanceImg!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: 300.h,
                    margin: EdgeInsets.only(bottom: 40.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.network(
                        siteSettings.maintenanceImg!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.build, size: 80, color: Colors.grey[400]),
                          );
                        },
                      ),
                    ),
                  ),
                // Maintenance Icon
                Icon(
                  Icons.build_circle,
                  size: 80.sp,
                  color: Colors.orange,
                ),
                SizedBox(height: 24.h),
                // Title
                Text(
                  'Maintenance Mode',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                // Message
                if (siteSettings.maintenanceMsg != null &&
                    siteSettings.maintenanceMsg!.isNotEmpty)
                  Text(
                    siteSettings.maintenanceMsg!,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  )
                else
                  Text(
                    'We are upgrading our site. We will come back soon.\nPlease stay with us.\nThank you.',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                SizedBox(height: 40.h),
                // Website Title
                if (siteSettings.websiteTitle != null)
                  Text(
                    siteSettings.websiteTitle!,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

