import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class AnimatedWidgetSwitcher extends StatelessWidget {
  const AnimatedWidgetSwitcher({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.scaled,
          fillColor: Colors.transparent,
          child: child,
        );
      },
      child: child,
    );
  }
}
