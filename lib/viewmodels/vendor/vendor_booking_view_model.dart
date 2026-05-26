import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:wedplan_mobile/repositories/vendor/vendor_booking_repository.dart';

class VendorBookingViewModel extends ChangeNotifier {
  VendorBookingViewModel({VendorBookingRepository? repository})
    : _repository = repository ?? VendorBookingRepository.instance;

  final VendorBookingRepository _repository;

  bool _busy = false;
  String? _error;
  List<Map<String, dynamic>> _bookings = const <Map<String, dynamic>>[];

  bool get busy => _busy;
  String? get error => _error;
  List<Map<String, dynamic>> get bookings => _bookings;

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
