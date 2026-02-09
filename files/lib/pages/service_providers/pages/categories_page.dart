import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/service_provider_category.dart';
import '../../../services/service_provider_service.dart';
import '../../../config/wp_config.dart';
import '../../../config/constants/app_colors.dart';
import 'providers_list_page.dart';
import '../../../config/constants/local_provider_images.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<ServiceProviderCategory> _categories = [];
  bool _isLoading = true;
  String? _error;
  String _search = '';
  final Set<String> _selectedNames = <String>{};

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final categories = await ServiceProviderService.fetchCategories();
      categories
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Service Categories',
          style: TextStyle(
            fontSize: isTablet ? 24.sp : 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary(context),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator(color: AppColors.primary(context)),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'Error loading categories',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadCategories,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary(context),
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _categories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.category_outlined,
                              size: 64, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text(
                            'No categories available',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadCategories,
                      color: AppColors.primary(context),
                      child: ListView(
                        padding: EdgeInsets.all(isTablet ? 20.w : 16.w),
                        children: [
                          _buildCategorySearchAndFilters(isTablet),
                          SizedBox(height: 12.h),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                               SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isTablet ? 4 : 3,
                              crossAxisSpacing: isTablet ? 24.w : 16.w,
                              mainAxisSpacing: isTablet ? 28.h : 20.h,
                              childAspectRatio: 0.65, // Increased height even more to be safe
                            ),
                            itemCount: _filteredCategories().length,
                            itemBuilder: (context, index) {
                              final category = _filteredCategories()[index];
                              return _buildCategoryAvatar(
                                  category, index, isTablet);
                            },
                          ),
                        ],
                      ),
                    ),
    );
  }

  List<ServiceProviderCategory> _filteredCategories() {
    var list = _categories;
    if (_search.trim().isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((c) => c.name.toLowerCase().contains(q)).toList();
    }
    if (_selectedNames.isNotEmpty) {
      // Create a copy of the Set to avoid concurrent modification issues
      final selectedNamesCopy = Set<String>.from(_selectedNames);
      list = list.where((c) => selectedNamesCopy.contains(c.name)).toList();
    }
    return list;
  }

  Widget _buildCategorySearchAndFilters(bool isTablet) {
    final names = _categories.map((c) => c.name).toList();
    names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final topNames = names.take(14).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search categories...',
              prefixIcon: Icon(Icons.search_rounded),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: isTablet ? 16.h : 14.h,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryAvatar(
      ServiceProviderCategory category, int index, bool isTablet) {
    // Calculate percentage based on index (for demo, you can use actual data)
    final percentage = ((index + 1) * 15) % 100;
    final avatarColor = _getAvatarColor(index, context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProvidersListPage(
              categoryId: category.id,
              categoryName: category.name,
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Use category image if available, otherwise use icon, fallback to colored circle
          Container(
            width: isTablet ? 100.w : 80.w,
            height: isTablet ? 100.w : 80.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avatarColor,
            ),
            clipBehavior: Clip.antiAlias,
            child: category.image != null && category.image!.isNotEmpty
                ? Image.network(
                    category.image!.startsWith('http')
                        ? category.image!
                        : '${WPConfig.imageBaseUrl}${category.image}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // print warning to debug
                      print('Image failed to load: ${category.image}');
                      return Image.network(
                        '${WPConfig.imageBaseUrl}service-provider-categories/${category.image}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error2, stackTrace2) {
                             print('Image failed to load (fallback): ${WPConfig.imageBaseUrl}service-provider-categories/${category.image}');
                             return Icon(
                                Icons.category,
                                size: isTablet ? 50 : 40,
                                color: Colors.white,
                              );
                        },
                      );
                    },
                  )
                : Icon(
                    Icons.category,
                    size: isTablet ? 50 : 40,
                    color: Colors.white,
                  ),
          ),
          SizedBox(height: 6.h),
          // Category name
          Flexible(
            child: Text(
              category.name,
              style: TextStyle(
                fontSize: isTablet ? 11.sp : 10.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 2.h),
          // Percentage
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: isTablet ? 10.sp : 9.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getAvatarColor(int index, BuildContext context) {
    final primaryColor = AppColors.primary(context);
    // Generate colors based on primary color with variations
    final colors = [
      primaryColor,
      primaryColor.withOpacity(0.8),
      primaryColor.withOpacity(0.6),
      primaryColor.withOpacity(0.9),
      primaryColor.withOpacity(0.7),
      primaryColor.withOpacity(0.85),
      primaryColor.withOpacity(0.75),
      primaryColor.withOpacity(0.65),
      primaryColor.withOpacity(0.95),
      primaryColor.withOpacity(0.55),
    ];
    return colors[index % colors.length];
  }
}
