import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/core_provider.dart';
import '../../services/site_settings_controller.dart';
import '../main/main_scaffold.dart';
import '../welcome/welcome_page.dart';
import '../auth/login.dart';
import '../maintenance/maintenance_page.dart';
import 'components/loading_dependency.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/token_storage_service.dart';

class LoadingAppPage extends ConsumerWidget {
  const LoadingAppPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(coreAppStateProvider(context));
    final siteSettingsAsync = ref.watch(siteSettingsProvider);
    
    // Check maintenance mode first
    return siteSettingsAsync.when(
      data: (siteSettings) {
        // Check if maintenance mode is enabled
        if (siteSettings.maintenanceStatus == 1) {
          return MaintenancePage(siteSettings: siteSettings);
        }
        
        // Continue with normal app flow
        return appState.map(
          data: (initialState) {
            switch (initialState.value) {
              case AppState.loggedIn:
                return FutureBuilder<String?>(
                  future: TokenStorageService.getUserType(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingDependencies();
                    }
                    final userType = snapshot.data;
                    // If user is hotel or service provider, show welcome page
                    if (userType == 'hotel' || userType == 'service_provider') {
                      return WelcomePage();
                    }
                    // Otherwise show main scaffold (for regular users)
                    return MainScaffold();
                  },
                );
              case AppState.loggedOut:
                // Always show login page when logged out
                return const LoginPage();
              default:
                return const LoginPage();
            }
          },
          error: (t) => Text('unknown_error'.tr()),
          loading: (t) => const LoadingDependencies(),
        );
      },
      loading: () => const LoadingDependencies(),
      error: (e, _) => const LoadingDependencies(),
    );
  }
}
