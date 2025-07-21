import 'package:flutter/material.dart';
import '../../config/wp_config.dart';

class ServiceDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<String> features;
  final double price;

  const ServiceDetailPage({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.features,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: screenHeight * 0.3,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.arrow_back, color: WPConfig.primaryColor),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      WPConfig.primaryColor.withOpacity(0.1),
                      WPConfig.primaryColor.withOpacity(0.2),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: screenWidth * 0.2,
                    color: WPConfig.primaryColor,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.06,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: screenWidth * 0.035,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    'Features',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.045,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  ...features.map((feature) => Padding(
                    padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: WPConfig.primaryColor,
                          size: screenWidth * 0.04,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  SizedBox(height: screenHeight * 0.03),
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: WPConfig.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Starting from',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                            Text(
                              '\$$price',
                              style: TextStyle(
                                color: WPConfig.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.045,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Handle booking
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WPConfig.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.015,
                            ),
                          ),
                          child: Text(
                            'Book Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 