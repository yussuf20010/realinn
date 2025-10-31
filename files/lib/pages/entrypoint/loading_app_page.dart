import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/core_provider.dart';
import '../../config/wp_config.dart';
import '../main/main_scaffold.dart';
import '../auth/login.dart';
import 'components/loading_dependency.dart';
import 'package:easy_localization/easy_localization.dart';

class LoadingAppPage extends ConsumerWidget {
  const LoadingAppPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(coreAppStateProvider(context));
    return appState.map(
        data: (initialState) {
          switch (initialState.value) {
            case AppState.loggedIn:
              return MainScaffold();
            case AppState.loggedOut:
              return WPConfig.forceUserToLoginEverytime
                  ? const LoginPage()
                  : MainScaffold();
            default:
              return MainScaffold();
          }
        },
        error: (t) => Text('unknown_error'.tr()),
        loading: (t) => const LoadingDependencies());
  }
}
