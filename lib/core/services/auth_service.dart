import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wedplan_mobile/core/network/api_service.dart';
import 'package:wedplan_mobile/core/services/app_session_cache.dart';
import 'package:wedplan_mobile/services/push_notification_service.dart';
import 'package:wedplan_mobile/repositories/couple/me_repository.dart';

class AuthService {
  AuthService._internal({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  static final AuthService instance = AuthService._internal();

  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'auth_role';
  static const String _userDetailKey = 'auth_user_detail';
  static const String _coupleDetailKey = 'auth_couple_detail';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiService _apiService;

  Future<String?> get token => _storage.read(key: _tokenKey);

  Future<String?> get role => _storage.read(key: _roleKey);

  Future<void> setToken(String? value) async {
    if (value == null || value.trim().isEmpty) {
      await _storage.delete(key: _tokenKey);
      return;
    }

    await _storage.write(key: _tokenKey, value: value.trim());
  }

  Future<void> setRole(String? value) async {
    if (value == null || value.trim().isEmpty) {
      await _storage.delete(key: _roleKey);
      return;
    }

    await _storage.write(key: _roleKey, value: value.trim().toLowerCase());
  }

  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  Future<void> clearRole() => _storage.delete(key: _roleKey);

  Future<bool> hasToken() async {
    final currentToken = await token;
    return currentToken != null && currentToken.isNotEmpty;
  }

  Future<bool> hasRole() async {
    final currentRole = await role;
    return currentRole != null && currentRole.isNotEmpty;
  }

  Future<Map<String, dynamic>> login(dynamic data) async {
    print('🔐 AuthService.login() starting...');
    // Attach device token (if available) to the login payload so backend
    // can register the device during authentication.
    dynamic loginPayload = data;
    try {
      final deviceToken = await PushNotificationService.instance
          .getDeviceToken();
      if (deviceToken != null && deviceToken.isNotEmpty) {
        if (data is Map<String, dynamic>) {
          loginPayload = {...data, 'device_token': deviceToken};
        } else if (data is Map) {
          loginPayload = Map<String, dynamic>.from(data as Map)
            ..['device_token'] = deviceToken;
        }
      }
    } catch (_) {
      // ignore token fetch failures and continue with original payload
      loginPayload = data;
    }

    final response = await _apiService.login(loginPayload);
    print('🔐 AuthService.login() - API response received');
    print('🔐 Response data type: ${response.data.runtimeType}');
    print('🔐 Response data: ${response.data}');

    await _storeTokenFromResponse(response.data);
    print('🔐 Token stored');

    AppSessionCache.instance.seedFromAuthResponse(response.data);
    print('🔐 Session cache seeded');

    await _storeSessionDetails(response.data);
    print('🔐 Session details persisted');

    // Register current device token with backend (if any)
    try {
      final deviceToken = await PushNotificationService.instance
          .getDeviceToken();
      if (deviceToken != null && deviceToken.isNotEmpty) {
        await MeRepository.instance.updateProfile({
          'device_token': deviceToken,
        });
        print('🔔 Device token registered with server');
      }
    } catch (e) {
      print('🔔 Failed to register device token: $e');
    }

    // Debug: log what was extracted
    print('🔐 AuthService.login - Cache check:');
    print(
      '   - coupleDisplayName: "${AppSessionCache.instance.coupleDisplayName}"',
    );
    print(
      '   - partner1: "${AppSessionCache.instance.partner1Name}", partner2: "${AppSessionCache.instance.partner2Name}"',
    );
    return _mapResponse(response);
  }

  Future<Map<String, dynamic>> registerCouple(dynamic data) async {
    final response = await _apiService.registerCouple(data);
    await _storeTokenFromResponse(response.data);
    AppSessionCache.instance.seedFromAuthResponse(response.data);
    await _storeSessionDetails(response.data);
    return _mapResponse(response);
  }

  Future<Map<String, dynamic>> registerVendor(dynamic data) async {
    final response = await _apiService.registerVendor(data);
    await _storeTokenFromResponse(response.data);
    AppSessionCache.instance.seedFromAuthResponse(response.data);
    await _storeSessionDetails(response.data);
    return _mapResponse(response);
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _apiService.logout();
      await clearToken();
      await clearRole();
      await _clearSessionDetails();
      AppSessionCache.instance.clear();
      return _mapResponse(response);
    } on DioException {
      await clearToken();
      await clearRole();
      await _clearSessionDetails();
      AppSessionCache.instance.clear();
      rethrow;
    }
  }

  Future<void> hydrateSessionCache() async {
    final userDetail = await _readStoredMap(_userDetailKey);
    final coupleDetail = await _readStoredMap(_coupleDetailKey);

    if (userDetail != null) {
      AppSessionCache.instance.userDetail = userDetail;
    }

    if (coupleDetail != null) {
      AppSessionCache.instance.coupleDetail = coupleDetail;
    }
  }

  Future<String?> syncTokenFromResponse(dynamic payload) async {
    final tokenValue = _extractToken(payload);
    if (tokenValue != null && tokenValue.isNotEmpty) {
      await setToken(tokenValue);
    }
    return tokenValue;
  }

  Future<void> _storeTokenFromResponse(dynamic payload) {
    final tokenValue = _extractToken(payload);
    final roleValue = _extractRole(payload);

    return Future.wait(<Future<void>>[
      setToken(tokenValue),
      setRole(roleValue),
    ]).then((_) {});
  }

  Future<void> _storeSessionDetails(dynamic payload) async {
    final normalized = _toMap(payload);
    final data = _readMap(normalized, ['data']);
    var user = _readMap(normalized, ['user']);

    if (user.isEmpty && data.isNotEmpty) {
      user = _readMap(data, ['user']);
      if (user.isEmpty && _looksLikeProfile(data)) {
        user = data;
      }
    }

    var couple = _readMap(user, ['couple']);
    var vendor = _readMap(user, ['vendor']);

    if (couple.isEmpty && vendor.isEmpty) {
      couple = _readMap(normalized, ['couple']);
      vendor = _readMap(normalized, ['vendor']);
    }

    if (user.isNotEmpty) {
      await _storage.write(key: _userDetailKey, value: jsonEncode(user));
    }

    if (couple.isNotEmpty) {
      await _storage.write(key: _coupleDetailKey, value: jsonEncode(couple));
    } else if (vendor.isNotEmpty) {
      await _storage.write(key: _coupleDetailKey, value: jsonEncode(vendor));
    }
  }

  Future<void> _clearSessionDetails() async {
    await Future.wait(<Future<void>>[
      _storage.delete(key: _userDetailKey),
      _storage.delete(key: _coupleDetailKey),
    ]);
  }

  Future<Map<String, dynamic>?> _readStoredMap(String key) async {
    final value = await _storage.read(key: key);
    if (value == null || value.trim().isEmpty) return null;

    final decoded = jsonDecode(value);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) {
      return decoded.map<String, dynamic>((k, v) => MapEntry(k.toString(), v));
    }
    return null;
  }

