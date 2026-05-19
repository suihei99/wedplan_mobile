import 'package:intl/intl.dart';

class CoupleDashboard {
  CoupleDashboard({
    required this.partner1Name,
    required this.partner2Name,
    required this.weddingDateLabel,
    required this.weddingVenue,
    required this.weddingTime,
    required this.daysUntilWedding,
    required this.progressPercentage,
    required this.totalBudget,
    required this.spent,
    required this.remainingBudget,
    required this.guestCount,
    required this.confirmedGuests,
    required this.declinedGuests,
    required this.pendingGuests,
    required this.vendorsBooked,
    required this.pendingVendors,
    required this.completedTasks,
    required this.totalTasks,
    required this.upcomingTasks,
    required this.raw,
  });

  final String partner1Name;
  final String partner2Name;
  final String weddingDateLabel;
  final String weddingVenue;
  final String weddingTime;
  final double daysUntilWedding;
  final double progressPercentage;
  final double totalBudget;
  final double spent;
  final double remainingBudget;
  final int guestCount;
  final int confirmedGuests;
  final int declinedGuests;
  final int pendingGuests;
  final int vendorsBooked;
  final int pendingVendors;
  final int completedTasks;
  final int totalTasks;
  final List<Map<String, dynamic>> upcomingTasks;
  final Map<String, dynamic> raw;

  String get coupleDisplayName {
    final p1 = partner1Name.trim();
    final p2 = partner2Name.trim();
    if (p1.isNotEmpty && p2.isNotEmpty) return '$p1 & $p2';
    if (p1.isNotEmpty) return p1;
    if (p2.isNotEmpty) return p2;
    return '';
  }

  double get budgetRemaining => remainingBudget;

  DateTime? get weddingDateOnly => _parseWeddingDateOnly(
        raw['wedding_date'] ?? raw['wedding_date_label'] ?? weddingDateLabel,
      );

  double get completionPercent {
    final fromApi = _firstDoubleFromMap(raw, [
      'completion_percent',
      'completion_percentage',
      'progress_percentage',
      'progress_percent',
    ]);
    if (fromApi > 0) return fromApi.clamp(0.0, 100.0);

    if (progressPercentage > 0) {
      return progressPercentage.clamp(0.0, 100.0);
    }

    final budgetProgress = totalBudget > 0 ? spent / totalBudget : 0.0;
    final guestProgress = guestCount > 0 ? confirmedGuests / guestCount : 0.0;
    final taskProgress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    final vendorTotal = pendingVendors + vendorsBooked;
    final vendorProgress = vendorTotal > 0 ? vendorsBooked / vendorTotal : 0.0;

    final value =
        [
          budgetProgress,
          guestProgress,
          taskProgress,
          vendorProgress,
        ].reduce((a, b) => a + b) /
        4;
    return (value.clamp(0.0, 1.0)) * 100;
  }

