import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../config/components/headline_with_row.dart';
import '../config/constants/app_defaults.dart';

class CustomAppWidgets {
  static Widget searchBar(BuildContext context,
      {VoidCallback? onTap,
      String hintText = 'Search...',
      double horizontalPadding = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        // Replace with your AppDefaults.padding if needed
        vertical: 8.0,
      ),
      child: GestureDetector(
        onTap: onTap ??
            () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => const SearchPage()),
              // );
            },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color
                    ?.withOpacity(0.5),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                hintText,
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color
                      ?.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildAppBar(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDefaults.padding,
              vertical: 8.0,
            ),
            child: HeadlineRow(headline: 'explore'.tr()),
          ),
        ],
      ),
      centerTitle: false,
      automaticallyImplyLeading: true,
    );
  }

}
