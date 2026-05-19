import 'package:wedplan_mobile/core/network/api_service.dart';
import 'package:wedplan_mobile/models/vendor/vendor_service.dart';

class VendorServiceRepository {
  VendorServiceRepository._({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  static final VendorServiceRepository instance = VendorServiceRepository._();

  final ApiService _apiService;

  Future<List<VendorService>> fetchServices({
    String? search,
    String? typeService,
    int perPage = 100,
  }) async {
    final response = await _apiService.coupleVendorServices(
      queryParameters: <String, dynamic>{
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (typeService != null &&
            typeService.trim().isNotEmpty &&
            typeService.trim().toLowerCase() != 'all')
          'type_service': typeService.trim(),
        'per_page': perPage,
      },
    );
    return _parseServices(response.data);
  }

  Future<VendorService?> showService(Object id) async {
    final response = await _apiService.coupleVendorServiceShow(id);
    final map = _toMap(response.data);
    if (map.isEmpty) return null;
    return VendorService.fromJson(map);
  }

  List<VendorService> _parseServices(dynamic data) {
    final map = _toMap(data);

    // Try to read common list wrappers: top-level 'data' or 'services'.
    var list = _readList(map, const ['data', 'services']);

    // Some APIs wrap the response as { data: { current_page: ..., data: [ ... ] } }
    // In that case, the first 'data' is a Map which itself contains the real list
    // under its 'data' key. Detect and unwrap that structure.
    if (list.isEmpty) {
      final inner = map['data'];
      if (inner is Map) {
        final innerMap = _toMap(inner);
        list = _readList(innerMap, const ['data', 'services']);
      }
    }

    final items = list;

    return items
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
