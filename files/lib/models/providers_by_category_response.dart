import 'service_provider.dart';
import 'pagination.dart';

class ProvidersByCategoryResponse {
  final List<ServiceProvider> providers;
  final PaginationInfo? pagination;

  const ProvidersByCategoryResponse({
    required this.providers,
    this.pagination,
  });
}
