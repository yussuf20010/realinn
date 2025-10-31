import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/assets.dart';

/// Dynamic App Logo Based on Theme
class AppLogo extends ConsumerWidget {
  const AppLogo({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
      return Image.asset(AssetsManager.appLogo);
  }
}
