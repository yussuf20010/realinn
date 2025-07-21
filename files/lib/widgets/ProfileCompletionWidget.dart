import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ProfileCompletionWidget extends StatelessWidget {
  final int completedSteps;
  final int totalSteps;

  const ProfileCompletionWidget({
    Key? key,
    required this.completedSteps,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double progress = completedSteps / totalSteps;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryImportant, // Start color
            AppColors.primary, // End color
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: Row(
        children: [
          // Circular Progress Bar
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background Circle
                CircularProgressIndicator(
                  value: 1.0, // Full circle (background)
                  backgroundColor: Colors.white.withOpacity(0.3), // Light background
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent), // Transparent fill
                ),
                // Progress Circle
                CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.transparent, // Transparent background
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // White progress
                  strokeWidth: 6, // Thickness of the progress bar
                ),
                // Progress Text
                Text(
                  "${(progress * 100).toStringAsFixed(0)}%",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16), // Spacing between progress bar and text
          // Text Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Complete your profile",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$completedSteps/$totalSteps",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white, // White text
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