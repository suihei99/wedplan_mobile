import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:wedplan_mobile/models/vendor/vendor_service.dart';
import 'package:wedplan_mobile/repositories/vendor/vendor_service_management_repository.dart';

class VendorServiceManagementViewModel extends ChangeNotifier {
  VendorServiceManagementViewModel({
    VendorServiceManagementRepository? repository,
  }) : _repository = repository ?? VendorServiceManagementRepository.instance;

  final VendorServiceManagementRepository _repository;

  bool _busy = false;
  String? _error;
  String _query = '';
  List<VendorService> _services = const <VendorService>[];

  bool get busy => _busy;
  String? get error => _error;
  String get query => _query;
  List<VendorService> get allServices => _services;

  List<VendorService> get visibleServices {
    final normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) return _services;

    return _services.where((service) {
      return <String>[
        service.serviceName,
        service.typeService,
        service.description,
        service.vendorBusinessName,
        service.vendorAddress,
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

  void clearQuery() {
    if (_query.isEmpty) return;
    _query = '';
    notifyListeners();
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
}
