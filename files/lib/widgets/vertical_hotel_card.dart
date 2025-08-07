import 'package:flutter/material.dart';
import '../models/hotel.dart';

class VerticalHotelCard extends StatelessWidget {
  final Hotel hotel;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  final bool isFavorite;
  
  const VerticalHotelCard({
    required this.hotel,
    this.onRemove,
    this.onTap,
    this.isFavorite = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    
    return Card(
      margin: EdgeInsets.only(bottom: isTablet ? 4 : 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
      ),
      elevation: isTablet ? 3 : 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: isTablet ? 2.2 / 1 : 2.5 / 1,
                  child: hotel.imageUrl != null && hotel.imageUrl!.isNotEmpty
                      ? Image.network(
                          hotel.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.hotel, size: isTablet ? 80 : 64, color: Colors.grey[400]),
                          ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.hotel, size: isTablet ? 80 : 64, color: Colors.grey[400]),
                        ),
                ),
                // Price badge overlay
                if (hotel.priceRange != null)
                  Positioned(
                    top: isTablet ? 12 : 8,
                    left: isTablet ? 12 : 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 12 : 8,
                        vertical: isTablet ? 6 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        hotel.priceRange!,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 16 : 14,
                        ),
                      ),
                    ),
                  ),
                if (onRemove != null)
                  Positioned(
                    top: isTablet ? 12 : 8,
                    right: isTablet ? 12 : 8,
                    child: Material(
                      color: Colors.white.withOpacity(0.9),
                      shape: CircleBorder(),
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                          size: isTablet ? 24 : 20,
                        ),
                        onPressed: onRemove,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(isTablet ? 12 : 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 28 : 22,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isTablet ? 6 : 4),
                  // Location with country and city
                  Row(
                    children: [
                      Icon(Icons.location_on, size: isTablet ? 20 : 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hotel.country != null)
                              Text(
                                hotel.country!,
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (hotel.city != null)
                              Text(
                                hotel.city!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: isTablet ? 14 : 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (hotel.country == null && hotel.city == null)
                              Text(
                                hotel.location ?? 'Location',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: isTablet ? 16 : 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isTablet ? 8 : 6),
                  Row(
                    children: [
                      Icon(Icons.star, color: Color(0xFFFFC107), size: isTablet ? 22 : 18),
                      SizedBox(width: 4),
                      Text(
                        hotel.rate?.toStringAsFixed(1) ?? '-',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 20 : 16,
                        ),
                      ),
                      if (hotel.reviews != null && hotel.reviews!.isNotEmpty) ...[
                        SizedBox(width: 4),
                        Text(
                          '(${hotel.reviews!.length})',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: isTablet ? 16 : 14,
                          ),
                        ),
                      ],
                      Spacer(),
                      if (hotel.priceRange != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 12 : 8,
                            vertical: isTablet ? 6 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Text(
                            'From ${hotel.priceRange}',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet ? 16 : 14,
                            ),
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
  }
} 