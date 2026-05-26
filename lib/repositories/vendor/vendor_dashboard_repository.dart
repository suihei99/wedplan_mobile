import 'package:wedplan_mobile/core/network/api_service.dart';

class VendorDashboardRepository {
  VendorDashboardRepository._({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  static final VendorDashboardRepository instance =
      VendorDashboardRepository._();

  final ApiService _apiService;

  Future<Map<String, dynamic>> loadDashboard({
    bool forceRefresh = false,
  }) async {
    final response = await _apiService.vendorDashboard();
    return _unwrap(_toMap(response.data));
  }

  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map<String, dynamic>(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    return <String, dynamic>{'data': data};
  }

  Map<String, dynamic> _unwrap(Map<String, dynamic> source) {
    final data = source['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map<String, dynamic>(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    return source;
  }
}
