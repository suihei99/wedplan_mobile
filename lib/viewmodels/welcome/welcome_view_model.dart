import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:wedplan_mobile/repositories/auth_repository.dart';
import 'package:wedplan_mobile/models/auth/auth_models.dart';

class WelcomeViewModel extends ChangeNotifier {
  bool _busy = false;
  String? _error;

  bool get busy => _busy;
  String? get error => _error;

  Future<Map<String, dynamic>> submit(
    WelcomeAuthMode mode,
    Map<String, dynamic> body,
  ) async {
    _setBusy(true);
    _error = null;

    try {
      final Map<String, dynamic> resp = switch (mode) {
        WelcomeAuthMode.login => await AuthRepository.instance.login(body),
        WelcomeAuthMode.registerCouple =>
          await AuthRepository.instance.registerCouple(body),
        WelcomeAuthMode.registerVendor =>
          await AuthRepository.instance.registerVendor(body),
      };
      return resp;
    } on DioException catch (e) {
      _error = _extractMessage(e);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  void _setBusy(bool v) {
    _busy = v;
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
}
