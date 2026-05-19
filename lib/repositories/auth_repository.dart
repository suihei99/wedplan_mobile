import 'package:wedplan_mobile/core/services/auth_service.dart';

class AuthRepository {
  AuthRepository._();

  static final AuthRepository instance = AuthRepository._();

  final AuthService _service = AuthService.instance;

  Future<Map<String, dynamic>> login(dynamic body) {
    return _service.login(body);
  }

  Future<Map<String, dynamic>> registerCouple(dynamic body) {
    return _service.registerCouple(body);
  }

  Future<Map<String, dynamic>> registerVendor(dynamic body) {
    return _service.registerVendor(body);
  }
}
