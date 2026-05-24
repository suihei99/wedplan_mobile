import 'package:wedplan_mobile/models/couple/couple_dashboard.dart';

enum CoupleNotificationType { task, guest, budget, vendor, general }

class CoupleNotificationItem {
  CoupleNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAtLabel,
    required this.isRead,
    required this.actionLabel,
    required this.raw,
  });

  final String id;
  final String title;
  final String message;
  final CoupleNotificationType type;
  final String createdAtLabel;
  final bool isRead;
  final String actionLabel;
  final Map<String, dynamic> raw;

  CoupleNotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    CoupleNotificationType? type,
    String? createdAtLabel,
    bool? isRead,
    String? actionLabel,
    Map<String, dynamic>? raw,
  }) {
    return CoupleNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAtLabel: createdAtLabel ?? this.createdAtLabel,
      isRead: isRead ?? this.isRead,
      actionLabel: actionLabel ?? this.actionLabel,
      raw: raw ?? this.raw,
    );
  }
}

class CoupleNotificationFeed {
  CoupleNotificationFeed({
    required this.unreadCount,
    required this.items,
  });

  final int unreadCount;
  final List<CoupleNotificationItem> items;

  bool get hasUnread => unreadCount > 0;

  static CoupleNotificationFeed fromDashboard(CoupleDashboard dashboard) {
    final unreadCount = dashboard.unreadNotificationCount;
    final items = _readNotifications(dashboard.raw, unreadCount);
    return CoupleNotificationFeed(unreadCount: unreadCount, items: items);
  }
}

List<CoupleNotificationItem> _readNotifications(
  Map<String, dynamic> raw,
  int unreadCount,
) {
  final notifications = _readList(raw, [
    'notifications',
    'notification',
    'couple_notifications',
    'items',
  ]);

  return notifications.asMap().entries.map((entry) {
    final index = entry.key;
    final item = entry.value;
    final id = _stringFromMap(item, ['id']);
    final title = _stringFromMap(item, ['title', 'notification_title', 'name']);
    final message = _stringFromMap(item, ['message', 'body', 'description']);
    final createdAt = _stringFromMap(item, ['created_at', 'time', 'date']);
    final readAt = _stringFromMap(item, ['read_at', 'seen_at']);
    final type = _parseType(_stringFromMap(item, ['type', 'category']));

    return CoupleNotificationItem(
      id: id.isNotEmpty ? id : 'notification-$index',
      title: title.isNotEmpty ? title : 'Notification',
      message: message.isNotEmpty
          ? message
          : 'You have a new couple update from the backend.',
      type: type,
      createdAtLabel: createdAt.isNotEmpty ? createdAt : 'Now',
      isRead: readAt.isNotEmpty || index >= unreadCount,
      actionLabel: _actionLabelForType(type),
      raw: item,
    );
  }).toList();
}

List<Map<String, dynamic>> _readList(
  Map<String, dynamic> map,
  List<String> keys,
) {
  for (final key in keys) {
    final value = map[key];
    if (value is List) {
      return value.whereType<Map>().map((entry) {
        return entry.map<String, dynamic>((k, v) => MapEntry(k.toString(), v));
      }).toList();
    }
  }
  return <Map<String, dynamic>>[];
}

CoupleNotificationType _parseType(String value) {
  switch (value.trim().toLowerCase()) {
    case 'task':
    case 'task_reminder':
    case 'tasks':
      return CoupleNotificationType.task;
    case 'guest':
    case 'guests':
      return CoupleNotificationType.guest;
    case 'budget':
      return CoupleNotificationType.budget;
    case 'vendor':
    case 'vendors':
      return CoupleNotificationType.vendor;
    default:
      return CoupleNotificationType.general;
  }
}

String _actionLabelForType(CoupleNotificationType type) {
  return switch (type) {
    CoupleNotificationType.task => 'Open task',
    CoupleNotificationType.guest => 'Review guests',
    CoupleNotificationType.budget => 'Open budget',
    CoupleNotificationType.vendor => 'View vendors',
    CoupleNotificationType.general => 'View update',
  };
}

String _stringFromMap(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    if (value != null) {
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
  }
  return '';
}
