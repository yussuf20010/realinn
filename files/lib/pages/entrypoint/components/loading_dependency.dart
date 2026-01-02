import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../config/constants/assets.dart';
import '../../../config/dynamic_config.dart';

class LoadingDependencies extends ConsumerWidget {
  const LoadingDependencies({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final primaryColor = dynamicConfig.primaryColor;
    
    // Get logo from API (prefer favicon, then logo, then logoTwo)
    final logoUrl = dynamicConfig.favicon ?? dynamicConfig.logoUrl ?? dynamicConfig.logoTwo;
    
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 7),
            // Use dynamic logo from API (favicon, logo, or logoTwo)
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: logoUrl != null && logoUrl.isNotEmpty
                  ? Image.network(
                      logoUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(AssetsManager.appLogo);
                      },
                    )
                  : Image.asset(AssetsManager.appLogo),
            ),
            const Spacer(flex: 5),
            LoadingAnimationWidget.threeArchedCircle(
              color: primaryColor,
              size: 50,
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
