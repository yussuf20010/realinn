import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import '../../../config/constants/app_defaults.dart';
import '../../../config/constants/sizedbox_const.dart';
import '../../../services/internet/reconnecting_provider.dart';

class InternetNotAvailablePage extends StatelessWidget {
  const InternetNotAvailablePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text(
            'No Internet Available',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width * 0.5,
            child: Lottie.asset('assets/animations/no_internet_animation.json'),
          ),
          const SizedBox(height: AppDefaults.margin),
          Text(
            'Currently you don\'t have internet available',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Please open your settings and enable internet by turning wifi or mobile data',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDefaults.margin),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  AppSettings.openAppSettings(type: AppSettingsType.wifi);
                },
                child: const Text('Open Settings'),
              ),
            ),
          ),
          AppSizedBox.h10,
          const ReconnectingWidget(),
          const Spacer(),
        ],
      ),
    );
  }
}

class ReconnectingWidget extends ConsumerWidget {
  const ReconnectingWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reconnnecting = ref.watch(reconnectingInternetProvider);
    return Container(
      padding: const EdgeInsets.all(AppDefaults.padding),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: AppDefaults.borderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimationWidget.beat(color: Colors.white, size: 14),
          AppSizedBox.w16,
          Text('Reconnecting in ${reconnnecting.secondsRemaining} Seconds...'),
        ],
      ),
    );
  }
}
