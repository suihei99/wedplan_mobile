import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:wedplan_mobile/models/couple/me_profile.dart';
import 'package:intl/intl.dart';
import 'package:wedplan_mobile/repositories/couple/me_repository.dart';
import 'package:wedplan_mobile/core/services/app_session_cache.dart';

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
      final payload = <String, dynamic>{};
      if (partner1Name.trim().isNotEmpty)
        payload['partner_1_name'] = partner1Name.trim();
      if (partner2Name.trim().isNotEmpty)
        payload['partner_2_name'] = partner2Name.trim();
      if (weddingDate.trim().isNotEmpty)
        payload['wedding_date'] = weddingDate.trim();
      if (weddingVenue.trim().isNotEmpty)
        payload['wedding_venue'] = weddingVenue.trim();
      if (weddingTime.trim().isNotEmpty)
        payload['wedding_time'] = weddingTime.trim();

      final budgetTrim = totalBudgetLimit.trim();
      if (budgetTrim.isNotEmpty) {
        final asInt = int.tryParse(budgetTrim);
        final asDouble = double.tryParse(budgetTrim);
        if (asInt != null) {
          payload['total_budget_limit'] = asInt;
        } else if (asDouble != null) {
          payload['total_budget_limit'] = asDouble;
        }
      }

      final response = await MeRepository.instance.updateCoupleProfile(payload);

      final refreshedProfile = await MeRepository.instance.loadProfile(
        forceRefresh: true,
      );

      // Ensure global cache reflects refreshed values so other screens pick them up
      try {
        // Importing AppSessionCache here is fine; update the global cached maps
        // using the raw maps produced by the profile parser.
        final cache = AppSessionCache.instance;
        cache.coupleDetail = refreshedProfile.rawCouple;
        cache.dashboard = refreshedProfile.rawDashboard;
      } catch (_) {}

      if (!_matchesCoupleProfile(
        refreshedProfile,
        partner1Name: partner1Name,
        partner2Name: partner2Name,
        weddingDate: weddingDate,
        weddingVenue: weddingVenue,
        weddingTime: weddingTime,
        totalBudgetLimit: totalBudgetLimit,
      )) {
        const message =
            'Profile saved, but the backend did not return the updated couple details.';
        _profile = refreshedProfile;
        _error = message;
        throw StateError(message);
      }

      _profile = refreshedProfile;
      _success = _messageFromResponse(response) ?? 'Profile updated.';
      notifyListeners();
    } on DioException catch (error) {
      _error = _message(error);
      rethrow;
    } on StateError {
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

  bool _matchesCoupleProfile(
    CoupleMeProfile profile, {
    required String partner1Name,
    required String partner2Name,
    required String weddingDate,
    required String weddingVenue,
    required String weddingTime,
    required String totalBudgetLimit,
  }) {
    // Normalize and compare partner names
    if (profile.partner1Name.trim() != partner1Name.trim()) return false;
    if (profile.partner2Name.trim() != partner2Name.trim()) return false;

    // Compare wedding date by year/month/day if possible, otherwise fallback to trimmed string compare
    DateTime? parseDate(String s) {
      final t = s.trim();
      if (t.isEmpty) return null;
      try {
        return DateTime.parse(t);
      } catch (_) {}
      try {
        return DateFormat('yyyy-MM-dd').parseLoose(t);
      } catch (_) {}
      try {
        return DateFormat('MMMM d, yyyy').parseLoose(t);
      } catch (_) {}
      return null;
    }

    final serverDate = parseDate(profile.weddingDate ?? '');
    final expectedDate = parseDate(weddingDate);
    if (serverDate != null && expectedDate != null) {
      if (!(serverDate.year == expectedDate.year &&
          serverDate.month == expectedDate.month &&
          serverDate.day == expectedDate.day))
        return false;
    } else {
      if (profile.weddingDate.trim() != weddingDate.trim()) return false;
    }

    // Compare wedding venue (trimmed)
    if (profile.weddingVenue.trim() != weddingVenue.trim()) return false;

    // Normalize and compare wedding time (compare hours and minutes)
    DateTime? parseTime(String s) {
      final t = s.trim();
      if (t.isEmpty) return null;
      // Try several common formats
      try {
        return DateFormat('HH:mm:ss').parseLoose(t);
      } catch (_) {}
      try {
        return DateFormat('HH:mm').parseLoose(t);
      } catch (_) {}
      try {
        return DateFormat('h:mm a').parseLoose(t);
      } catch (_) {}
      // Fallback: regex capture HH:mm
      final m = RegExp(r"(\d{1,2}):(\d{2})").firstMatch(t);
      if (m != null) {
        final h = int.tryParse(m.group(1) ?? '0') ?? 0;
        final mm = int.tryParse(m.group(2) ?? '0') ?? 0;
        return DateTime(0).add(Duration(hours: h, minutes: mm));
      }
      return null;
    }

    final serverTime = parseTime(profile.weddingTime ?? '');
    final expectedTime = parseTime(weddingTime);
    if (serverTime != null && expectedTime != null) {
      if (!(serverTime.hour == expectedTime.hour &&
          serverTime.minute == expectedTime.minute))
        return false;
    } else {
      if (profile.weddingTime.trim() != weddingTime.trim()) return false;
    }

    // Compare budgets numerically (allow small rounding differences)
    final expectedBudget = double.tryParse(totalBudgetLimit.trim());
    if (expectedBudget != null) {
      if ((profile.totalBudgetLimit - expectedBudget).abs() >= 0.01) {
        return false;
      }
    }

    return true;
  }
}
