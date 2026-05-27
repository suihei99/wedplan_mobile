import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:wedplan_mobile/repositories/vendor/vendor_me_repository.dart';

class VendorMeViewModel extends ChangeNotifier {
  VendorMeViewModel({VendorMeRepository? repository})
    : _repository = repository ?? VendorMeRepository.instance;

  final VendorMeRepository _repository;

  bool _busy = false;
  bool _saving = false;
  bool _loggingOut = false;
  String? _error;
  String? _success;
  Map<String, dynamic> _profile = const <String, dynamic>{};

  bool get busy => _busy;
  bool get saving => _saving;
  bool get loggingOut => _loggingOut;
  String? get error => _error;
  String? get success => _success;
  Map<String, dynamic> get profile => _profile;

  Map<String, dynamic> get settings => _readMap(_profile, const ['settings']);

  Map<String, dynamic> get dashboard => _readMap(_profile, const ['dashboard']);

  String get email => _readString([
    _readMap(settings, const ['user', 'profile'])['email'],
    settings['email'],
    settings['user_email'],
  ]);

  String get role => _readString([
    _readMap(settings, const ['user', 'profile'])['role'],
    settings['role'],
    'vendor',
  ], fallback: 'vendor');

  String get businessName => _readString([
    _readMap(dashboard, const ['vendor'])['business_name'],
    _readMap(dashboard, const ['vendor'])['company_name'],
    dashboard['business_name'],
    dashboard['company_name'],
    settings['business_name'],
    settings['display_name'],
    settings['company_name'],
  ], fallback: 'Vendor Account');

  String get businessType => _readString([
    _readMap(dashboard, const ['vendor'])['business_type'],
    dashboard['business_type'],
    settings['business_type'],
  ]);

  String get contactNumber => _readString([
    _readMap(dashboard, const ['vendor'])['contact_number'],
    dashboard['contact_number'],
    settings['contact_number'],
  ]);

  String get address => _readString([
    _readMap(dashboard, const ['vendor'])['address'],
    dashboard['address'],
    settings['address'],
  ]);

  String get displayName => _readString([
    settings['display_name'],
    _readMap(dashboard, const ['vendor'])['display_name'],
    _readMap(dashboard, const ['vendor'])['owner_name'],
    dashboard['display_name'],
    dashboard['owner_name'],
  ], fallback: businessName);

  String get profilePhotoPath => _readString([
    _readMap(settings, const ['user', 'profile'])['profile_photo_path'],
    settings['profile_photo_path'],
    _readMap(dashboard, const ['vendor'])['profile_photo_path'],
    dashboard['profile_photo_path'],
  ]);

  String get profilePhotoUrl => _readString([
    _readMap(settings, const ['user', 'profile'])['profile_photo_url'],
    settings['profile_photo_url'],
    _readMap(dashboard, const ['vendor'])['profile_photo_url'],
    dashboard['profile_photo_url'],
  ]);

  String get businessDocumentPath => _readString([
    _readMap(dashboard, const ['vendor'])['business_documents'],
    dashboard['business_documents'],
    settings['business_documents'],
  ]);

  String get businessDocumentUrl => _readString([
    _readMap(dashboard, const ['vendor'])['business_document_url'],
    dashboard['business_document_url'],
    settings['business_document_url'],
  ]);

  bool get hasProfilePhoto => profilePhotoUrl.isNotEmpty;

  bool get hasBusinessDocument =>
      businessDocumentUrl.isNotEmpty || businessDocumentPath.isNotEmpty;

  String get statusLabel => _readString([
    _readMap(dashboard, const ['vendor'])['status'],
    _readMap(dashboard, const ['vendor'])['business_status'],
    dashboard['status'],
    dashboard['business_status'],
    'Approved',
  ], fallback: 'Approved');

  String get summaryLabel => _readString([
    _readMap(dashboard, const ['vendor'])['summary'],
    _readMap(dashboard, const ['vendor'])['description'],
    dashboard['summary'],
    dashboard['description'],
  ], fallback: 'Manage your account and business profile from here.');

  int get totalServices => _readInt([
    _readMap(dashboard, const ['vendor'])['total_services'],
    _readMap(dashboard, const ['vendor'])['services_total'],
    _readMap(dashboard, const ['vendor'])['service_count'],
    dashboard['total_services'],
    dashboard['services_total'],
    dashboard['service_count'],
    _readListOfMaps(dashboard, const ['services', 'featured_services']).length,
  ]);

  int get totalBookings => _readInt([
    _readMap(dashboard, const ['vendor'])['total_bookings'],
    _readMap(dashboard, const ['vendor'])['bookings_total'],
    _readMap(dashboard, const ['vendor'])['booking_count'],
    dashboard['total_bookings'],
    dashboard['bookings_total'],
    dashboard['booking_count'],
    _readListOfMaps(dashboard, const ['bookings', 'upcoming_bookings']).length,
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

  Future<void> updateProfile({
    String? businessType,
    String? contactNumber,
    String? address,
    String? email,
    String? profilePhotoPath,
    String? businessDocumentPath,
  }) async {
    _setSaving(true);
    _error = null;
    _success = null;

    try {
      final payload = <String, dynamic>{
        if (businessType != null && businessType.trim().isNotEmpty)
          'business_type': businessType.trim(),
        if (contactNumber != null && contactNumber.trim().isNotEmpty)
          'contact_number': contactNumber.trim(),
        if (address != null && address.trim().isNotEmpty)
          'address': address.trim(),
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
      };

      if (profilePhotoPath != null && profilePhotoPath.trim().isNotEmpty) {
        payload['profile_photo'] = await MultipartFile.fromFile(
          profilePhotoPath.trim(),
        );
      }

      if (businessDocumentPath != null &&
          businessDocumentPath.trim().isNotEmpty) {
        payload['business_documents'] = await MultipartFile.fromFile(
          businessDocumentPath.trim(),
        );
      }

      final response = await _repository.updateProfile(
        FormData.fromMap(payload),
      );
      _profile = await _repository.loadProfile(forceRefresh: true);
      _success = _messageFromResponse(response) ?? 'Profile updated.';
      notifyListeners();
    } on DioException catch (error) {
      _error = _message(error);
      rethrow;
    } finally {
      _setSaving(false);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setSaving(true);
    _error = null;
    _success = null;

    try {
      final response = await _repository.changePassword({
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
      _success = _messageFromResponse(response) ?? 'Password updated.';
      notifyListeners();
    } on DioException catch (error) {
      _error = _message(error);
      rethrow;
    } finally {
      _setSaving(false);
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

  void _setSaving(bool value) {
    if (_saving == value) return;
    _saving = value;
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

  List<Map<String, dynamic>> _readListOfMaps(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value is Iterable) {
        return value
            .whereType<Map>()
            .map(
              (item) => item.map<String, dynamic>(
                (mapKey, mapValue) => MapEntry(mapKey.toString(), mapValue),
              ),
            )
            .toList();
      }
    }
    return <Map<String, dynamic>>[];
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

  String? _messageFromResponse(Map<String, dynamic> response) {
    final message = response['message'];
    if (message is String && message.isNotEmpty) return message;
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      final nestedMessage = data['message'];
      if (nestedMessage is String && nestedMessage.isNotEmpty) {
        return nestedMessage;
      }
    }
    return null;
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
