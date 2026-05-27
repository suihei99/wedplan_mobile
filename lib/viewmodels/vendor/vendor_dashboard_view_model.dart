import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:wedplan_mobile/repositories/vendor/vendor_dashboard_repository.dart';

class VendorDashboardViewModel extends ChangeNotifier {
  VendorDashboardViewModel({VendorDashboardRepository? repository})
    : _repository = repository ?? VendorDashboardRepository.instance;

  final VendorDashboardRepository _repository;

  bool _busy = false;
  String? _error;
  Map<String, dynamic> _dashboard = const <String, dynamic>{};

  bool get busy => _busy;
  String? get error => _error;
  Map<String, dynamic> get raw => _dashboard;

  String get businessName => _firstString([
    _dashboard['business_name'],
    _dashboard['company_name'],
    _dashboard['vendor_business_name'],
    _dashboard['display_name'],
    _dashboard['name'],
  ], fallback: 'Vendor Dashboard');

  String get displayName => _firstString([
    _dashboard['display_name'],
    _dashboard['owner_name'],
    _dashboard['contact_name'],
    _dashboard['name'],
  ], fallback: businessName);

  String get initials {
    final source = businessName.isNotEmpty ? businessName : displayName;
    if (source.isEmpty) return 'V';

    final parts = source
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return source[0].toUpperCase();

    return parts.take(2).map((part) => part[0]).join().toUpperCase();
  }

  String get statusLabel => _firstString([
    _dashboard['status'],
    _dashboard['business_status'],
    _dashboard['approval_status'],
  ], fallback: 'Approved');

  String get statusHelper => _firstString([
    _dashboard['status_message'],
    _dashboard['status_note'],
    _dashboard['business_status_note'],
  ], fallback: 'Your business is active and ready for bookings.');

  String get summaryLabel => _firstString(
    [_dashboard['summary'], _dashboard['description'], _dashboard['headline']],
    fallback: 'Track services, bookings, and notifications in one mobile view.',
  );

  int get totalServices => _readInt([
    _dashboard['total_services'],
    _dashboard['services_total'],
    _dashboard['service_count'],
    _readListOfMaps(_dashboard, const ['services', 'featured_services']).length,
  ]);

  int get totalBookings => _readInt([
    _dashboard['total_bookings'],
    _dashboard['bookings_total'],
    _dashboard['booking_count'],
    _readListOfMaps(_dashboard, const ['bookings', 'upcoming_bookings']).length,
  ]);

  int get pendingBookings => _readInt([
    _dashboard['pending_bookings'],
    _dashboard['bookings_pending'],
    _dashboard['pending_count'],
  ]);

  int get unreadNotifications => _readInt([
    _dashboard['unread_notifications'],
    _dashboard['notifications_unread'],
    _dashboard['notification_count'],
    _readListOfMaps(_dashboard, const [
      'notifications',
      'recent_notifications',
    ]).length,
  ]);

  double get profileCompletionPercent => _readDouble([
    _dashboard['profile_completion_percent'],
    _dashboard['completion_percent'],
    _dashboard['progress_percentage'],
  ]);

  List<Map<String, dynamic>> get upcomingBookings => _readListOfMaps(
    _dashboard,
    const ['upcoming_bookings', 'bookings', 'recent_bookings'],
  );

  List<Map<String, dynamic>> get featuredServices => _readListOfMaps(
    _dashboard,
    const ['featured_services', 'services', 'top_services'],
  );

  List<DateTime> get bookingDates => _readDateList([
    _dashboard['booking_dates'],
    _dashboard['upcoming_booking_dates'],
    _dashboard['calendar_dates'],
    for (final item in upcomingBookings) ...[
      item['booking_date'],
      item['date'],
      item['scheduled_at'],
    ],
  ]);

  Future<void> load({bool forceRefresh = false}) async {
    _setBusy(true);
    _error = null;

    try {
      _dashboard = await _repository.loadDashboard(forceRefresh: forceRefresh);
      notifyListeners();
    } on DioException catch (error) {
      _error = _message(error);
      _dashboard = const <String, dynamic>{};
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

  int _readInt(Iterable<dynamic> values) {
    for (final value in values) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null) return parsed;
      }
    }
    return 0;
  }

  double _readDouble(Iterable<dynamic> values, {double fallback = 0}) {
    for (final value in values) {
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value.trim());
        if (parsed != null) return parsed;
      }
    }
    return fallback;
  }

  String _firstString(Iterable<dynamic> values, {String fallback = ''}) {
    for (final value in values) {
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text != 'null') return text;
    }
    return fallback;
  }

  List<Map<String, dynamic>> _readListOfMaps(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value is List) {
        return value
            .whereType<Map>()
            .map(
              (item) => item.map<String, dynamic>(
                (key, value) => MapEntry(key.toString(), value),
              ),
            )
            .toList();
      }
    }
    return const <Map<String, dynamic>>[];
  }

  List<DateTime> _readDateList(Iterable<dynamic> values) {
    final dates = <DateTime>{};

    for (final value in values) {
      if (value == null) continue;

      if (value is List) {
        for (final item in value) {
          final parsed = _parseDate(item);
          if (parsed != null) dates.add(_dateOnly(parsed));
        }
        continue;
      }

      final parsed = _parseDate(value);
      if (parsed != null) dates.add(_dateOnly(parsed));
    }

    final sorted = dates.toList()..sort((a, b) => a.compareTo(b));
    return sorted;
  }

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value == null) return null;

    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return null;

    final parsed = DateTime.tryParse(text);
    if (parsed != null) return parsed;

    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(text);
    if (match != null) {
      return DateTime(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
      );
    }

    return null;
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
