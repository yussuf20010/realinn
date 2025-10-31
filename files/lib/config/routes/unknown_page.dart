import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import '../constants/app_defaults.dart';
import '../constants/assets.dart';
import '../constants/sizedbox_const.dart';
import 'app_routes.dart';

class UnknownPage extends StatelessWidget {
  const UnknownPage({
    Key? key,
    this.errorMessage,
  }) : super(key: key);

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AssetsManager.error),
          AppSizedBox.h16,
          AppSizedBox.h16,
          Text(
            'Oops! No Page found with this name',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
          ),
          AppSizedBox.h16,
          Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.entryPoint);
                },
                label: Text('go_back'.tr(),
                style: TextStyle(
      color: Colors.blue, // Set your desired text color here
      fontSize: 16, // Optional: Adjust the font size if needed
      decoration: TextDecoration.underline, // Add underline
    ),
  ),

                icon: const Icon(IconlyLight.arrowLeft),
              ),
            ),
          )
        ],
      ),
    );
  }
}
