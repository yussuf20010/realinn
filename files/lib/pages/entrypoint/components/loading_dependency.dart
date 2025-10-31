import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../config/constants/app_colors.dart';
import '../../../config/constants/assets.dart';

class LoadingDependencies extends StatelessWidget {
  const LoadingDependencies({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 7),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: Image.asset(AssetsManager.appLogo),
            ),
            const Spacer(flex: 5),
            LoadingAnimationWidget.threeArchedCircle(
              color: AppColors.primary,
              size: 50,
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
