import 'package:wedplan_mobile/core/network/api_service.dart';

class VendorBookingRepository {
  VendorBookingRepository._({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  static final VendorBookingRepository instance = VendorBookingRepository._();

  final ApiService _apiService;

  Future<List<Map<String, dynamic>>> fetchBookings({
    bool forceRefresh = false,
  }) async {
    final response = await _apiService.vendorBookings();
    return _parseItems(response.data);
  }

  List<Map<String, dynamic>> _parseItems(dynamic data) {
    final map = _toMap(data);
    final normalized = _unwrap(map);
    final list = _readList(normalized, const ['data', 'bookings', 'orders']);
    return list
        .whereType<Map>()
        .map(
          (item) => item.map<String, dynamic>(
            (key, value) => MapEntry(key.toString(), value),
          ),
        )
        .toList();
  }

  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map<String, dynamic>(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    if (data is List) {
      return <String, dynamic>{'data': data};
    }
    return <String, dynamic>{};
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

  List<dynamic> _readList(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is List) return value;
    }
    return const <dynamic>[];
  }
}
