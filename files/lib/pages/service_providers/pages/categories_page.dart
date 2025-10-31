import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/service_provider_category.dart';
import '../../../services/service_provider_service.dart';
import '../../../config/wp_config.dart';
import 'providers_list_page.dart';
import '../utils/category_icons.dart';

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
      categories.sort((a, b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()));
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
        backgroundColor: WPConfig.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: WPConfig.primaryColor),
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
                          backgroundColor: WPConfig.primaryColor,
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
                      color: WPConfig.primaryColor,
                      child: ListView(
                        padding: EdgeInsets.all(isTablet ? 20.w : 16.w),
                        children: [
                          _buildCategorySearchAndFilters(isTablet),
                          SizedBox(height: 12.h),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isTablet ? 4 : 2,
                              crossAxisSpacing: 16.w,
                              mainAxisSpacing: 16.h,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: _filteredCategories().length,
                            itemBuilder: (context, index) {
                              final category = _filteredCategories()[index];
                              return _buildCategoryCard(category, isTablet);
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
      list = list
          .where((c) => c.name.toLowerCase().contains(q))
          .toList();
    }
    if (_selectedNames.isNotEmpty) {
      list = list
          .where((c) => _selectedNames.contains(c.name))
          .toList();
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
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 6.h,
          children: [
            FilterChip(
              label: Text('Has providers'),
              selected: _selectedNames.contains('__HAS__'),
              onSelected: (v) => setState(() {
                if (v) {
                  _selectedNames.add('__HAS__');
                } else {
                  _selectedNames.remove('__HAS__');
                }
              }),
              selectedColor: Colors.green.shade50,
              checkmarkColor: Colors.green,
            ),
            ...topNames.map((n) => FilterChip(
                  label: Text(n),
                  selected: _selectedNames.contains(n),
                  onSelected: (v) => setState(() {
                    if (v) {
                      _selectedNames.add(n);
                    } else {
                      _selectedNames.remove(n);
                    }
                  }),
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard(ServiceProviderCategory category, bool isTablet) {
    final icon = CategoryIcons.getIcon(category.name);
    final color = CategoryIcons.getColor(category.name);

    return InkWell(
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
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 24.w : 20.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: isTablet ? 48.sp : 40.sp,
                color: color,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              category.name,
              style: TextStyle(
                fontSize: isTablet ? 16.sp : 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (category.description != null &&
                category.description!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  category.description!,
                  style: TextStyle(
                    fontSize: isTablet ? 12.sp : 10.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