  Map<String, dynamic> _mapResponse(Response<dynamic> response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return data.map<String, dynamic>(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    return <String, dynamic>{'data': data};
  }

  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map<String, dynamic>(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> _readMap(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value is Map<String, dynamic>) return value;
      if (value is Map) {
        return value.map<String, dynamic>((k, v) => MapEntry(k.toString(), v));
      }
    }
    return <String, dynamic>{};
  }

  String? _extractToken(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final directToken = payload['token'] ?? payload['access_token'];
      if (directToken is String && directToken.isNotEmpty) {
        return directToken;
      }

      final data = payload['data'];
      final nestedToken = _extractToken(data);
      if (nestedToken != null) {
        return nestedToken;
      }

      final nestedAuth = payload['auth'];
      return _extractToken(nestedAuth);
    }

    if (payload is Map) {
      return _extractToken(
        payload.map<String, dynamic>(
          (key, value) => MapEntry(key.toString(), value),
        ),
      );
    }

    return null;
  }

  String? _extractRole(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final directRole = payload['role'];
      if (directRole is String && directRole.isNotEmpty) {
        return directRole;
      }

      for (final value in payload.values) {
        final nestedRole = _extractRole(value);
        if (nestedRole != null && nestedRole.isNotEmpty) {
          return nestedRole;
        }
      }
    }

    if (payload is Map) {
      return _extractRole(
        payload.map<String, dynamic>(
          (key, value) => MapEntry(key.toString(), value),
        ),
      );
    }

    if (payload is List) {
      for (final value in payload) {
        final nestedRole = _extractRole(value);
        if (nestedRole != null && nestedRole.isNotEmpty) {
          return nestedRole;
        }
      }
    }

    return null;
  }

  bool _looksLikeProfile(Map<String, dynamic> data) {
    return data.containsKey('email') ||
        data.containsKey('role') ||
        data.containsKey('profile_photo_path') ||
        data.containsKey('is_active');
  }
}
