import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:wedplan_mobile/models/vendor/vendor_service.dart';
import 'package:wedplan_mobile/models/vendor/vendor_service_draft.dart';
import 'package:wedplan_mobile/repositories/vendor/vendor_service_management_repository.dart';

class VendorServiceManagementViewModel extends ChangeNotifier {
  VendorServiceManagementViewModel({
    VendorServiceManagementRepository? repository,
  }) : _repository = repository ?? VendorServiceManagementRepository.instance;

  final VendorServiceManagementRepository _repository;

  bool _busy = false;
  String? _error;
  String _query = '';
  String _selectedType = 'all';
  List<VendorService> _services = const <VendorService>[];

  bool get busy => _busy;
  String? get error => _error;
  String get query => _query;
  String get selectedType => _selectedType;
  List<VendorService> get allServices => _services;

  List<String> get serviceTypes {
    final values =
        _services
            .map((service) => service.typeService.trim())
            .where((value) => value.isNotEmpty)
            .map(_normalizeType)
            .toSet()
            .toList()
          ..sort();

    return values;
  }

  List<VendorService> get visibleServices {
    final normalized = _query.trim().toLowerCase();
    return _services.where((service) {
      final matchesType =
          _selectedType == 'all' ||
          _normalizeType(service.typeService) == _normalizeType(_selectedType);
      if (!matchesType) return false;

      if (normalized.isEmpty) return true;

      return <String>[
        service.serviceName,
        service.typeService,
        service.description,
      ].any((value) => value.toLowerCase().contains(normalized));
    }).toList();
  }

  Future<void> load({bool forceRefresh = false}) async {
    _setBusy(true);
    _error = null;

    try {
      _services = await _repository.fetchServices(forceRefresh: forceRefresh);
      notifyListeners();
    } on DioException catch (error) {
      _error = _message(error);
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

  void clearQuery() {
    if (_query.isEmpty) return;
    _query = '';
    notifyListeners();
  }

  void clearFilters() {
    if (_query.isEmpty && _selectedType == 'all') return;
    _query = '';
    _selectedType = 'all';
    notifyListeners();
  }

  Future<VendorService?> showService(Object id) async {
    try {
      return await _repository.showService(id);
    } on DioException catch (error) {
      _error = _message(error);
      notifyListeners();
      rethrow;
    }
  }

  Future<VendorService?> createService(VendorServiceDraft draft) async {
    _setBusy(true);
    _error = null;

    try {
      final service = await _repository.createService(draft);
      await load(forceRefresh: true);
      return service;
    } on DioException catch (error) {
      _error = _message(error);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<VendorService?> updateService(
    Object id,
    VendorServiceDraft draft,
  ) async {
    _setBusy(true);
    _error = null;

    try {
      final service = await _repository.updateService(id, draft);
      await load(forceRefresh: true);
      return service;
    } on DioException catch (error) {
      _error = _message(error);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> deleteService(Object id) async {
    _setBusy(true);
    _error = null;

    try {
      await _repository.deleteService(id);
      await load(forceRefresh: true);
    } on DioException catch (error) {
      _error = _message(error);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  void _setBusy(bool value) {
    if (_busy == value) return;
    _busy = value;
    notifyListeners();
  }

  String _message(DioException error) {
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
