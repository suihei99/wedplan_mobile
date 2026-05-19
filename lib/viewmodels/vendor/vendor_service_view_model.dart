import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:wedplan_mobile/models/vendor/vendor_service.dart';
import 'package:wedplan_mobile/repositories/vendor/vendor_service_repository.dart';

class VendorServiceViewModel extends ChangeNotifier {
  VendorServiceViewModel({VendorServiceRepository? repository})
    : _repository = repository ?? VendorServiceRepository.instance;

  final VendorServiceRepository _repository;

  bool _busy = false;
  String? _error;
  String _query = '';
  String _selectedType = 'all';
  List<VendorService> _services = const <VendorService>[];

  bool get busy => _busy;
  String? get error => _error;
  List<VendorService> get allServices => _services;
  String get query => _query;
  String get selectedType => _selectedType;

  List<VendorService> get visibleServices {
    final normalizedQuery = _query.trim().toLowerCase();
    return _services.where((service) {
      final matchesType =
          _selectedType == 'all' ||
          _normalizeType(service.typeService) == _normalizeType(_selectedType);
      if (!matchesType) return false;

      if (normalizedQuery.isEmpty) return true;

      return <String>[
        service.serviceName,
        service.typeService,
        service.description,
      ].any((value) => value.toLowerCase().contains(normalizedQuery));
    }).toList();
  }

  List<String> get serviceTypes {
    final values =
        _services
            .map((service) => service.typeService.trim())
            .where((value) => value.isNotEmpty)
            .map((value) => value.toLowerCase())
            .toSet()
            .toList()
          ..sort();

    return values;
  }

  Future<void> load({bool forceRefresh = false}) async {
    _setBusy(true);
    _error = null;

    try {
      _services = await _repository.fetchServices();
      if (_selectedType != 'all' &&
          !_services.any(
            (service) =>
                _normalizeType(service.typeService) ==
                _normalizeType(_selectedType),
          )) {
        _selectedType = 'all';
      }
      notifyListeners();
    } on DioException catch (error) {
      _error = _extractMessage(error);
      _services = const <VendorService>[];
      notifyListeners();
    } finally {
      _setBusy(false);
    }
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void setTypeFilter(String value) {
    if (_selectedType == value) return;
    _selectedType = value;
    notifyListeners();
  }

  void clearFilters() {
    if (_query.isEmpty && _selectedType == 'all') return;
    _query = '';
    _selectedType = 'all';
    notifyListeners();
  }

  void _setBusy(bool value) {
    if (_busy == value) return;
    _busy = value;
    notifyListeners();
  }

  String _extractMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];
      if (message is String && message.isNotEmpty) return message;
    }
    if (data is Map) {
      final message = data['message'] ?? data['error'];
      if (message is String && message.isNotEmpty) return message;
    }
    return error.message ?? 'Something went wrong.';
  }

  String _normalizeType(String value) {
    final normalized = value.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '_',
    );

    if (normalized.contains('makeup')) return 'makeup_artist';
    if (normalized.contains('planner')) return 'wedding_planner';
    if (normalized.contains('bridal')) return 'bridal_wear';
    if (normalized.contains('decor') || normalized.contains('styling')) {
      return 'decor_styling';
    }

    if (normalized.contains('photo')) return 'photography';
    if (normalized.contains('transport')) return 'transportation';
    if (normalized.contains('entertain')) return 'entertainment';
    if (normalized.contains('cater')) return 'catering';
    if (normalized.contains('venue')) return 'venue';
    if (normalized.contains('other')) return 'other';

    return normalized;
  }
}
