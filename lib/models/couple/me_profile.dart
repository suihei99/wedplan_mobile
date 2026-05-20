class CoupleMeProfile {
  const CoupleMeProfile({
    required this.email,
    required this.role,
    required this.profilePhotoPath,
    required this.profilePhotoUrl,
    required this.partner1Name,
    required this.partner2Name,
    required this.displayName,
    required this.weddingDate,
    required this.weddingVenue,
    required this.weddingTime,
    required this.totalBudgetLimit,
    required this.spent,
    required this.remainingBudget,
    required this.guestCount,
    required this.confirmedGuests,
    required this.pendingGuests,
    required this.vendorsBooked,
    required this.completedTasks,
    required this.totalTasks,
    required this.daysUntilWedding,
    required this.rawSettings,
    required this.rawCouple,
    required this.rawDashboard,
  });

  final String email;
  final String role;
  final String profilePhotoPath;
  final String profilePhotoUrl;
  final String partner1Name;
  final String partner2Name;
  final String displayName;
  final String weddingDate;
  final String weddingVenue;
  final String weddingTime;
  final double totalBudgetLimit;
  final double spent;
  final double remainingBudget;
  final int guestCount;
  final int confirmedGuests;
  final int pendingGuests;
  final int vendorsBooked;
  final int completedTasks;
  final int totalTasks;
  final double daysUntilWedding;
  final Map<String, dynamic> rawSettings;
  final Map<String, dynamic> rawCouple;
  final Map<String, dynamic> rawDashboard;

  bool get hasProfilePhoto => profilePhotoUrl.isNotEmpty;

  String get initials {
    final names = <String>[
      partner1Name,
      partner2Name,
    ].where((value) => value.trim().isNotEmpty).toList();
    if (names.isNotEmpty) {
      return names.map((name) => name.trim()[0]).take(2).join().toUpperCase();
    }

    if (displayName.isNotEmpty) {
      return displayName.trim()[0].toUpperCase();
    }

    if (email.isNotEmpty) {
      return email.trim()[0].toUpperCase();
    }

    return 'M';
  }

  double get budgetUsagePercent {
    if (totalBudgetLimit <= 0) return 0;
    return ((spent / totalBudgetLimit) * 100).clamp(0.0, 100.0);
  }

  double get suggestedDailyBudget {
    final remainingDays = daysUntilWedding > 0 ? daysUntilWedding : 30;
    if (remainingBudget > 0) {
      return remainingBudget / remainingDays;
    }
    if (totalBudgetLimit > 0) {
      return totalBudgetLimit / remainingDays;
    }
    return 0;
  }

  String get budgetHealthLabel {
    if (budgetUsagePercent >= 90) return 'Tight budget';
    if (budgetUsagePercent >= 70) return 'Watch spending';
    if (budgetUsagePercent >= 40) return 'Healthy pace';
    return 'Room to plan';
  }

  String get weddingSummary {
    final parts = <String>[
      if (weddingDate.isNotEmpty) weddingDate,
      if (weddingVenue.isNotEmpty) weddingVenue,
      if (weddingTime.isNotEmpty) weddingTime,
    ];
    return parts.join(' • ');
  }

  factory CoupleMeProfile.fromMaps({
    required Map<String, dynamic> settings,
    required Map<String, dynamic> couple,
    required Map<String, dynamic> dashboard,
  }) {
    final settingsData = _readMap(settings, const ['data']);
    final selectedProfile = _readMap(settingsData, const ['user', 'profile']);
    final coupleData = _unwrapCouple(couple);
    final dashboardData = _readMap(dashboard, const ['data']);

    final profile = selectedProfile.isNotEmpty ? selectedProfile : settingsData;

    final partner1Name = _firstString([
      profile['partner_1_name'],
      profile['partner1_name'],
      coupleData['partner_1_name'],
      coupleData['partner1_name'],
      dashboardData['partner_1_name'],
    ]);
    final partner2Name = _firstString([
      profile['partner_2_name'],
      profile['partner2_name'],
      coupleData['partner_2_name'],
      coupleData['partner2_name'],
      dashboardData['partner_2_name'],
    ]);

    final displayName = _firstString([
      profile['display_name'],
      coupleData['display_name'],
      dashboardData['display_name'],
    ]);

    return CoupleMeProfile(
      email: _firstString([profile['email'], settings['email']]),
      role: _firstString([profile['role'], settings['role']]),
      profilePhotoPath: _firstString([
        profile['profile_photo_path'],
        settings['profile_photo_path'],
      ]),
      profilePhotoUrl: _firstString([
        profile['profile_photo_url'],
        settings['profile_photo_url'],
      ]),
      partner1Name: partner1Name,
      partner2Name: partner2Name,
      displayName: displayName.isNotEmpty
          ? displayName
          : _displayName(partner1Name, partner2Name),
      weddingDate: _firstString([
        coupleData['wedding_date'],
        dashboardData['wedding_date'],
        profile['wedding_date'],
      ]),
      weddingVenue: _firstString([
        coupleData['wedding_venue'],
        dashboardData['wedding_venue'],
        profile['wedding_venue'],
      ]),
      weddingTime: _firstString([
        coupleData['wedding_time'],
        dashboardData['wedding_time'],
        profile['wedding_time'],
      ]),
      totalBudgetLimit: _firstDouble([
        coupleData['total_budget_limit'],
        dashboardData['total_budget'],
        profile['total_budget_limit'],
      ]),
      spent: _firstDouble([
        dashboardData['spent'],
        dashboardData['total_spent'],
        dashboardData['total_expenses'],
      ]),
      remainingBudget: _firstDouble([
        dashboardData['remaining_budget'],
        dashboardData['remaining'],
      ]),
      guestCount: _firstInt([
        dashboardData['guest_count'],
        dashboardData['guests_total'],
      ]),
      confirmedGuests: _firstInt([
        dashboardData['confirmed_guests'],
        dashboardData['guests_confirmed'],
      ]),
      pendingGuests: _firstInt([dashboardData['pending_guests']]),
      vendorsBooked: _firstInt([dashboardData['vendors_booked']]),
      completedTasks: _firstInt([
        dashboardData['completed_tasks'],
        dashboardData['tasks_done'],
      ]),
      totalTasks: _firstInt([
        dashboardData['total_tasks'],
        dashboardData['tasks_total'],
      ]),
      daysUntilWedding: _firstDouble([dashboardData['days_until_wedding']]),
      rawSettings: settingsData.isNotEmpty ? settingsData : settings,
      rawCouple: coupleData,
      rawDashboard: dashboardData,
    );
  }
}

Map<String, dynamic> _readMap(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map<String, dynamic>((k, v) => MapEntry(k.toString(), v));
    }
  }
  return <String, dynamic>{};
}

Map<String, dynamic> _unwrapCouple(Map<String, dynamic> source) {
  final data = _readMap(source, const ['data']);
  if (data.isNotEmpty) {
    final nestedCouple = _readMap(data, const ['couple']);
    if (nestedCouple.isNotEmpty) return nestedCouple;
    return data;
  }

  final nestedCouple = _readMap(source, const ['couple']);
  if (nestedCouple.isNotEmpty) return nestedCouple;

  return source;
}

String _firstString(List<dynamic> values) {
  for (final value in values) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    if (value != null) {
      final text = value.toString().trim();
      if (text.isNotEmpty && text != 'null') {
        return text;
      }
    }
  }
  return '';
}

double _firstDouble(List<dynamic> values) {
  for (final value in values) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
  return 0;
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

String _displayName(String partner1Name, String partner2Name) {
  if (partner1Name.isNotEmpty && partner2Name.isNotEmpty) {
    return '$partner1Name & $partner2Name';
  }
  if (partner1Name.isNotEmpty) return partner1Name;
  if (partner2Name.isNotEmpty) return partner2Name;
  return '';
}