  factory CoupleDashboard.fromJson(Map<String, dynamic> json) {
    final data = _readMap(json, ['data']);
    final dashboard = _readMap(json, ['dashboard']);
    final summary = _readMap(data, ['summary']);
    final stats = _readMap(data, ['stats']);
    final couple = _readMap(data, ['couple', 'profile']);
    final wedding = _readMap(data, ['wedding']);
    final budget = _readMap(data, ['budget']);
    final guestsSummary = _readMap(data, ['guests_summary']);

    return CoupleDashboard(
      partner1Name: _firstString([
        data['partner_1_name'],
        data['partner1_name'],
        dashboard['partner_1_name'],
        summary['partner_1_name'],
        couple['partner_1_name'],
        couple['partner1_name'],
        wedding['partner_1_name'],
      ]),
      partner2Name: _firstString([
        data['partner_2_name'],
        data['partner2_name'],
        dashboard['partner_2_name'],
        summary['partner_2_name'],
        couple['partner_2_name'],
        couple['partner2_name'],
        wedding['partner_2_name'],
      ]),
      weddingDateLabel: _firstString([
        data['wedding_date'],
        data['wedding_date_label'],
        dashboard['wedding_date'],
        summary['wedding_date'],
        wedding['date'],
      ], fallback: 'Wedding Dashboard'),
      weddingVenue: _firstString([
        data['wedding_venue'],
        data['venue'],
        dashboard['wedding_venue'],
        summary['wedding_venue'],
        wedding['venue'],
      ]),
      weddingTime: _firstString([
        data['wedding_time'],
        data['time'],
        dashboard['wedding_time'],
        summary['wedding_time'],
        wedding['time'],
      ]),
      daysUntilWedding: (() {
        final val = _firstDouble([
          data['days_until_wedding'],
          dashboard['days_until_wedding'],
          summary['days_until_wedding'],
        ]);
        if (val > 0) return val;

        // fallback: try to parse wedding date strings and compute remaining days
        final dateCandidates = [
          data['wedding_date'],
          data['wedding_date_label'],
          dashboard['wedding_date'],
          summary['wedding_date'],
          wedding['date'],
        ];
        String pick = '';
        for (final c in dateCandidates) {
          if (c is String && c.trim().isNotEmpty) {
            pick = c.trim();
            break;
          }
        }

        if (pick.isNotEmpty) {
          try {
            DateTime? parsed = DateTime.tryParse(pick);
            if (parsed == null) {
              // try common human-friendly formats
              final formats = [
                DateFormat('MMMM d, y'),
                DateFormat('d MMMM y'),
                DateFormat('y-MM-dd'),
              ];
              for (final f in formats) {
                try {
                  parsed = f.parse(pick);
                  if (parsed != null) break;
                } catch (_) {}
              }
            }
            if (parsed != null) {
              // Use calendar-day difference only so the countdown ignores the
              // current time of day and follows the wedding date itself.
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final weddingDay = DateTime(
                parsed.year,
                parsed.month,
                parsed.day,
              );
              final diffDays = weddingDay.difference(today).inDays;
              return diffDays > 0 ? diffDays.toDouble() : 0.0;
            }
          } catch (_) {}
        }

        return 0.0;
      }()),
      progressPercentage: _firstDouble([
        data['progress_percentage'],
        data['progress'],
        dashboard['progress_percentage'],
        summary['progress_percentage'],
      ]),
      totalBudget: _firstDouble([
        data['total_budget'],
        data['total_budget_limit'],
        data['budget_limit'],
        data['budget_total'],
        summary['total_budget'],
        summary['budget_limit'],
        dashboard['total_budget'],
        dashboard['budget_limit'],
        wedding['total_budget_limit'],
        budget['total_budget_limit'],
        budget['effective_budget_limit'],
      ]),
      spent: _firstDouble([
        data['spent'],
        data['total_spent'],
        data['budget_spent'],
        data['spent_amount'],
        data['total_expenses'],
        summary['spent'],
        summary['spent_amount'],
        dashboard['spent'],
        dashboard['total_expenses'],
        budget['total_spent'],
      ]),
      remainingBudget: _firstDouble([
        data['remaining'],
        data['remaining_budget'],
        data['budget_remaining'],
        summary['remaining'],
        dashboard['remaining'],
        dashboard['remaining_budget'],
        budget['remaining'],
        budget['remaining_budget'],
      ]),
      guestCount: _firstInt([
        data['guest_count'],
        data['guests'],
        data['guest_total'],
        data['guests_total'],
        summary['guest_count'],
        summary['guests'],
        stats['guest_count'],
        dashboard['guest_count'],
        guestsSummary['total_guests'],
      ]),
      confirmedGuests: _firstInt([
        data['confirmed_guests'],
        data['guests_confirmed'],
        data['confirmed_guest_count'],
        data['rsvp_confirmed'],
        summary['confirmed_guests'],
        summary['guests_confirmed'],
        stats['confirmed_guests'],
        dashboard['confirmed_guests'],
        dashboard['rsvp_confirmed'],
        guestsSummary['confirmed_guests'],
      ]),
      declinedGuests: _firstInt([
        data['declined_guests'],
        guestsSummary['declined_guests'],
      ]),
      pendingGuests: _firstInt([
        data['pending_guests'],
        guestsSummary['pending_guests'],
      ]),
      vendorsBooked: _firstInt([
        data['vendors_booked'],
        dashboard['vendors_booked'],
        stats['vendors_booked'],
      ]),
      pendingVendors: _firstInt([
        data['pending_vendors'],
        data['vendors_pending'],
        data['vendor_pending'],
        summary['pending_vendors'],
        summary['vendors_pending'],
        stats['pending_vendors'],
        dashboard['pending_vendors'],
        budget['vendors_pending'],
      ]),
      completedTasks: _firstInt([
        data['completed_tasks'],
        data['tasks_completed'],
        data['task_completed'],
        data['tasks_done'],
        summary['completed_tasks'],
        summary['tasks_completed'],
        stats['completed_tasks'],
        dashboard['completed_tasks'],
      ]),
      totalTasks: _firstInt([
        data['total_tasks'],
        data['tasks_total'],
        data['task_total'],
        data['tasks_count'],
        summary['total_tasks'],
        summary['tasks_total'],
        stats['total_tasks'],
        dashboard['total_tasks'],
      ]),
      upcomingTasks: _readList(data, ['upcoming_tasks']),
      raw: json,
    );
  }

