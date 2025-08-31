import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/wp_config.dart';
import '../../models/hotel.dart';
import '../../controllers/hotel_controller.dart';

class CountryHotelsPage extends ConsumerStatefulWidget {
  final String countryName;

  const CountryHotelsPage({
    Key? key,
    required this.countryName,
  }) : super(key: key);

  @override
  ConsumerState<CountryHotelsPage> createState() => _CountryHotelsPageState();
}

class _CountryHotelsPageState extends ConsumerState<CountryHotelsPage> {
  List<Hotel> _countryHotels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCountryHotels();
  }

  Future<void> _loadCountryHotels() async {
    try {
      final allHotels = await ref.read(hotelProvider.future);
      final countryHotels = allHotels
          .where((hotel) =>
              hotel.country?.toLowerCase() ==
                  widget.countryName.toLowerCase() ||
              hotel.location
                      ?.toLowerCase()
                      .contains(widget.countryName.toLowerCase()) ==
                  true)
          .toList();

      setState(() {
        _countryHotels = countryHotels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load country hotels: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = WPConfig.navbarColor;
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: _buildCustomAppBar(context, primaryColor, isTablet),
      ),
      body: _buildMainContent(isTablet, primaryColor),
    );
  }

  Widget _buildCustomAppBar(
      BuildContext context, Color primaryColor, bool isTablet) {
    return Container(
      color: primaryColor,
      child: SafeArea(
        child: Container(
          height: 80,
          child: Row(
            children: [
              // Back button
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              // Title
              Expanded(
                child: Center(
                  child: Text(
                    'Hotels in ${widget.countryName}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 28 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Placeholder for symmetry
              SizedBox(width: 56),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isTablet, Color primaryColor) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (_countryHotels.isEmpty) {
      return _buildNoCountryHotels(isTablet, primaryColor);
    }

    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              Icon(Icons.public, color: primaryColor, size: isTablet ? 24 : 20),
              SizedBox(width: 12),
              Text(
                '${_countryHotels.length} Hotels in ${widget.countryName}',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),

        // Hotels list
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            itemCount: _countryHotels.length,
            itemBuilder: (context, index) {
              final hotel = _countryHotels[index];
              return _buildHotelCard(hotel, isTablet, primaryColor);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoCountryHotels(bool isTablet, Color primaryColor) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.public_outlined,
              size: isTablet ? 80 : 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No hotels found in ${widget.countryName}',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try searching for a different country',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text('Back to Search'),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hotel image
          Container(
            width: double.infinity,
            height: isTablet ? 200 : 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              image: DecorationImage(
                image: NetworkImage(
                    hotel.imageUrl ?? 'https://via.placeholder.com/300x200'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Hotel info
          Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        hotel.name ?? 'Hotel Name',
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${hotel.stars ?? 0}★',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  hotel.location ?? 'Location not specified',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'From ',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'EGP ${hotel.priceRange ?? '0'}',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    Text(
                      ' / night',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: isTablet ? 48 : 44,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to hotel details
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Navigate to ${hotel.name} details')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.bold,
                      ),
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
