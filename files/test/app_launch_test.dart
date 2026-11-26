import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:realinn/config/core_provider.dart';
import 'package:realinn/config/wp_config.dart';
import 'package:realinn/models/site_settings.dart';
import 'package:realinn/pages/auth/login.dart';
import 'package:realinn/pages/entrypoint/loading_app_page.dart';
import 'package:realinn/pages/maintenance/maintenance_page.dart';
import 'package:realinn/services/site_settings_controller.dart';

Widget _buildTestApp(List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) => const MaterialApp(
        home: LoadingAppPage(),
      ),
    ),
  );
}

void main() {
  test('WPConfig builds site-settings endpoint from configured URL', () {
    expect(WPConfig.url, isNotEmpty);
    expect(WPConfig.siteSettingsApiUrl, '${WPConfig.url}/api/site-settings');
  });

  testWidgets('Launches into LoginPage when site settings load normally',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildTestApp([
        coreAppStateProvider.overrideWith((ref) async => AppState.loggedOut),
        siteSettingsProvider.overrideWith(
          (ref) async => SiteSettings(
            websiteTitle: 'RylN',
            maintenanceStatus: 0,
            primaryColor: '7767D7',
          ),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets(
      'Falls back to LoginPage instead of hanging when site settings fail',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildTestApp([
        coreAppStateProvider.overrideWith((ref) async => AppState.loggedOut),
        siteSettingsProvider.overrideWith(
          (ref) async => throw Exception('Network unreachable'),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('Shows MaintenancePage when maintenanceStatus is 1',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildTestApp([
        coreAppStateProvider.overrideWith((ref) async => AppState.loggedOut),
        siteSettingsProvider.overrideWith(
          (ref) async => SiteSettings(
            websiteTitle: 'RylN',
            maintenanceStatus: 1,
            maintenanceMsg: 'Under maintenance',
          ),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaintenancePage), findsOneWidget);
  });
}
