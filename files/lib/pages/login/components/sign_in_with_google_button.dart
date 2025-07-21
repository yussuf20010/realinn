// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:loader_overlay/loader_overlay.dart';
//
// import '../../../core/constants/constants.dart';
// import '../../../core/controllers/auth/auth_controller.dart';
//
// class SignInWithGoogleButton extends ConsumerWidget {
//   const SignInWithGoogleButton({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final auth = ref.read(authController.notifier);
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: AppDefaults.margin,
//         vertical: AppDefaults.margin,
//       ),
//       child: SizedBox(
//         width: double.infinity,
//         child: OutlinedButton.icon(
//           onPressed: () async {
//             context.loaderOverlay.show();
//             await auth.signInWithGoogle(context);
//             context.loaderOverlay.hide();
//           },
//           label: Text('sign_in_with_google'.tr()),
//           icon: const Icon(FontAwesomeIcons.google),
//         ),
//       ),
//     );
//   }
// }
