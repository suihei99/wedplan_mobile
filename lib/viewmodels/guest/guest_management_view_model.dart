import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:wedplan_mobile/models/guest/guest.dart';
import 'package:wedplan_mobile/repositories/guest/guest_repository.dart';

enum GuestFilterStatus { all, pending, confirmed, declined }

class GuestManagementViewModel extends ChangeNotifier {
  bool _busy = false;
  String? _error;
  List<Guest> _guests = const <Guest>[];
  String _searchQuery = '';
  GuestFilterStatus _statusFilter = GuestFilterStatus.all;

  bool get busy => _busy;
  String? get error => _error;
  List<Guest> get guests => _guests;
  String get searchQuery => _searchQuery;
  GuestFilterStatus get statusFilter => _statusFilter;

  List<Guest> get filteredGuests {
    final query = _searchQuery.trim().toLowerCase();
    return _guests.where((guest) {
      final matchesQuery =
          query.isEmpty ||
          guest.name.toLowerCase().contains(query) ||
          guest.phone.toLowerCase().contains(query) ||
          guest.inviteCode.toLowerCase().contains(query);

      final matchesStatus = switch (_statusFilter) {
        GuestFilterStatus.all => true,
        GuestFilterStatus.pending => guest.isPending,
        GuestFilterStatus.confirmed => guest.isConfirmed,
        GuestFilterStatus.declined => guest.isDeclined,
      };

      return matchesQuery && matchesStatus;
    }).toList();
  }

  int get totalGuests => _guests.length;
  int get confirmedCount => _guests.where((guest) => guest.isConfirmed).length;
  int get pendingCount => _guests.where((guest) => guest.isPending).length;
  int get declinedCount => _guests.where((guest) => guest.isDeclined).length;

  Future<void> loadGuests({bool forceRefresh = false}) async {
    _setBusy(true);
    _error = null;

    try {
      _guests = await GuestRepository.instance.fetchGuests();
      notifyListeners();
    } on DioException catch (error) {
      _error = _extractMessage(error);
      if (!forceRefresh) {
        _guests = const <Guest>[];
      }
      notifyListeners();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> createGuest({
    required String name,
    required String phone,
    required int paxCount,
    String rsvpStatus = 'pending',
  }) async {
    _setBusy(true);
    _error = null;

    try {
      await GuestRepository.instance.createGuest(<String, dynamic>{
        'name': name,
        'phone': phone,
        'pax_count': paxCount,
        'rsvp_status': rsvpStatus,
      });
      await loadGuests(forceRefresh: true);
    } on DioException catch (error) {
      _error = _extractMessage(error);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> updateGuest({
    required Object id,
    required String name,
    required String phone,
    required int paxCount,
    required String rsvpStatus,
  }) async {
    _setBusy(true);
    _error = null;

    try {
      await GuestRepository.instance.updateGuest(id, <String, dynamic>{
        'name': name,
        'phone': phone,
        'pax_count': paxCount,
        'rsvp_status': rsvpStatus,
      });
      await loadGuests(forceRefresh: true);
    } on DioException catch (error) {
      _error = _extractMessage(error);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> updateRsvp(Object id, String status) async {
    _setBusy(true);
    _error = null;

    try {
      await GuestRepository.instance.updateGuestRsvp(id, <String, dynamic>{
        'rsvp_status': status,
      });
      await loadGuests(forceRefresh: true);
    } on DioException catch (error) {
      _error = _extractMessage(error);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> checkInGuest(Object id) async {
    _setBusy(true);
    _error = null;

    try {
      await GuestRepository.instance.checkInGuest(id, <String, dynamic>{});
      await loadGuests(forceRefresh: true);
    } on DioException catch (error) {
      _error = _extractMessage(error);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> deleteGuest(Object id) async {
    _setBusy(true);
    _error = null;

    try {
      await GuestRepository.instance.deleteGuest(id);
      await loadGuests(forceRefresh: true);
    } on DioException catch (error) {
      _error = _extractMessage(error);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  void updateSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void updateStatusFilter(GuestFilterStatus value) {
    _statusFilter = value;
    notifyListeners();
  }

  Guest? guestById(Object id) {
    for (final guest in _guests) {
      if (guest.id == id.toString()) return guest;
    }
    return null;
  }

  void _setBusy(bool value) {
    if (_busy == value) return;
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
