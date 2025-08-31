import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/wp_config.dart';
import '../../providers/favorites_provider.dart';
import '../../models/hotel.dart';
import '../hotel_details/hotel_details_page.dart';

class FavouritesPage extends ConsumerStatefulWidget {
  const FavouritesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends ConsumerState<FavouritesPage> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = WPConfig.navbarColor;
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100), // App bar height
        child: _buildCustomAppBar(context, primaryColor, isTablet),
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              100, // Adjusted for new app bar height
        ),
        child: _buildMainContent(isTablet, primaryColor),
      ),
    );
  }

  Widget _buildCustomAppBar(
      BuildContext context, Color primaryColor, bool isTablet) {
    return Container(
      color: primaryColor,
      child: SafeArea(
        child: Column(
          children: [
            // Main app bar content
            Container(
              height: 80,
              child: Center(
                child: Text(
                  'Saved',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 28 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isTablet, Color primaryColor) {
    final favorites = ref.watch(favoritesProvider);

    if (favorites.isEmpty) {
      return _buildEmptyState(isTablet, primaryColor);
    }

    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Row(
            children: [
              Icon(Icons.favorite,
                  color: primaryColor, size: isTablet ? 24 : 20),
              SizedBox(width: 8),
              Text(
                '${favorites.length} saved ${favorites.length == 1 ? 'hotel' : 'hotels'}',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),

        // Favorites list
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final hotel = favorites[index];
              return _buildHotelCard(hotel, isTablet, primaryColor);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isTablet, Color primaryColor) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Property illustration
            Container(
              width: isTablet ? 250 : 180,
              height: isTablet ? 200 : 150,
              child: Stack(
                children: [
                  // Background card (Hill view Apartments)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: isTablet ? 120 : 90,
                      height: isTablet ? 80 : 60,
                      decoration: BoxDecoration(
                        color: Colors.orange[300],
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.apartment,
                                  color: Colors.white,
                                  size: isTablet ? 16 : 12,
                                ),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Hill view',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isTablet ? 12 : 10,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Apartments',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 10 : 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Front card (Hotel Downtown)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: isTablet ? 140 : 100,
                      height: isTablet ? 100 : 75,
                      decoration: BoxDecoration(
                        color: Colors.orange[400],
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: isTablet ? 20 : 16,
                                  height: isTablet ? 20 : 16,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.favorite,
                                    color: Colors.orange[600],
                                    size: isTablet ? 14 : 12,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Downtown',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 12 : 10,
                              ),
                            ),
                            SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Decorative elements
                  Positioned(
                    top: isTablet ? 20 : 15,
                    left: isTablet ? 40 : 30,
                    child: Container(
                      width: isTablet ? 8 : 6,
                      height: isTablet ? 8 : 6,
                      decoration: BoxDecoration(
                        color: Colors.blue[200],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: isTablet ? 30 : 20,
                    right: isTablet ? 60 : 40,
                    child: Container(
                      width: isTablet ? 6 : 4,
                      height: isTablet ? 6 : 4,
                      decoration: BoxDecoration(
                        color: Colors.blue[300],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: isTablet ? 32 : 24),

            // Heading
            Text(
              'Save what you like for later',
              style: TextStyle(
                fontSize: isTablet ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: isTablet ? 16 : 12),

            // Description
            Text(
              'Create lists of your favorite properties to help you share, compare, and book.',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),

            SizedBox(height: isTablet ? 32 : 24),

            // Primary button
            Container(
              width: double.infinity,
              height: isTablet ? 60 : 60,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to search/home
                  Navigator.pushReplacementNamed(context, '/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Start your search',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: isTablet ? 16 : 12),

            // Secondary button
            TextButton(
              onPressed: () {
                // Navigate to search/home
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Text(
                'Create a list',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelCard(Hotel hotel, bool isTablet, Color primaryColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HotelDetailsPage(hotel: hotel),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Row(
            children: [
              // Hotel image placeholder
              Container(
                width: isTablet ? 80 : 60,
                height: isTablet ? 80 : 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.hotel,
                  color: Colors.grey[400],
                  size: isTablet ? 32 : 24,
                ),
              ),

              SizedBox(width: 16),

              // Hotel details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name ?? 'Hotel Name',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 4),

                    if (hotel.city != null)
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              color: Colors.grey[600], size: 16),
                          SizedBox(width: 4),
                          Text(
                            hotel.city!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isTablet ? 14 : 12,
                            ),
                          ),
                        ],
                      ),

                    SizedBox(height: 8),

                    // Rating placeholder
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.yellow[600], size: 16),
                        SizedBox(width: 4),
                        Text(
                          '4.5',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Remove from favorites button
              IconButton(
                onPressed: () {
                  ref.read(favoritesProvider.notifier).removeHotel(hotel);
                },
                icon: Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: isTablet ? 24 : 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
