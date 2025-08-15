import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../config/image_cache_config.dart';
import '../../config/wp_config.dart';
import '../../controllers/hotel_controller.dart';
import '../../models/hotel.dart';
import '../../widgets/custom_app_bar.dart';
import '../../core/utils/app_utils.dart';
import '../booking/book_now_page.dart';
import '../favorites/favorites_page.dart';
import '../booking/book_now_page.dart' as booking;


class AllHotelsPage extends ConsumerStatefulWidget {
  const AllHotelsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AllHotelsPage> createState() => _AllHotelsPageState();
}

class _AllHotelsPageState extends ConsumerState<AllHotelsPage> {
  List<String> selectedAmenities = [];

  final List<_Amenity> amenities = [
    _Amenity('amenity_free_wifi'.tr(), Icons.wifi),
    _Amenity('amenity_fitness_center'.tr(), Icons.fitness_center),
    _Amenity('amenity_free_breakfast'.tr(), Icons.free_breakfast),
    _Amenity('amenity_kid_friendly'.tr(), Icons.child_friendly),
    _Amenity('amenity_free_parking'.tr(), Icons.local_parking),
    _Amenity('amenity_pet_friendly'.tr(), Icons.pets),
    _Amenity('amenity_air_conditioned'.tr(), Icons.ac_unit),
    _Amenity('amenity_pool'.tr(), Icons.pool),
    _Amenity('amenity_bar'.tr(), Icons.local_bar),
    _Amenity('amenity_restaurant'.tr(), Icons.restaurant),
  ];

  @override
  void initState() {
    super.initState();
    _preloadImages();
  }

  Future<void> _preloadImages() async {
    final hotels = ref.read(hotelProvider).value;
    if (hotels != null) {
      for (final hotel in hotels) {
        if (hotel.images?.isNotEmpty == true) {
          await ImageCacheConfig.preloadImage(hotel.images!.first);
        } else if (hotel.imageUrl != null && hotel.imageUrl!.isNotEmpty) {
          await ImageCacheConfig.preloadImage(hotel.imageUrl!);
        }
      }
    }
  }

  String _getImageUrl(Hotel hotel) {
    if (hotel.images?.isNotEmpty == true) {
      return hotel.images!.first;
    }
    return hotel.imageUrl ?? '';
  }

  void _showAmenitiesDrawer() async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        List<String> tempSelected = List.from(selectedAmenities);
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: StatefulBuilder(
            builder: (context, setState) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text('amenities'.tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 2.8,
                    physics: NeverScrollableScrollPhysics(),
                    children: amenities.map((amenity) {
                      final selected = tempSelected.contains(amenity.label);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selected) {
                              tempSelected.remove(amenity.label);
                            } else {
                              tempSelected.add(amenity.label);
                            }
                          });
                        }, 
                        child: Container(
                          decoration: BoxDecoration(
                            color: selected ? WPConfig.primaryColor : Colors.white,
                            border: Border.all(color: WPConfig.primaryColor, width: 1.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                amenity.icon, 
                                color: selected ? Colors.white : WPConfig.primaryColor,
                              ),
                              SizedBox(width: 8),
                              Text(
                                amenity.label,
                                style: TextStyle(
                                  color: selected ? Colors.white : WPConfig.primaryColor, 
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() => tempSelected.clear());
                          },
                           child: Text('clear'.tr(), style: TextStyle(color: WPConfig.primaryColor, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: WPConfig.primaryColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, tempSelected);
                          },
                           child: Text('apply'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WPConfig.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (result != null) {
      setState(() => selectedAmenities = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hotelsAsync = ref.watch(hotelProvider);
    return Scaffold(
      appBar: CustomAppBar(
        title: 'hotels'.tr(),
        showBackButton: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _showAmenitiesDrawer,
                  icon: Icon(Icons.filter_list, color: WPConfig.primaryColor),
                  label: Text('amenities'.tr(), style: TextStyle(color: WPConfig.primaryColor, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    side: BorderSide(color: WPConfig.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                // Add more filter buttons if needed
              ],
            ),
          ),
          Expanded(
            child: hotelsAsync.when(
              data: (hotels) => ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: hotels.length,
                itemBuilder: (context, index) {
                  final hotel = hotels[index];
                  final imageUrl = _getImageUrl(hotel);
                  return Container(
                    margin: EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image with favorite button overlay
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                              child: ImageCacheConfig.buildCachedImage(
                                imageUrl: imageUrl,
                                height: 90,
                                width: 90,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                              ),
                            ),
                            // Favorite button
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Consumer(
                                builder: (context, ref, child) {
                                  final favoritesNotifier = ref.watch(favoritesProvider.notifier);
                                  final isFavorite = favoritesNotifier.isFavorite(hotel);
                                  
                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () async {
                                        if (isFavorite) {
                                          favoritesNotifier.removeHotel(hotel);
                                          // Small delay to ensure widget is still mounted
                                          await Future.delayed(Duration(milliseconds: 100));
                                          if (context.mounted) {
                                            AppUtil.showSafeSnackBar(
                                              context,
                                              message: 'Removed from favorites',
                                              actionLabel: 'View Favorites',
                                              onActionPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (_) => FavoritesPage()),
                                                );
                                              },
                                            );
                                          }
                                        } else {
                                          favoritesNotifier.addHotel(hotel);
                                          // Small delay to ensure widget is still mounted
                                          await Future.delayed(Duration(milliseconds: 100));
                                          if (context.mounted) {
                                            AppUtil.showSafeSnackBar(
                                              context,
                                              message: 'Added to favorites!',
                                              actionLabel: 'View Favorites',
                                              onActionPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (_) => FavoritesPage()),
                                                );
                                              },
                                            );
                                          }
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          isFavorite ? Icons.favorite : Icons.favorite_border,
                                          color: isFavorite ? Colors.red : WPConfig.navbarColor,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        hotel.name ?? '',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
                                    SizedBox(width: 2),
                                    Text(
                                      hotel.rate?.toStringAsFixed(1) ?? '',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'reviews'.tr() + ' (${hotel.reviews?.length ?? 0})',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 3),
                                Text(
                                  hotel.description ?? '',
                                  style: TextStyle(fontSize: 13, color: Colors.black87),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      hotel.priceRange != null ? hotel.priceRange! : '',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Spacer(),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => booking.BookNowPage(
                                              hotel: hotel,
                                              bookingType: 0,
                                            ),
                                          ),
                                        );
                                      }, 
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: WPConfig.primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                        minimumSize: Size(0, 32),
                                      ),
                                      child: Text('book_now'.tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              loading: () => ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: 5,
                itemBuilder: (context, index) => _ShimmerHotelCard(),
              ),
              error: (e, _) => Center(child: Text('error_loading_hotels'.tr())),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerHotelCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ImageCacheConfig.buildShimmerPlaceholder(
            width: double.infinity,
            height: 200,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 24,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 16,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    for (int i = 0; i < 3; i++)
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            height: 24,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
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
    );
  }
}

class _Amenity {
  final String label;
  final IconData icon;
  _Amenity(this.label, this.icon);
}


