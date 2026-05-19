import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:wedplan_mobile/models/guest/guest_invitation.dart';
import 'package:wedplan_mobile/repositories/guest/guest_repository.dart';

class GuestInvitationViewModel extends ChangeNotifier {
  static const String confirmedStatus = 'confirmed';
  static const String rejectedStatus = 'rejected';

  bool _busy = false;
  String? _error;
  GuestInvitation? _invitation;

  bool get busy => _busy;
  String? get error => _error;
  GuestInvitation? get invitation => _invitation;

  Future<void> loadInvitation(String code) async {
    if (code.trim().isEmpty) {
      _error = 'Enter an invitation code.';
      notifyListeners();
      return;
    }

    _setBusy(true);
    _error = null;

    try {
      final response = await GuestRepository.instance.fetchInvitation(
        code.trim(),
      );
      _invitation = GuestInvitation.fromJson(response);
    } on DioException catch (error) {
      _error = _extractMessage(error);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> checkIn(String guestName) async {
    final current = _invitation;
    if (current == null) {
      _error = 'Invitation not loaded yet.';
      notifyListeners();
      return;
    }

    final targetId = current.invitationId.trim().isNotEmpty
        ? current.invitationId.trim()
        : current.code.trim();
    if (targetId.isEmpty) {
      _error = 'Invitation identifier is missing.';
      notifyListeners();
      return;
    }

    _setBusy(true);
    _error = null;

    try {
      final response = await GuestRepository.instance
          .checkIn(targetId, <String, dynamic>{
            'code': current.code,
            if (guestName.trim().isNotEmpty) 'guest_name': guestName.trim(),
          });

      final updated = GuestInvitation.fromJson(response);
      _invitation = updated.invitationId.isNotEmpty
          ? updated
          : current.copyWith(checkedIn: true, rsvpStatus: confirmedStatus);
    } on DioException catch (error) {
      _error = _extractMessage(error);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> updateRsvp(String status, {String guestName = ''}) async {
    final current = _invitation;
    if (current == null) {
      _error = 'Invitation not loaded yet.';
      notifyListeners();
      return;
    }

    final targetId = current.invitationId.trim().isNotEmpty
        ? current.invitationId.trim()
        : current.code.trim();
    if (targetId.isEmpty) {
      _error = 'Invitation identifier is missing.';
      notifyListeners();
      return;
    }

    _setBusy(true);
    _error = null;

    try {
      final response = await GuestRepository.instance
          .updateRsvp(targetId, <String, dynamic>{
            'rsvp_status': status,
            'code': current.code,
            if (guestName.trim().isNotEmpty) 'guest_name': guestName.trim(),
          });

      final updated = GuestInvitation.fromJson(response);
      _invitation = current.copyWith(
        code: updated.code.isNotEmpty ? updated.code : current.code,
        title: updated.title.isNotEmpty ? updated.title : current.title,
        coupleName: updated.coupleName.isNotEmpty
            ? updated.coupleName
            : current.coupleName,
        eventName: updated.eventName.isNotEmpty
            ? updated.eventName
            : current.eventName,
        venue: updated.venue.isNotEmpty ? updated.venue : current.venue,
        message: updated.message.isNotEmpty ? updated.message : current.message,
        invitationId: updated.invitationId.isNotEmpty
            ? updated.invitationId
            : current.invitationId,
        checkedIn: updated.checkedIn || current.checkedIn,
        rsvpStatus: updated.rsvpStatus.isNotEmpty ? updated.rsvpStatus : status,
        raw: updated.raw,
      );
    } on DioException catch (error) {
      _error = _extractMessage(error);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  void clear() {
    _invitation = null;
    _error = null;
    notifyListeners();
  }

  void _setBusy(bool value) {
    _busy = value;
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
