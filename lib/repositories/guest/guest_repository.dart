import 'package:wedplan_mobile/core/network/api_service.dart';

class GuestRepository {
  GuestRepository._({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  static final GuestRepository instance = GuestRepository._();

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchInvitation(String code) async {
    final response = await _apiService.guestInvitation(code);
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> checkIn(
    String invitationId,
    Map<String, dynamic> data,
  ) async {
    // If invitationId is numeric, call the couple-managed (authenticated)
    // check-in endpoint. Otherwise treat it as an invite code and call the
    // public, unauthenticated check-in endpoint.
    final isNumeric = RegExp(r'^\d+$').hasMatch(invitationId);
    if (isNumeric) {
      final response = await _apiService.guestCheckIn(invitationId, data);
      return _toMap(response.data);
    }

    final response = await _apiService.guestPublicCheckIn(invitationId, data);
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> updateRsvp(
    String invitationId,
    Map<String, dynamic> data,
  ) async {
    // Use the public guest RSVP endpoint which does not require auth.
    final response = await _apiService.guestPublicUpdateRsvp(
      invitationId,
      data,
    );
    return _toMap(response.data);
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
