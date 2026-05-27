import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:wedplan_mobile/models/vendor/vendor_booking_draft.dart';
import 'package:wedplan_mobile/repositories/vendor/vendor_booking_repository.dart';

class VendorBookingViewModel extends ChangeNotifier {
  VendorBookingViewModel({VendorBookingRepository? repository})
    : _repository = repository ?? VendorBookingRepository.instance;

  final VendorBookingRepository _repository;

  bool _busy = false;
  String? _error;
  List<Map<String, dynamic>> _bookings = const <Map<String, dynamic>>[];
  String _query = '';
  String _selectedStatus = 'all';

  bool get busy => _busy;
  String? get error => _error;
  List<Map<String, dynamic>> get bookings => _bookings;
  String get query => _query;
  String get selectedStatus => _selectedStatus;

  List<Map<String, dynamic>> get visibleBookings {
    final normalizedQuery = _query.trim().toLowerCase();
    return _bookings.where((booking) {
      final status = bookingStatusLabel(booking);
      final matchesStatus =
          _selectedStatus == 'all' ||
          status.toLowerCase().contains(_selectedStatus.toLowerCase());
      if (!matchesStatus) return false;

      if (normalizedQuery.isEmpty) return true;

      return <String>[
        bookingTitle(booking),
        bookingSubtitle(booking),
        bookingNotes(booking),
        bookingTypeLabel(booking),
        status,
        _readString(booking, const ['couple_id', 'customer_id']),
      ].any((value) => value.toLowerCase().contains(normalizedQuery));
    }).toList();
  }

  int get totalBookings => _bookings.length;

  int get pendingBookings => _bookings.where((item) {
    final status = _readString(item, const [
      'status',
      'booking_status',
      'state',
    ]);
    return status.toLowerCase().contains('pending');
  }).length;

  int get confirmedBookings => _bookings.where((item) {
    final status = _readString(item, const [
      'status',
      'booking_status',
      'state',
    ]);
    return status.toLowerCase().contains('confirm');
  }).length;

  int get completedBookings => _bookings.where((item) {
    final status = _readString(item, const [
      'status',
      'booking_status',
      'state',
    ]);
    return status.toLowerCase().contains('complete');
  }).length;

  Future<void> load({bool forceRefresh = false}) async {
    _setBusy(true);
    _error = null;

    try {
      _bookings = await _repository.fetchBookings(forceRefresh: forceRefresh);
      notifyListeners();
    } on DioException catch (error) {
      _error = _message(error);
      _bookings = const <Map<String, dynamic>>[];
      notifyListeners();
    } finally {
      _setBusy(false);
    }
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void setStatusFilter(String value) {
    if (_selectedStatus == value) return;
    _selectedStatus = value;
    notifyListeners();
  }

  void clearFilters() {
    if (_query.isEmpty && _selectedStatus == 'all') return;
    _query = '';
    _selectedStatus = 'all';
    notifyListeners();
  }

  Future<Map<String, dynamic>?> showBooking(Object id) async {
    try {
      return await _repository.showBooking(id);
    } on DioException catch (error) {
      _error = _message(error);
      notifyListeners();
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> createBooking(VendorBookingDraft draft) async {
    _setBusy(true);
    _error = null;

    try {
      final booking = await _repository.createBooking(draft);
      await load(forceRefresh: true);
      return booking;
    } on DioException catch (error) {
      _error = _message(error);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<Map<String, dynamic>?> updateBooking(
    Object id,
    VendorBookingDraft draft,
  ) async {
    _setBusy(true);
    _error = null;

    try {
      final booking = await _repository.updateBooking(id, draft);
      await load(forceRefresh: true);
      return booking;
    } on DioException catch (error) {
      _error = _message(error);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> deleteBooking(Object id) async {
    _setBusy(true);
    _error = null;

    try {
      await _repository.deleteBooking(id);
      await load(forceRefresh: true);
    } on DioException catch (error) {
      _error = _message(error);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  void _setBusy(bool value) {
    if (_busy == value) return;
    _busy = value;
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

  String bookingTitle(Map<String, dynamic> booking) {
    return _readString(booking, const [
      'client_name',
      'customer_name',
      'couple_name',
      'title',
    ]);
  }

  String bookingSubtitle(Map<String, dynamic> booking) {
    return _readString(booking, const [
      'service_name',
      'service',
      'booking_date',
      'date',
    ]);
  }

  String bookingTypeLabel(Map<String, dynamic> booking) {
    return _readString(booking, const [
      'type_service',
      'service_type',
      'category',
    ]);
  }

  String bookingNotes(Map<String, dynamic> booking) {
    return _readString(booking, const ['notes', 'description', 'remark']);
  }

  String bookingStatusLabel(Map<String, dynamic> booking) {
    final status = booking['status'];
    if (status is bool) return status ? 'Confirmed' : 'Pending';
    return _readString(booking, const ['status', 'booking_status', 'state']);
  }

  String _readString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text != 'null') return text;
    }
    return '';
  }
}
