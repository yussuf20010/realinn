import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../config/dynamic_config.dart';
import '../../../../providers/favorites_provider.dart';
import '../../../../core/utils/page_transitions.dart';
import '../../../models/hotel.dart';
import '../../../models/location.dart' as location_model;
import '../../hotel_details/hotel_details_page.dart';

class HotelCard extends ConsumerWidget {
  final Hotel hotel;
  final location_model.City? city;
  final location_model.Country? country;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;

  const HotelCard({
    Key? key,
    required this.hotel,
    this.city,
    this.country,
    this.onFavoriteTap,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final primaryColor = dynamicConfig.primaryColor;
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _navigateToHotelDetails(context),
                                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 0, 
                      vertical: isTablet ? 12 : 8
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(0),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(isTablet ? 0.15 : 0.1),
                          blurRadius: isTablet ? 16 : 12,
                          offset: Offset(0, isTablet ? 6 : 4),
                          spreadRadius: 1,
                        ),
                      ],
                    ),
        child: ClipRect(
          child: isTablet ? _buildTabletLayout(primaryColor, isTablet, context) : _buildMobileLayout(primaryColor, isTablet, context),
        ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(Color primaryColor, bool isTablet, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hotel Image Section (Left - 40% width)
        Expanded(
          flex: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0),
              bottomLeft: Radius.circular(0),
            ),
            child: AspectRatio(
              aspectRatio: 1.2,
              child: _buildHotelImage(),
            ),
          ),
        ),
        
        // Hotel Details Section (Right - 60% width)
        Expanded(
          flex: 6,
          child: Padding(
            padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and favorite button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hotel.name ?? 'Hotel Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (city?.name != null)
                            Text(
                              '- ${city!.name}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        final favorites = ref.watch(favoritesProvider);
                        final isFavorite = favorites.any((h) => h.id == hotel.id);
                        return GestureDetector(
                          onTap: () {
                            ref.read(favoritesProvider.notifier).toggleFavorite(hotel, context);
                          },
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 200),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              key: ValueKey(isFavorite),
                              color: isFavorite ? Colors.red : Colors.grey[600],
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                
                SizedBox(height: 8),
                
                // Rating Section (Compact for mobile)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    // Stars
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        if (index < (hotel.rate ?? 0).floor()) {
                          return Icon(Icons.star, color: Colors.amber, size: 14);
                        } else if (index == (hotel.rate ?? 0).floor() && 
                                 (hotel.rate ?? 0) % 1 > 0) {
                          return Icon(Icons.star_half, color: Colors.amber, size: 14);
                        } else {
                          return Icon(Icons.star_border, color: Colors.amber, size: 14);
                        }
                      }),
                    ),
                  ],
                ),
                
                SizedBox(height: 6),
                
                // Review Score (Compact)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${hotel.rate?.toStringAsFixed(1) ?? "N/A"}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Text(
                      _getRatingText(hotel.rate),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      ' · ${_getReviewCount()} reviews',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                
                SizedBox(height: 8),
                
                // Location Details (Compact)
                if (hotel.latitude != null && hotel.longitude != null) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[600], size: 12),
                      SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          '${_calculateDistance(hotel.latitude!, hotel.longitude!)} km from downtown',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.beach_access, color: Colors.grey[600], size: 12),
                      SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          '${_calculateBeachDistance(hotel.latitude!, hotel.longitude!)} m from beach',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                ],
                
                // Room Type
                Text(
                  'Hotel room: ${_getBedInfo()}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: 8),
                
                // Pricing Section (Compact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            'US\$${hotel.oldPrice ?? hotel.priceRange ?? "0"}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                              decoration: TextDecoration.lineThrough,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'US\$${hotel.priceRange ?? "0"}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '+US\$${_calculateTaxes(hotel.priceRange)} taxes and fees',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
          ],
        ),
                
                SizedBox(height: 6),
                
                // Availability Warning (Compact)
                Text(
                  'Only ${_getRandomAvailability()} left at this price on',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.red,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                GestureDetector(
                  onTap: () => _navigateToHotelDetails(context),
                  child: Text(
                    'RealInn',
                    style: TextStyle(
                      fontSize: 10,
                      color: primaryColor,
                      decoration: TextDecoration.underline,
                          ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(Color primaryColor, bool isTablet, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hotel Image Section (Full width for tablet)
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
          child: AspectRatio(
            aspectRatio: 2.5,
            child: _buildHotelImage(),
          ),
        ),
        
        // Hotel Details Section (Below image for tablet)
            Padding(
          padding: EdgeInsets.all(20),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and favorite button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                          hotel.name ?? 'Hotel Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (city?.name != null)
                                Text(
                            '- ${city!.name}',
                                  style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                    ],
                  ),
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final isFavorite = ref.watch(favoritesProvider.notifier).isFavorite(hotel);
                      return GestureDetector(
                        onTap: () {
                          ref.read(favoritesProvider.notifier).toggleFavorite(hotel, context);
                        },
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            key: ValueKey(isFavorite),
                            color: isFavorite ? Colors.red : Colors.grey[600],
                            size: 28,
                          ),
                        ), 
                      );
                    },
                  ),
                          ],
                        ),
              
              SizedBox(height: 12),
              
              // Rating Section (Expanded for tablet)
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  // Stars
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      if (index < (hotel.rate ?? 0).floor()) {
                        return Icon(Icons.star, color: Colors.amber, size: 20);
                      } else if (index == (hotel.rate ?? 0).floor() && 
                               (hotel.rate ?? 0) % 1 > 0) {
                        return Icon(Icons.star_half, color: Colors.amber, size: 20);
                      } else {
                        return Icon(Icons.star_border, color: Colors.amber, size: 20);
                      }
                    }),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Review Score (Expanded)
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${hotel.rate?.toStringAsFixed(1) ?? "N/A"}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    _getRatingText(hotel.rate),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                                    Text(
                    ' · ${_getReviewCount()} reviews',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                                 ],
                               ),
              
              SizedBox(height: 20),
              
              // Location Details (Expanded)
              if (hotel.latitude != null && hotel.longitude != null) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, color: Colors.grey[600], size: 20),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${_calculateDistance(hotel.latitude!, hotel.longitude!)} km from downtown',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.beach_access, color: Colors.grey[600], size: 20),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${_calculateBeachDistance(hotel.latitude!, hotel.longitude!)} m from beach',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
              ],
              
              // Room Type
              Text(
                'Hotel room: ${_getBedInfo()}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: 20),
              
              // Pricing Section (Expanded)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'US\$${hotel.oldPrice ?? hotel.priceRange ?? "0"}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                            decoration: TextDecoration.lineThrough,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'US\$${hotel.priceRange ?? "0"}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '+US\$${_calculateTaxes(hotel.priceRange)} taxes and fees',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Availability Warning (Expanded)
              Text(
                'Only ${_getRandomAvailability()} left at this price on',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              GestureDetector(
                onTap: () => _navigateToHotelDetails(context),
                child: Text(
                  'RealInn',
                  style: TextStyle(
                    fontSize: 16,
                    color: primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHotelImage() {
    if (hotel.images != null && hotel.images!.isNotEmpty) {
      return Image.network(
        hotel.images!.first,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholderImage();
        },
        // Add timeout to prevent long loading
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: Duration(milliseconds: 300),
            child: child,
          );
        },
      );
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[200]!,
            Colors.grey[300]!,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.hotel,
                color: Colors.grey[600],
                size: 32,
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                hotel.name?.split(' ').take(2).join(' ') ?? 'Hotel',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(double? rating) {
    if (rating == null) return 'N/A';
    if (rating >= 9.0) return 'Exceptional';
    if (rating >= 8.0) return 'Excellent';
    if (rating >= 7.0) return 'Very Good';
    if (rating >= 6.0) return 'Good';
    if (rating >= 5.0) return 'Average';
    return 'Below Average';
  }

  String _getBedInfo() {
    // This should come from your dynamic data
    return '1 bed';
  }

  double _calculateDistance(double lat, double lng) {
    // This should calculate actual distance from your data
    // Placeholder calculation - replace with actual logic
    return ((lat * 100) % 10).roundToDouble();
  }

  double _calculateBeachDistance(double lat, double lng) {
    // This should calculate actual beach distance from your data
    // Placeholder calculation - replace with actual logic
    return ((lng * 1000) % 2000).roundToDouble();
  }

  double _calculateTaxes(String? price) {
    if (price == null) return 0.0;
    final basePrice = double.tryParse(price) ?? 0.0;
    return (basePrice * 0.15).roundToDouble(); // 15% taxes
  }

  int _getRandomAvailability() {
    // This should come from your dynamic data
    final hotelId = int.tryParse(hotel.id ?? '0') ?? 0;
    return 2 + (hotelId % 4); // Random number between 2-5
  }

  int _getReviewCount() {
    // This should come from your dynamic data
    final hotelId = int.tryParse(hotel.id ?? '0') ?? 0;
    return 100 + (hotelId % 500); // Random number between 100-600
  }

  void _navigateToHotelDetails(BuildContext context) {
    Navigator.push(
      context,
      ScalePageRoute(
        child: HotelDetailsPage(hotel: hotel),
      ),
    );
  }
}

