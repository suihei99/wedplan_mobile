import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:wedplan_mobile/repositories/vendor/vendor_notification_repository.dart';

class VendorNotificationViewModel extends ChangeNotifier {
  VendorNotificationViewModel({VendorNotificationRepository? repository})
    : _repository = repository ?? VendorNotificationRepository.instance;

  final VendorNotificationRepository _repository;

  bool _busy = false;
  String? _error;
  List<Map<String, dynamic>> _notifications = const <Map<String, dynamic>>[];

  bool get busy => _busy;
  String? get error => _error;
  List<Map<String, dynamic>> get notifications => _notifications;

  int get unreadCount => _notifications.where((item) {
    return !_isRead(item);
  }).length;

  Future<void> load({bool forceRefresh = false}) async {
    _setBusy(true);
    _error = null;

    try {
      _notifications = await _repository.fetchNotifications(
        forceRefresh: forceRefresh,
      );
      notifyListeners();
    } on DioException catch (error) {
      _error = _message(error);
      _notifications = const <Map<String, dynamic>>[];
      notifyListeners();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> markAsRead(Map<String, dynamic> item) async {
    final id = item['id'];
    if (id == null) return;

    try {
      await _repository.markAsRead(id);
      _notifications = _notifications.map((notification) {
        if (notification['id'] != id) return notification;
        return <String, dynamic>{
          ...notification,
          'read_at':
              notification['read_at'] ?? DateTime.now().toIso8601String(),
        };
      }).toList();
      notifyListeners();
    } on DioException catch (error) {
      _error = _message(error);
      notifyListeners();
    }
  }

  Future<void> removeNotification(Map<String, dynamic> item) async {
    final id = item['id'];
    if (id == null) return;

    try {
      await _repository.deleteNotification(id);
      _notifications = _notifications
          .where((notification) => notification['id'] != id)
          .toList();
      notifyListeners();
    } on DioException catch (error) {
      _error = _message(error);
      notifyListeners();
    }
  }

  bool _isRead(Map<String, dynamic> item) {
    final readAt = item['read_at'];
    if (readAt == null) return false;
    final text = readAt.toString().trim();
    return text.isNotEmpty && text != 'null';
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
}
