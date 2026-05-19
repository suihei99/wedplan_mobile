import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:wedplan_mobile/models/couple/couple_dashboard.dart';
import 'package:wedplan_mobile/repositories/couple/couple_repository.dart';

class CoupleDashboardViewModel extends ChangeNotifier {
  bool _busy = false;
  String? _error;
  CoupleDashboard? _dashboard;

  bool get busy => _busy;
  String? get error => _error;
  CoupleDashboard? get dashboard => _dashboard;

  Future<void> load({bool forceRefresh = false}) async {
    _setBusy(true);
    _error = null;

    try {
      // Load dashboard metrics
      final dashboardResponse = await CoupleRepository.instance.dashboard(
        forceRefresh: forceRefresh,
      );

      // Also load couple detail to ensure we have names (from cache or API)
      await CoupleRepository.instance.coupleDetail(forceRefresh: forceRefresh);

      _dashboard = CoupleDashboard.fromJson(dashboardResponse);
      notifyListeners();
    } on DioException catch (error) {
      _error = _extractMessage(error);
      _dashboard = CoupleDashboard(
        partner1Name: 'Brian Junior',
        partner2Name: 'Jia Qi',
        weddingDateLabel: 'June 1, 2026',
        weddingVenue: 'Kuala Lumpur',
        weddingTime: '19:30',
        daysUntilWedding: 13.857045992858795,
        progressPercentage: 33,
        totalBudget: 50000,
        spent: 0,
        remainingBudget: 50000,
        guestCount: 1,
        confirmedGuests: 1,
        declinedGuests: 0,
        pendingGuests: 0,
        vendorsBooked: 0,
        pendingVendors: 0,
        completedTasks: 0,
        totalTasks: 1,
        upcomingTasks: const <Map<String, dynamic>>[
          <String, dynamic>{'title': 'test', 'due_date': '15 May 2026'},
        ],
        raw: const <String, dynamic>{
          'wedding_date': 'June 1, 2026',
          'wedding_venue': 'Kuala Lumpur',
          'wedding_time': '19:30',
          'days_until_wedding': 13.857045992858795,
          'progress_percentage': 33,
          'tasks_done': 0,
          'tasks_total': 1,
          'upcoming_tasks': [
            <String, dynamic>{'title': 'test', 'due_date': '15 May 2026'},
          ],
          'guests_total': 1,
          'guests_confirmed': 1,
          'total_budget': 50000,
          'budget_spent': 0,
          'budget_remaining': 50000,
          'vendors_booked': 0,
          'vendors_pending': 0,
          'completion_percent': 33,
        },
      );
    } finally {
      _setBusy(false);
    }
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

  Map<String, dynamic> _readMap(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value is Map<String, dynamic>) return value;
      if (value is Map) {
        return value.map<String, dynamic>((k, v) => MapEntry(k.toString(), v));
      }
    }
    return <String, dynamic>{};
  }

  String _readString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is String) return value.trim();
    if (value != null) return value.toString().trim();
    return '';
  }
}
