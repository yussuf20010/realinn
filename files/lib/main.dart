import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;
import 'config/localization/app_locales.dart';
import 'config/routes/on_generate_route.dart';
import 'config/themes/theme_constants.dart';
import 'config/utils/app_utils.dart';
import 'config/wp_config.dart';
import 'config/dynamic_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  AppUtil.setDisplayToHighRefreshRate();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: AppLocales.supportedLocales,
        path: 'assets/lang',
        startLocale: AppLocales.english,
        fallbackLocale: AppLocales.english,
        child: RealInnApp(savedThemeMode: savedThemeMode),
      ),
    ),
  );
}

class RealInnApp extends StatelessWidget {
  const RealInnApp({Key? key, this.savedThemeMode}) : super(key: key);
  final AdaptiveThemeMode? savedThemeMode;

  @override
  Widget build(BuildContext context) {
    final dynamicConfig = ProviderScope.containerOf(context, listen: true)
        .read(dynamicConfigProvider);
    return AdaptiveTheme(
        light: AppTheme.lightTheme,
        dark: AppTheme.darkTheme,
        initial: savedThemeMode ?? AdaptiveThemeMode.light,
        builder: (theme, darkTheme) => GlobalLoaderOverlay(
              child: ScreenUtilInit(
                designSize: const Size(375, 812), // iPhone X design size
                minTextAdapt: true,
                splitScreenMode: true,
                useInheritedMediaQuery: true,
                builder: (context, child) => MaterialApp(
                  title: dynamicConfig.appName ?? WPConfig.appName,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  theme: theme,
                  darkTheme: darkTheme,
                  builder: (context, child) {
                    final mediaQuery = MediaQuery.of(context);
                    final width = mediaQuery.size.width;
                    final isTablet = width >= 768;
                    final textScale = isTablet ? 0.95 : 1.0;
 

                    // Handle RTL for Arabic
                    final isRTL = context.locale.languageCode == 'ar';
                    return MediaQuery(
                      data: mediaQuery.copyWith(
                        textScaler: TextScaler.linear(textScale),
                      ),
                      child: Directionality(
                        textDirection:
                            isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                        child: child ?? const SizedBox.shrink(),
                      ),
                    );
                  },
                  onGenerateRoute: RouteGenerator.onGenerate,
                  onUnknownRoute: (_) => RouteGenerator.errorRoute(),
                  debugShowCheckedModeBanner: false,
                ),
              ),
            ));
  }
}

class UpdateRequiredApp extends StatelessWidget {
  const UpdateRequiredApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.update,
                  size: 80, color: Colors.red), // An update icon
              Text(
                'force_update_required'.tr(),
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'force_update_message'.tr(),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
