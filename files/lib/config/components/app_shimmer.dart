import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../config/constants/app_colors.dart';
import '../../../config/constants/sizedbox_const.dart';
import '../constants/app_defaults.dart';


class AppShimmer extends StatelessWidget {
  const AppShimmer({
    Key? key,
    required this.child,
    this.enabled = true,
  }) : super(key: key);

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      highlightColor: Theme.of(context).cardColor,
      baseColor: AppColors.primary.withOpacity(0.1),
      enabled: enabled,
      child: child,
    );
  }
}
