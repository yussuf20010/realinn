import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../models/country.dart';
import '../../../services/country_service.dart';

class CountrySelectorWidget extends StatefulWidget {
  final String? selectedDialCode;
  final Function(Country) onCountrySelected;
  final bool showSearch;
  final bool showFlags;
  final bool showDialCodes;

  const CountrySelectorWidget({
    Key? key,
    this.selectedDialCode,
    required this.onCountrySelected,
    this.showSearch = true,
    this.showFlags = true,
    this.showDialCodes = true,
  }) : super(key: key);

  @override
  State<CountrySelectorWidget> createState() => _CountrySelectorWidgetState();
}

class _CountrySelectorWidgetState extends State<CountrySelectorWidget> {
  List<Country> _allCountries = [];
  List<Country> _filteredCountries = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCountries();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    setState(() => _isLoading = true);
    try {
      final countries = await CountryService.fetchAllCountries();
      if (mounted) {
        setState(() {
          _allCountries = countries;
          _filteredCountries = countries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load countries: $e')),
        );
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = _allCountries;
      } else {
        _filteredCountries = _allCountries.where((country) {
          return country.name.toLowerCase().contains(query) ||
              country.dialCode.contains(query) ||
              country.code.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('loading_countries'.tr()),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (widget.showSearch) ...[
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'search_countries'.tr(),
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
        ],
        Expanded(
          child: _filteredCountries.isEmpty
              ? Center(
                  child: Text(
                    'no_countries_found'.tr(),
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredCountries.length,
                  itemBuilder: (context, index) {
                    final country = _filteredCountries[index];
                    final isSelected =
                        country.dialCode == widget.selectedDialCode;

                    return ListTile(
                      leading: widget.showFlags
                          ? Container(
                              width: 40.w,
                              height: 30.h,
                              alignment: Alignment.center,
                              child: Text(
                                country.flag,
                                style: TextStyle(fontSize: 24.sp),
                              ),
                            )
                          : Icon(Icons.flag),
                      title: Text(
                        country.name,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: widget.showDialCodes
                          ? Text(
                              '${country.code.toUpperCase()} ${country.dialCode}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            )
                          : null,
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      onTap: () => widget.onCountrySelected(country),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Modal dialog version for easy use in forms
class CountrySelectorModal extends StatefulWidget {
  final String? selectedDialCode;
  final Function(Country) onCountrySelected;

  const CountrySelectorModal({
    Key? key,
    this.selectedDialCode,
    required this.onCountrySelected,
  }) : super(key: key);

  @override
  State<CountrySelectorModal> createState() => _CountrySelectorModalState();

  static void show(
    BuildContext context, {
    String? selectedDialCode,
    required Function(Country) onCountrySelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CountrySelectorModal(
        selectedDialCode: selectedDialCode,
        onCountrySelected: onCountrySelected,
      ),
    );
  }
}

class _CountrySelectorModalState extends State<CountrySelectorModal> {
  List<Country> _allCountries = [];
  List<Country> _filteredCountries = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCountries();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    setState(() => _isLoading = true);
    try {
      final countries = await CountryService.fetchAllCountries();
      if (mounted) {
        setState(() {
          _allCountries = countries;
          _filteredCountries = countries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = _allCountries;
      } else {
        _filteredCountries = _allCountries.where((country) {
          return country.name.toLowerCase().contains(query) ||
              country.dialCode.contains(query) ||
              country.code.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'select_country'.tr(),
                        style: TextStyle(
                          fontSize: isTablet ? 26.sp : 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20.r),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 20.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(fontSize: isTablet ? 16.sp : 14.sp),
                    decoration: InputDecoration(
                      hintText: 'search_country'.tr(),
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: isTablet ? 16.sp : 14.sp,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[600],
                        size: 24.sp,
                      ),
                      suffixIcon: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _searchController,
                        builder: (context, value, child) {
                          return value.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear,
                                      color: Colors.grey[600]),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : SizedBox.shrink();
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                    ),
                  ),
                ),
              ),
              // Countries List
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16.h),
                            Text(
                              'loading_countries'.tr(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: isTablet ? 16.sp : 14.sp,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _filteredCountries.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'no_countries_found'.tr(),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: isTablet ? 18.sp : 16.sp,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 8.h,
                            ),
                            itemCount: _filteredCountries.length,
                            itemBuilder: (context, index) {
                              final country = _filteredCountries[index];
                              final isSelected =
                                  country.dialCode == widget.selectedDialCode;

                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    widget.onCountrySelected(country);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.w,
                                      vertical: 14.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.blue[50]
                                          : Colors.transparent,
                                    ),
                                    child: Row(
                                      children: [
                                        // Flag
                                        Container(
                                          width: isTablet ? 48.w : 44.w,
                                          height: isTablet ? 36.h : 32.h,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                          ),
                                          child: Text(
                                            country.flag,
                                            style: TextStyle(
                                              fontSize:
                                                  isTablet ? 32.sp : 28.sp,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16.w),
                                        // Country Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                country.name,
                                                style: TextStyle(
                                                  fontSize:
                                                      isTablet ? 18.sp : 16.sp,
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
                                                  color: isSelected
                                                      ? Colors.blue[900]
                                                      : Colors.black87,
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                '${country.code.toUpperCase()} • ${country.dialCode}',
                                                style: TextStyle(
                                                  fontSize:
                                                      isTablet ? 14.sp : 12.sp,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Check Icon
                                        if (isSelected)
                                          Container(
                                            padding: EdgeInsets.all(6.w),
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: isTablet ? 20.sp : 18.sp,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
