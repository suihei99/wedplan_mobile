import 'package:flutter/foundation.dart';

import 'package:wedplan_mobile/models/couple/notification/notification_item.dart';
import 'package:wedplan_mobile/repositories/couple/notification_repository.dart';

enum NotificationFilterType {
  all,
  unread,
  task,
  guest,
  budget,
  vendor,
  general,
}

class NotificationViewModel extends ChangeNotifier {
  bool _busy = false;
  String? _error;
  CoupleNotificationFeed? _feed;
  NotificationFilterType _filter = NotificationFilterType.all;
  String _searchQuery = '';

  bool get busy => _busy;
  String? get error => _error;
  CoupleNotificationFeed? get feed => _feed;
  NotificationFilterType get filter => _filter;
  String get searchQuery => _searchQuery;

  List<CoupleNotificationItem> get items => _filteredItems();

  int get unreadCount => _feed?.unreadCount ?? 0;

  int get totalCount => _feed?.items.length ?? 0;

  int get taskCount =>
      _feed?.items
          .where((item) => item.type == CoupleNotificationType.task)
          .length ??
      0;

  int get guestCount =>
      _feed?.items
          .where((item) => item.type == CoupleNotificationType.guest)
          .length ??
      0;

  int get vendorCount =>
      _feed?.items
          .where((item) => item.type == CoupleNotificationType.vendor)
          .length ??
      0;

  int get budgetCount =>
      _feed?.items
          .where((item) => item.type == CoupleNotificationType.budget)
          .length ??
      0;

  Future<void> load({bool forceRefresh = false}) async {
    _setBusy(true);
    _error = null;

    try {
      _feed = await NotificationRepository.instance.loadFeed(
        forceRefresh: forceRefresh,
      );
      notifyListeners();
    } catch (error) {
      _error = error.toString();
      notifyListeners();
    } finally {
      _setBusy(false);
    }
  }

  void updateFilter(NotificationFilterType value) {
    if (_filter == value) return;
    _filter = value;
    notifyListeners();
  }

  void updateSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void markAsRead(String id) {
    final feed = _feed;
    if (feed == null) return;

    final updatedItems = feed.items.map((item) {
      if (item.id != id) return item;
      return item.copyWith(isRead: true);
    }).toList();

    _feed = CoupleNotificationFeed(
      unreadCount: updatedItems.where((item) => !item.isRead).length,
      items: updatedItems,
    );
    notifyListeners();
  }

  void markAllAsRead() {
    final feed = _feed;
    if (feed == null) return;

    _feed = CoupleNotificationFeed(
      unreadCount: 0,
      items: feed.items.map((item) => item.copyWith(isRead: true)).toList(),
    );
    notifyListeners();
  }

  void removeItem(String id) {
    final feed = _feed;
    if (feed == null) return;

    final updatedItems = feed.items.where((item) => item.id != id).toList();
    _feed = CoupleNotificationFeed(
      unreadCount: updatedItems.where((item) => !item.isRead).length,
      items: updatedItems,
    );
    notifyListeners();
  }

  CoupleNotificationItem? itemById(String id) {
    final feed = _feed;
    if (feed == null) return null;
    for (final item in feed.items) {
      if (item.id == id) return item;
    }
    return null;
  }

  List<CoupleNotificationItem> _filteredItems() {
    final feed = _feed;
    if (feed == null) return const <CoupleNotificationItem>[];

    final query = _searchQuery.trim().toLowerCase();
    return feed.items.where((item) {
      final matchesSearch =
          query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.message.toLowerCase().contains(query) ||
          item.createdAtLabel.toLowerCase().contains(query);

      final matchesFilter = switch (_filter) {
        NotificationFilterType.all => true,
        NotificationFilterType.unread => !item.isRead,
        NotificationFilterType.task => item.type == CoupleNotificationType.task,
        NotificationFilterType.guest =>
          item.type == CoupleNotificationType.guest,
        NotificationFilterType.budget =>
          item.type == CoupleNotificationType.budget,
        NotificationFilterType.vendor =>
          item.type == CoupleNotificationType.vendor,
        NotificationFilterType.general =>
          item.type == CoupleNotificationType.general,
      };

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _setBusy(bool value) {
    if (_busy == value) return;
    _busy = value;
    notifyListeners();
  }
}
