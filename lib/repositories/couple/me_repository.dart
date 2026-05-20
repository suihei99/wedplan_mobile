import 'package:wedplan_mobile/core/network/api_service.dart';
import 'package:wedplan_mobile/core/services/auth_service.dart';
import 'package:wedplan_mobile/models/couple/me_profile.dart';
import 'package:wedplan_mobile/repositories/couple/couple_repository.dart';

class MeRepository {
  MeRepository._({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  static final MeRepository instance = MeRepository._();

  final ApiService _apiService;

  Future<CoupleMeProfile> loadProfile({bool forceRefresh = false}) async {
    final settingsResponse = await _apiService.settings();
    final coupleDetail = await CoupleRepository.instance.coupleDetail(
      forceRefresh: forceRefresh,
    );
    final dashboard = await CoupleRepository.instance.dashboard(
      forceRefresh: forceRefresh,
    );

    return CoupleMeProfile.fromMaps(
      settings: _toMap(settingsResponse.data),
      couple: coupleDetail,
      dashboard: dashboard,
    );
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiService.updateSettings(data);
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> updateCoupleProfile(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.updateSettings(data);
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> changePassword(Map<String, dynamic> data) async {
    final response = await _apiService.updateSettings(data);
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> logout() {
    return AuthService.instance.logout();
  }

  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map<String, dynamic>(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    return <String, dynamic>{'data': data};
  }
}
