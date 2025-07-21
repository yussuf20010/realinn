import 'package:flutter/material.dart';
import '../../config/wp_config.dart';
import '../hotel_details/service_detail_page.dart';

class ServiceProvidersPage extends StatefulWidget {
  const ServiceProvidersPage({Key? key}) : super(key: key);

  @override
  State<ServiceProvidersPage> createState() => _ServiceProvidersPageState();
}

class _ServiceProvidersPageState extends State<ServiceProvidersPage> {
  String selectedCategory = 'All';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = [
    'All',
    'Spa & Wellness',
    'Dining',
    'Fitness',
    'Transportation',
    'Entertainment',
  ];

  final Map<String, IconData> categoryIcons = {
    'All': Icons.grid_view,
    'Spa & Wellness': Icons.spa,
    'Dining': Icons.restaurant,
    'Fitness': Icons.fitness_center,
    'Transportation': Icons.directions_car,
    'Entertainment': Icons.movie,
  };

  final List<Map<String, dynamic>> services = [
    {
      'title': 'Luxury Spa & Wellness',
      'category': 'Spa & Wellness',
      'icon': Icons.spa,
      'description': 'Experience ultimate relaxation with our premium spa services.',
      'features': [
        'Professional massage therapists',
        'Various treatment options',
        'Private treatment rooms',
        'Relaxation area',
        'Premium spa products',
      ],
      'price': 150.0,
      'rating': 4.8,
      'location': 'Hotel Ground Floor',
    },
    {
      'title': 'Fine Dining Restaurant',
      'category': 'Dining',
      'icon': Icons.restaurant,
      'description': 'Savor exquisite cuisine prepared by our master chefs.',
      'features': [
        'International cuisine',
        'Expert chefs',
        'Elegant atmosphere',
        'Wine selection',
        'Private dining rooms',
      ],
      'price': 200.0,
      'rating': 4.9,
      'location': 'Hotel 1st Floor',
    },
    {
      'title': 'Fitness Center',
      'category': 'Fitness',
      'icon': Icons.fitness_center,
      'description': 'Stay active with our state-of-the-art fitness equipment.',
      'features': [
        'Modern equipment',
        'Personal trainers',
        'Group classes',
        'Yoga studio',
        'Locker rooms',
      ],
      'price': 50.0,
      'rating': 4.7,
      'location': 'Hotel 2nd Floor',
    },
    {
      'title': 'Luxury Car Service',
      'category': 'Transportation',
      'icon': Icons.directions_car,
      'description': 'Premium car rental and chauffeur services.',
      'features': [
        'Luxury vehicles',
        'Professional chauffeurs',
        '24/7 availability',
        'Airport transfers',
        'City tours',
      ],
      'price': 100.0,
      'rating': 4.8,
      'location': 'Hotel Lobby',
    },
    {
      'title': 'Movie Theater',
      'category': 'Entertainment',
      'icon': Icons.movie,
      'description': 'Enjoy the latest movies in our private theater.',
      'features': [
        'Latest releases',
        'Comfortable seating',
        'Dolby sound system',
        'Snack bar',
        'Private screenings',
      ],
      'price': 30.0,
      'rating': 4.6,
      'location': 'Hotel 3rd Floor',
    },
  ];

  List<Map<String, dynamic>> get filteredServices {
    return services.where((service) {
      final matchesCategory = selectedCategory == 'All' || service['category'] == selectedCategory;
      final matchesSearch = service['title'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          service['description'].toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: screenHeight * 0.15,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      WPConfig.primaryColor.withOpacity(0.1),
                      Colors.white,
                    ],
                  ),
                ),
              ),
            ),
            title: Row(
              children: [
                SizedBox(width: screenWidth * 0.02),
                Text(
                  'Hotel Services',
                  style: TextStyle(
                    color: WPConfig.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.06,
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search services...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.015,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    height: screenHeight * 0.06,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = category == selectedCategory;
                        return GestureDetector(
                          onTap: () => setState(() => selectedCategory = category),
                          child: Container(
                            margin: EdgeInsets.only(right: screenWidth * 0.03),
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.01,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? WPConfig.primaryColor : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  categoryIcons[category],
                                  color: isSelected ? Colors.white : Colors.grey[600],
                                  size: screenWidth * 0.04,
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey[600],
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: screenWidth * 0.035,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final service = filteredServices[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceDetailPage(
                            title: service['title'],
                            description: service['description'],
                            icon: service['icon'],
                            features: List<String>.from(service['features']),
                            price: service['price'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: screenHeight * 0.15,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  WPConfig.primaryColor.withOpacity(0.1),
                                  WPConfig.primaryColor.withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: Center(
                              child: Icon(
                                service['icon'],
                                size: screenWidth * 0.15,
                                color: WPConfig.primaryColor,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(screenWidth * 0.04),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        service['title'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: screenWidth * 0.045,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.03,
                                        vertical: screenHeight * 0.005,
                                      ),
                                      decoration: BoxDecoration(
                                        color: WPConfig.primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Color(0xFFFFC107),
                                            size: screenWidth * 0.04,
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          Text(
                                            service['rating'].toString(),
                                            style: TextStyle(
                                              color: WPConfig.primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: screenWidth * 0.035,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.grey[600],
                                      size: screenWidth * 0.04,
                                    ),
                                    SizedBox(width: screenWidth * 0.01),
                                    Text(
                                      service['location'],
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: screenWidth * 0.035,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Text(
                                  service['description'],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: screenWidth * 0.035,
                                    height: 1.5,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Starting from',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: screenWidth * 0.035,
                                      ),
                                    ),
                                    Text(
                                      '\$${service['price']}',
                                      style: TextStyle(
                                        color: WPConfig.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth * 0.045,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: filteredServices.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 