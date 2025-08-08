import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../config/dynamic_config.dart';

class MoreForYouSection extends ConsumerWidget {
  const MoreForYouSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final primaryColor = dynamicConfig.primaryColor;
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'More for you',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 16 : 18,
                color: Colors.black,
              ),
            ),
          ),
          
          // Horizontally scrollable image cards
          SizedBox(
            height: isTablet ? 120 : 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 4),
              children: [
                // First image card
                Container(
                  width: isTablet ? 160 : 180,
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        // Placeholder for image - you can replace with actual images
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.grey.shade300,
                          child: Icon(
                            Icons.people,
                            size: 40,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        // Gradient overlay
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Text overlay
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Text(
                            'Group Adventures',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 12 : 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Second image card
                Container(
                  width: isTablet ? 160 : 180,
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        // Placeholder for image
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.grey.shade300,
                          child: Icon(
                            Icons.laptop,
                            size: 40,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        // Gradient overlay
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Text overlay
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Text(
                            'Work & Travel',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 12 : 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Third image card
                Container(
                  width: isTablet ? 160 : 180,
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        // Placeholder for image
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.grey.shade300,
                          child: Icon(
                            Icons.beach_access,
                            size: 40,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        // Gradient overlay
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Text overlay
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Text(
                            'Beach Getaways',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 12 : 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Fourth image card
                Container(
                  width: isTablet ? 160 : 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        // Placeholder for image
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.grey.shade300,
                          child: Icon(
                            Icons.flag,
                            size: 40,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        // Gradient overlay
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Text overlay
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Text(
                            'City Breaks',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 12 : 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 