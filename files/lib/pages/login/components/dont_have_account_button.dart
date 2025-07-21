import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';

class DontHaveAccountButton extends StatelessWidget {
  const DontHaveAccountButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('dont_have_account'.tr()),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.signup);
            },
              style: TextButton.styleFrom(
    foregroundColor: Colors.blue, // Set the color of the button text
  ),

            child: Text(
              'sign_up'.tr(),
              style: TextStyle(
                color: Colors.blue, // Set your desired text color here
                fontSize: 16, // Optional: Adjust the font size if needed
                decoration: TextDecoration.underline, // Add underline
              ),
            ),
          )
        ],
      ),
    );
  }
}