  CoupleDashboard copyWith({
    String? partner1Name,
    String? partner2Name,
    String? weddingDateLabel,
    String? weddingVenue,
    String? weddingTime,
    double? daysUntilWedding,
    double? progressPercentage,
    double? totalBudget,
    double? spent,
    double? remainingBudget,
    int? guestCount,
    int? confirmedGuests,
    int? declinedGuests,
    int? pendingGuests,
    int? vendorsBooked,
    int? pendingVendors,
    int? completedTasks,
    int? totalTasks,
    List<Map<String, dynamic>>? upcomingTasks,
    Map<String, dynamic>? raw,
  }) {
    return CoupleDashboard(
      partner1Name: partner1Name ?? this.partner1Name,
      partner2Name: partner2Name ?? this.partner2Name,
      weddingDateLabel: weddingDateLabel ?? this.weddingDateLabel,
      weddingVenue: weddingVenue ?? this.weddingVenue,
      weddingTime: weddingTime ?? this.weddingTime,
      daysUntilWedding: daysUntilWedding ?? this.daysUntilWedding,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      totalBudget: totalBudget ?? this.totalBudget,
      spent: spent ?? this.spent,
      remainingBudget: remainingBudget ?? this.remainingBudget,
      guestCount: guestCount ?? this.guestCount,
      confirmedGuests: confirmedGuests ?? this.confirmedGuests,
      declinedGuests: declinedGuests ?? this.declinedGuests,
      pendingGuests: pendingGuests ?? this.pendingGuests,
      vendorsBooked: vendorsBooked ?? this.vendorsBooked,
      pendingVendors: pendingVendors ?? this.pendingVendors,
      completedTasks: completedTasks ?? this.completedTasks,
      totalTasks: totalTasks ?? this.totalTasks,
      upcomingTasks: upcomingTasks ?? this.upcomingTasks,
      raw: raw ?? this.raw,
    );
  }
}

Map<String, dynamic> _readMap(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map<String, dynamic>((k, v) => MapEntry(k.toString(), v));
    }
  }
  return <String, dynamic>{};
}

double _firstDouble(List<dynamic> values) {
  for (final value in values) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
  return 0.0;
}

int _firstInt(List<dynamic> values) {
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

String _firstString(List<dynamic> values, {String fallback = ''}) {
  for (final value in values) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }
  return fallback;
}

double _firstDoubleFromMap(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
  return 0.0;
}

List<Map<String, dynamic>> _readList(
  Map<String, dynamic> map,
  List<String> keys,
) {
  for (final key in keys) {
    final value = map[key];
    if (value is List) {
      return value
          .whereType<Map>()
          .map(
            (item) =>
                item.map<String, dynamic>((k, v) => MapEntry(k.toString(), v)),
          )
          .toList();
    }
  }
  return <Map<String, dynamic>>[];
}

DateTime? _parseWeddingDateOnly(dynamic value) {
  if (value == null) return null;

  final text = value.toString().trim();
  if (text.isEmpty) return null;

  // ISO date or ISO datetime: keep only the calendar date portion.
  if (text.contains('T')) {
    final datePart = text.split('T').first;
    final parts = datePart.split('-');
    if (parts.length == 3) {
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);
      if (year != null && month != null && day != null) {
        return DateTime(year, month, day);
      }
    }
  }

  final isoDate = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text);
  if (isoDate != null) {
    return DateTime(
      int.parse(isoDate.group(1)!),
      int.parse(isoDate.group(2)!),
      int.parse(isoDate.group(3)!),
    );
  }

  for (final format in [
    DateFormat('MMMM d, y'),
    DateFormat('d MMMM y'),
    DateFormat('y-MM-dd'),
  ]) {
    try {
      final parsed = format.parse(text);
      return DateTime(parsed.year, parsed.month, parsed.day);
    } catch (_) {}
  }

  final parsed = DateTime.tryParse(text);
  if (parsed != null) {
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  return null;
}
