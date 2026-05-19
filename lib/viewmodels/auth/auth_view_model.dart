import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:wedplan_mobile/models/auth/auth_models.dart';
import 'package:wedplan_mobile/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  bool _busy = false;
  String? _error;

  bool get busy => _busy;
  String? get error => _error;

  Future<Map<String, dynamic>> submit(AuthMode mode, dynamic body) async {
    _setBusy(true);
    _error = null;

    try {
      final Map<String, dynamic> response = switch (mode) {
        AuthMode.login => await AuthRepository.instance.login(body),
        AuthMode.registerCouple => await AuthRepository.instance.registerCouple(
          body,
        ),
        AuthMode.registerVendor => await AuthRepository.instance.registerVendor(
          body,
        ),
      };
      return response;
    } on DioException catch (error) {
      _error = extractAuthErrorMessage(error);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  void _setBusy(bool value) {
    if (_busy == value) {
      return;
    }

    _busy = value;
    notifyListeners();
  }
}
