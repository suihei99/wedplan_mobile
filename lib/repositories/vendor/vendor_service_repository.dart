import 'package:wedplan_mobile/core/network/api_service.dart';
import 'package:wedplan_mobile/models/vendor/vendor_service.dart';

class VendorServiceRepository {
  VendorServiceRepository._({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  static final VendorServiceRepository instance = VendorServiceRepository._();

  final ApiService _apiService;

  Future<List<VendorService>> fetchServices() async {
    final response = await _apiService.vendorServices();
    return _parseServices(response.data);
  }

  Future<VendorService?> showService(Object id) async {
    final response = await _apiService.vendorServiceShow(id);
    final map = _toMap(response.data);
    if (map.isEmpty) return null;
    return VendorService.fromJson(map);
  }

  List<VendorService> _parseServices(dynamic data) {
    final map = _toMap(data);
    final list = _readList(map, const ['data', 'services']);

    return list
        .whereType<Map>()
        .map((item) => VendorService.fromJson(item.cast<String, dynamic>()))
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

  List<dynamic> _readList(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is List) return value;
    }
    return const <dynamic>[];
  }
}
