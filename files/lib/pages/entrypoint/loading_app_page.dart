import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/core_provider.dart';
import '../../config/wp_config.dart';
import '../home/home_page.dart';
import '../login/login_intro_page.dart';
import 'components/loading_dependency.dart';


class LoadingAppPage extends ConsumerWidget {
  const LoadingAppPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(coreAppStateProvider(context));
    return appState.map(
        data: (initialState) {
          switch (initialState.value) {
            case AppState.loggedIn:
              return HomePage();
            case AppState.loggedOut:
              return WPConfig.forceUserToLoginEverytime
                  ? const LoginIntroPage()
                  :  HomePage();
            default:
              return  HomePage();
          }
        },
        error: (t) => const Text('Unknown Error'),
        loading: (t) => const LoadingDependencies());
  }
}