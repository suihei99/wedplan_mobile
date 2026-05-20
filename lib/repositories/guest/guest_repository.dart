import 'package:wedplan_mobile/core/network/api_service.dart';
import 'package:wedplan_mobile/models/guest/guest.dart';

class GuestRepository {
  GuestRepository._({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  static final GuestRepository instance = GuestRepository._();

  final ApiService _apiService;

  Future<List<Guest>> fetchGuests() async {
    final response = await _apiService.guests();
    final data = _toMap(response.data);
    final items = data['data'];

    if (items is List) {
      return items
          .whereType<Map>()
          .map(
            (item) => Guest.fromJson(
              item.map<String, dynamic>(
                (key, value) => MapEntry(key.toString(), value),
              ),
            ),
          )
          .toList();
    }

    if (items is Map) {
      return [
        Guest.fromJson(
          items.map<String, dynamic>(
            (key, value) => MapEntry(key.toString(), value),
          ),
        ),
      ];
    }

    return const <Guest>[];
  }

  Future<Guest> createGuest(Map<String, dynamic> data) async {
    final response = await _apiService.guestCreate(data);
    return Guest.fromJson(_toMap(response.data));
  }

  Future<Guest> fetchGuest(Object id) async {
    final response = await _apiService.guestShow(id);
    return Guest.fromJson(_toMap(response.data));
  }

  Future<Guest> updateGuest(Object id, Map<String, dynamic> data) async {
    final response = await _apiService.guestUpdate(id, data);
    return Guest.fromJson(_toMap(response.data));
  }

  Future<Guest> updateGuestRsvp(Object id, Map<String, dynamic> data) async {
    final response = await _apiService.guestUpdateRsvp(id, data);
    return Guest.fromJson(_toMap(response.data));
  }

  Future<Guest> checkInGuest(Object id, Map<String, dynamic> data) async {
    final response = await _apiService.guestCheckIn(id, data);
    return Guest.fromJson(_toMap(response.data));
  }

  Future<void> deleteGuest(Object id) async {
    await _apiService.guestDelete(id);
  }

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

  Future<Map<String, dynamic>> addGuestInvitation(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.guestCreate(data);
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
