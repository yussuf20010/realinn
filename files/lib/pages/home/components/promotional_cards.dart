import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../config/dynamic_config.dart';

class PromotionalCards extends ConsumerWidget {
  const PromotionalCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final primaryColor = dynamicConfig.primaryColor;
    final isTablet = MediaQuery.of(context).size.width >= 768;
    final screenWidth = MediaQuery.of(context).size.width;
    // Make card height relative to screen to avoid overflow and keep equal size
    final double cardHeight = isTablet ? screenWidth * 0.18 : screenWidth * 0.32;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Travel more, spend less',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 16 : 18,
                color: Colors.black,
              ),
            ),
          ),
          
          // Cards row
          Row(
            children: [
              // Genius card
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: isTablet ? 4 : 8),
                  height: cardHeight,
                  padding: EdgeInsets.all(isTablet ? 12 : 16),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Genius',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 14 : 16,
                        ),
                      ),
                      Text(
                        'Nelson, you\'re at Genius Level 2 in our loyalty program',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 12 : 14,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Discount card
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: isTablet ? 4 : 8),
                  height: cardHeight,
                  padding: EdgeInsets.all(isTablet ? 12 : 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '10%-15% discounts',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 14 : 16,
                        ),
                      ),
                      Text(
                        'Enjoy discounts at participating properties worldwide',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: isTablet ? 12 : 14,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 