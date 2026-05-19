import 'package:wedplan_mobile/core/network/api_service.dart';
import 'package:wedplan_mobile/core/services/app_session_cache.dart';

class CoupleRepository {
  CoupleRepository._({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  static final CoupleRepository instance = CoupleRepository._();

  final ApiService _apiService;
  final AppSessionCache _cache = AppSessionCache.instance;

  Future<Map<String, dynamic>> dashboard({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache.dashboard != null) {
      return _cache.dashboard!;
    }

    final response = await _apiService.coupleDashboard();
    final dashboard = _toMap(response.data);
    _cache.dashboard = dashboard;
    return dashboard;
  }

  Future<Map<String, dynamic>> coupleDetail({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache.coupleDetail != null) {
      return _cache.coupleDetail!;
    }

    final response = await _apiService.settings();
    final normalized = _toMap(response.data);

    // Possible shapes:
    // 1. { data: { ... } } where data may contain 'couple' or direct profile
    // 2. { user: { couple: { ... } } }
    // 3. top-level { couple: { ... } }
    Map<String, dynamic> couple = <String, dynamic>{};

    final data = normalized['data'] is Map<String, dynamic>
        ? normalized['data'] as Map<String, dynamic>
        : normalized;

    if (data['couple'] is Map) {
      couple = _toMap(data['couple']);
    } else if (data['user'] is Map && (data['user']['couple'] is Map)) {
      couple = _toMap(data['user']['couple']);
    } else if (normalized['user'] is Map &&
        (normalized['user']['couple'] is Map)) {
      couple = _toMap(normalized['user']['couple']);
    } else if (normalized['couple'] is Map) {
      couple = _toMap(normalized['couple']);
    } else {
      // fallback: maybe the data itself is the profile (contains partner names)
      final maybe = _toMap(data);
      if (maybe.containsKey('partner_1_name') ||
          maybe.containsKey('partner1_name') ||
          maybe.containsKey('display_name')) {
        couple = maybe;
      } else {
        // last resort: use normalized (settings) as-is
        couple = _toMap(normalized['data'] ?? normalized);
      }
    }

    _cache.coupleDetail = couple;
    return couple;
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

  Map<String, dynamic> _unwrapData(dynamic data) {
    final normalized = _toMap(data);
    final nested = normalized['data'];
    if (nested is Map<String, dynamic>) return nested;
    if (nested is Map) {
      return nested.map<String, dynamic>(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    return normalized;
  }
}
