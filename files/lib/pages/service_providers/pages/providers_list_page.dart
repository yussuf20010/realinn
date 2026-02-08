import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../models/service_provider.dart';
import '../../../services/service_provider_service.dart';
import '../../../models/pagination.dart';
import '../../../models/providers_by_category_response.dart';
import '../../../config/constants/app_colors.dart';
import 'provider_details_page.dart';
import '../../../config/components/network_image.dart';
import '../../../config/constants/local_provider_images.dart';

class ProvidersListPage extends StatefulWidget {
  final int categoryId;
  final String? categoryName;

  const ProvidersListPage({
    Key? key,
    required this.categoryId,
    this.categoryName,
  }) : super(key: key);

  @override
  State<ProvidersListPage> createState() => _ProvidersListPageState();
}

class _ProvidersListPageState extends State<ProvidersListPage> {
  List<ServiceProvider> _providers = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _sortKey = 'Best match';
  PaginationInfo? _pagination;
  bool _isLoadingMore = false;
  late final ScrollController _scrollController;
  bool _filterVerifiedOnly = false;
  bool _filterAvailableOnly = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ProvidersByCategoryResponse res =
          await ServiceProviderService.fetchProvidersByCategoryPaged(
        categoryId: widget.categoryId,
        page: 1,
        perPage: 12,
      );
      setState(() {
        _providers = res.providers;
        _pagination = res.pagination;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    if (_pagination == null) return;
    if (!_pagination!.hasMorePages) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _pagination!.currentPage + 1;
      final ProvidersByCategoryResponse res =
          await ServiceProviderService.fetchProvidersByCategoryPaged(
        categoryId: widget.categoryId,
        page: nextPage,
        perPage: _pagination!.perPage,
      );
      setState(() {
        _providers.addAll(res.providers);
        _pagination = res.pagination;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      // keep previous data; optionally show a snackbar
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.categoryName ?? 'service_providers'.tr(),
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
          ? _buildLoadingList(isTablet)
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'provider.error_loading_providers'.tr(),
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
                        onPressed: _loadProviders,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary(context),
                          foregroundColor: Colors.white,
                        ),
                        child: Text('retry'.tr()),
                      ),
                    ],
                  ),
                )
              : _providers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_outline,
                              size: 64, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text(
                            'provider.no_providers'.tr(),
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'provider.no_providers_in_category'.tr(),
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadProviders,
                      color: AppColors.primary(context),
                      child: ListView(
                        controller: _scrollController,
                        padding: EdgeInsets.only(
                          left: isTablet ? 20.w : 16.w,
                          right: isTablet ? 20.w : 16.w,
                          top: isTablet ? 20.h : 16.h,
                          bottom: isTablet ? 20.h : 16.h,
                        ),
                        children: [
                          // Removed search and filter controls for details page
                          _buildResultsMeta(),
                          SizedBox(height: 12.h),
                          _buildAvatarGrid(
                              _buildSortedAndFiltered(_providers), isTablet),
                          if (_pagination != null && _pagination!.hasMorePages)
                            Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: ElevatedButton(
                                onPressed: _isLoadingMore ? null : _loadMore,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary(context),
                                  foregroundColor: Colors.white,
                                ),
                                child: _isLoadingMore
                                    ? SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text('provider.load_more'.tr()),
                              ),
                            ),
                          if (_isLoadingMore)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              child: Center(
                                child: SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary(context),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
    );
  }

  List<ServiceProvider> _buildSortedAndFiltered(List<ServiceProvider> list) {
    var result = list;
    if (_filterVerifiedOnly) {
      result = result.where((p) => p.isVerified).toList();
    }
    if (_filterAvailableOnly) {
      result = result.where((p) => p.availableForWork).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((p) {
        final inName = p.name.toLowerCase().contains(q);
        final inTag = (p.tagline ?? '').toLowerCase().contains(q);
        final inCat = (p.mainCategory?.name ?? '').toLowerCase().contains(q);
        return inName || inTag || inCat;
      }).toList();
    }

    switch (_sortKey) {
      case 'Top rated':
        result.sort((a, b) => (b.rating).compareTo(a.rating));
        break;
      case 'Most orders':
        result.sort((a, b) => (b.completedOrders).compareTo(a.completedOrders));
        break;
      case 'Lowest price':
        result.sort((a, b) => (a.minPrice).compareTo(b.minPrice));
        break;
      case 'Highest price':
        result.sort((a, b) => (b.maxPrice).compareTo(a.maxPrice));
        break;
      default:
        break;
    }
    return result;
  }

  Widget _buildResultsMeta() {
    final total = _pagination?.total ?? _providers.length;
    final current = _providers.length;
    return Row(
      children: [
        Icon(Icons.people_alt_rounded, size: 18, color: Colors.grey.shade700),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            'provider.results_meta'.tr(namedArgs: {
              'current': '$current',
              'total': '$total',
              'page': _pagination?.currentPage.toString() ?? '1',
              'last': _pagination?.lastPage.toString() ?? '1',
            }),
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingList(bool isTablet) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20.w : 16.w,
        vertical: isTablet ? 20.h : 16.h,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(isTablet ? 20.w : 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: isTablet ? 90.w : 75.w,
                height: isTablet ? 90.w : 75.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: isTablet ? 22.h : 18.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      height: isTablet ? 14.h : 12.h,
                      width: MediaQuery.of(context).size.width * 0.5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 28.h,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                  color: Colors.grey.shade200, width: 1),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Container(
                            height: 28.h,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                  color: Colors.grey.shade200, width: 1),
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
      },
    );
  }

  Widget _buildAvatarGrid(List<ServiceProvider> providers, bool isTablet) {
    if (providers.isEmpty) {
      return SizedBox.shrink();
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: isTablet ? 24.w : 16.w,
        mainAxisSpacing: isTablet ? 32.h : 24.h,
        childAspectRatio: 0.75, // Adjusted for text below avatars
      ),
      itemCount: providers.length,
      itemBuilder: (context, index) {
        return _buildAvatarItem(providers[index], index, isTablet);
      },
    );
  }

  Widget _buildAvatarItem(ServiceProvider provider, int index, bool isTablet) {
    // Calculate a percentage based on response rate or completion rate
    final percentage = provider.responseRate > 0
        ? provider.responseRate.toInt()
        : (provider.completedOrders > 0
            ? (provider.completedOrders * 2).clamp(0, 100)
            : 0);

    // Get avatar color based on provider index or name
    final avatarColor = _getAvatarColor(provider.id.hashCode, context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProviderDetailsPage(
              providerId: int.parse(provider.id),
              categoryId: widget.categoryId,
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Use provider image if available, otherwise use colored circle with icon
          Container(
            width: isTablet ? 100.w : 80.w,
            height: isTablet ? 100.w : 80.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avatarColor,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              LocalProviderImages.getImagePath(index),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.person,
                  size: isTablet ? 50 : 40,
                  color: Colors.white,
                );
              },
            ),
          ),
          SizedBox(height: 8.h),
          // Provider name
          Text(
            provider.name,
            style: TextStyle(
              fontSize: isTablet ? 12.sp : 11.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          // Percentage
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: isTablet ? 11.sp : 10.sp,
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
    return colors[index.abs() % colors.length];
  }

  Widget _buildProviderCard(ServiceProvider provider, bool isTablet) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProviderDetailsPage(
                providerId: int.parse(provider.id),
                categoryId: widget.categoryId,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 20.w : 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image with border and shadow
                  Hero(
                    tag: 'provider-image-${provider.id}',
                    child: Container(
                      width: isTablet ? 90.w : 75.w,
                      height: isTablet ? 90.w : 75.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                        color: Colors.grey.shade100,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        LocalProviderImages.getImagePath(int.tryParse(provider.id) ?? 0),
                        fit: BoxFit.cover,
                        width: isTablet ? 90.w : 75.w,
                        height: isTablet ? 90.w : 75.w,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.person,
                              size: 40, color: Colors.grey.shade400);
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  // Provider Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          provider.name,
                          style: TextStyle(
                            fontSize: isTablet ? 22.sp : 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        // Badges as wrap to avoid overlap
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 6.h,
                          children: [
                            if (provider.availableForWork)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.work_outline_rounded,
                                      color: Colors.green,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'provider.available'.tr(),
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (provider.isVerified)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      color: Colors.blue,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'provider.verified'.tr(),
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        if (provider.tagline != null &&
                            provider.tagline!.isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          Text(
                            provider.tagline!,
                            style: TextStyle(
                              fontSize: isTablet ? 14.sp : 13.sp,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        SizedBox(height: 12.h),
                        // Rating and Stats
                        Wrap(
                          spacing: 12.w,
                          runSpacing: 8.h,
                          children: [
                            if (provider.rating > 0) ...[
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star_rounded,
                                        color: Colors.amber.shade700, size: 16),
                                    SizedBox(width: 4.w),
                                    Text(
                                      provider.rating.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: isTablet ? 13.sp : 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.amber.shade900,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      '(${provider.reviewCount})',
                                      style: TextStyle(
                                        fontSize: isTablet ? 12.sp : 11.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (provider.responseRate > 0) ...[
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.reply_rounded,
                                        color: Colors.blue.shade700, size: 16),
                                    SizedBox(width: 4.w),
                                    Text(
                                      '${provider.responseRate.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: isTablet ? 13.sp : 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'provider.response'.tr(),
                                      style: TextStyle(
                                        fontSize: isTablet ? 12.sp : 11.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (provider.onTimeDeliveryRate > 0) ...[
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade50,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.schedule_rounded,
                                        color: Colors.teal.shade700, size: 16),
                                    SizedBox(width: 4.w),
                                    Text(
                                      '${provider.onTimeDeliveryRate.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: isTablet ? 13.sp : 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.teal.shade900,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'provider.on_time'.tr(),
                                      style: TextStyle(
                                        fontSize: isTablet ? 12.sp : 11.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                      color: Colors.green.shade700, size: 16),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${provider.completedOrders}',
                                    style: TextStyle(
                                      fontSize: isTablet ? 13.sp : 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (provider.mainCategory != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary(context)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: AppColors.primary(context)
                                        .withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.category_rounded,
                                        size: 16,
                                        color: AppColors.primary(context)),
                                    SizedBox(width: 6.w),
                                    Text(
                                      provider.mainCategory!.name,
                                      style: TextStyle(
                                        fontSize: isTablet ? 12.sp : 11.sp,
                                        color: AppColors.primary(context),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        // Price and Location
                        Row(
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary(context)
                                          .withOpacity(0.1),
                                      AppColors.primary(context)
                                          .withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: AppColors.primary(context)
                                        .withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      provider.currency,
                                      style: TextStyle(
                                        fontSize: isTablet ? 13.sp : 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary(context),
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Flexible(
                                      child: Text(
                                        '${provider.minPrice}${provider.maxPrice > provider.minPrice ? ' - ${provider.maxPrice}' : ''}',
                                        style: TextStyle(
                                          fontSize: isTablet ? 15.sp : 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary(context),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (provider.city != null ||
                                provider.country != null) ...[
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.location_on_rounded,
                                          color: Colors.grey.shade600,
                                          size: 16),
                                      SizedBox(width: 6.w),
                                      Flexible(
                                        child: Text(
                                          '${provider.city ?? ''}${provider.city != null && provider.country != null ? ', ' : ''}${provider.country ?? ''}',
                                          style: TextStyle(
                                            fontSize: isTablet ? 13.sp : 12.sp,
                                            color: Colors.grey.shade700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              // View Details Button - Full width with gradient
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary(context),
                      AppColors.primary(context).withOpacity(0.8),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary(context).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProviderDetailsPage(
                            providerId: int.parse(provider.id),
                            categoryId: widget.categoryId,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: isTablet ? 14.h : 12.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'provider.view_details'.tr(),
                            style: TextStyle(
                              fontSize: isTablet ? 15.sp : 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
