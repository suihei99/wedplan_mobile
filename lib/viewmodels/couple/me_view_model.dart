import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:wedplan_mobile/models/couple/me_profile.dart';
import 'package:wedplan_mobile/repositories/couple/me_repository.dart';

class MeViewModel extends ChangeNotifier {
  bool _busy = false;
  bool _saving = false;
  bool _loggingOut = false;
  String? _error;
  String? _success;
  CoupleMeProfile? _profile;

  bool get busy => _busy;
  bool get saving => _saving;
  bool get loggingOut => _loggingOut;
  String? get error => _error;
  String? get success => _success;
  CoupleMeProfile? get profile => _profile;

  Future<void> load({bool forceRefresh = false}) async {
    _setBusy(true);
    _error = null;

    try {
      _profile = await MeRepository.instance.loadProfile(
        forceRefresh: forceRefresh,
      );
      _success = null;
    } on DioException catch (error) {
      _error = _message(error);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> updateProfile(String email) async {
    _setSaving(true);
    _error = null;
    _success = null;

    try {
      final response = await MeRepository.instance.updateProfile({
        'email': email.trim(),
      });
      _profile = await MeRepository.instance.loadProfile(forceRefresh: true);
      _success = _messageFromResponse(response) ?? 'Profile updated.';
      notifyListeners();
    } on DioException catch (error) {
      _error = _message(error);
      rethrow;
    } finally {
      _setSaving(false);
    }
  }

  Future<void> updateCoupleProfile({
    required String partner1Name,
    required String partner2Name,
    required String weddingDate,
    required String weddingVenue,
    required String weddingTime,
    required String totalBudgetLimit,
  }) async {
    _setSaving(true);
    _error = null;
    _success = null;

    try {
      final response = await MeRepository.instance.updateCoupleProfile({
        'partner_1_name': partner1Name.trim(),
        'partner_2_name': partner2Name.trim(),
        'wedding_date': weddingDate.trim(),
        'wedding_venue': weddingVenue.trim(),
        'wedding_time': weddingTime.trim(),
        'total_budget_limit': totalBudgetLimit.trim(),
      });
      _profile = await MeRepository.instance.loadProfile(forceRefresh: true);
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
      final response = await MeRepository.instance.changePassword({
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
      await MeRepository.instance.logout();
    } on DioException catch (error) {
      _error = _message(error);
      rethrow;
    } finally {
      _setLoggingOut(false);
    }
  }

  void clearMessages() {
    _error = null;
    _success = null;
    notifyListeners();
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
}
