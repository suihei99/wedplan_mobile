import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:wedplan_mobile/repositories/vendor/vendor_me_repository.dart';

class VendorMeViewModel extends ChangeNotifier {
  VendorMeViewModel({VendorMeRepository? repository})
    : _repository = repository ?? VendorMeRepository.instance;

  final VendorMeRepository _repository;

  bool _busy = false;
  bool _loggingOut = false;
  String? _error;
  Map<String, dynamic> _profile = const <String, dynamic>{};

  bool get busy => _busy;
  bool get loggingOut => _loggingOut;
  String? get error => _error;
  Map<String, dynamic> get profile => _profile;

  String get email => _readString([
    _readMap(_profile, const ['settings'])['email'],
    _readMap(_profile, const ['settings'])['user_email'],
  ]);

  String get role => _readString([
    _readMap(_profile, const ['settings'])['role'],
    'vendor',
  ], fallback: 'vendor');

  String get businessName => _readString([
    _readMap(_profile, const ['dashboard'])['business_name'],
    _readMap(_profile, const ['dashboard'])['company_name'],
    _readMap(_profile, const ['settings'])['business_name'],
    _readMap(_profile, const ['settings'])['display_name'],
  ], fallback: 'Vendor Account');

  String get statusLabel => _readString([
    _readMap(_profile, const ['dashboard'])['status'],
    _readMap(_profile, const ['dashboard'])['business_status'],
    'Approved',
  ], fallback: 'Approved');

  String get summaryLabel => _readString([
    _readMap(_profile, const ['dashboard'])['summary'],
    _readMap(_profile, const ['dashboard'])['description'],
  ], fallback: 'Manage your account and business profile from here.');

  int get totalServices => _readInt([
    _readMap(_profile, const ['dashboard'])['total_services'],
    _readMap(_profile, const ['dashboard'])['services_total'],
  ]);

  int get totalBookings => _readInt([
    _readMap(_profile, const ['dashboard'])['total_bookings'],
    _readMap(_profile, const ['dashboard'])['bookings_total'],
  ]);

  String get initials {
    final source = businessName.isNotEmpty ? businessName : email;
    if (source.isEmpty) return 'V';
    final parts = source
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return source[0].toUpperCase();
    return parts.take(2).map((part) => part[0]).join().toUpperCase();
  }

  Future<void> load({bool forceRefresh = false}) async {
    _setBusy(true);
    _error = null;

    try {
      _profile = await _repository.loadProfile(forceRefresh: forceRefresh);
      notifyListeners();
    } on DioException catch (error) {
      _error = _message(error);
      _profile = const <String, dynamic>{};
      notifyListeners();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> logout() async {
    _setLoggingOut(true);
    _error = null;

    try {
      await _repository.logout();
    } on DioException catch (error) {
      _error = _message(error);
      rethrow;
    } finally {
      _setLoggingOut(false);
    }
  }

  void _setBusy(bool value) {
    if (_busy == value) return;
    _busy = value;
    notifyListeners();
  }

  void _setLoggingOut(bool value) {
    if (_loggingOut == value) return;
    _loggingOut = value;
    notifyListeners();
  }

  Map<String, dynamic> _readMap(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value is Map<String, dynamic>) return value;
      if (value is Map) {
        return value.map<String, dynamic>(
          (mapKey, mapValue) => MapEntry(mapKey.toString(), mapValue),
        );
      }
    }
    return <String, dynamic>{};
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

  String _readString(Iterable<dynamic> values, {String fallback = ''}) {
    for (final value in values) {
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text != 'null') return text;
    }
    return fallback;
  }

  int _readInt(Iterable<dynamic> values) {
    for (final value in values) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null) return parsed;
      }
    }
    return 0;
  }
}
