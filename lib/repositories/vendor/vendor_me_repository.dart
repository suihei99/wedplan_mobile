import 'package:wedplan_mobile/core/network/api_service.dart';
import 'package:wedplan_mobile/core/services/auth_service.dart';

class VendorMeRepository {
  VendorMeRepository._({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  static final VendorMeRepository instance = VendorMeRepository._();

  final ApiService _apiService;

  Future<Map<String, dynamic>> loadProfile({bool forceRefresh = false}) async {
    final settingsResponse = await _apiService.settings();
    final dashboardResponse = await _apiService.vendorDashboard();
    return <String, dynamic>{
      'settings': _unwrap(_toMap(settingsResponse.data)),
      'dashboard': _unwrap(_toMap(dashboardResponse.data)),
    };
  }

  Future<Map<String, dynamic>> logout() {
    return AuthService.instance.logout();
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
