import 'package:wedplan_mobile/models/couple/couple_dashboard.dart';
import 'package:wedplan_mobile/models/couple/notification/notification_item.dart';
import 'package:wedplan_mobile/repositories/couple/couple_repository.dart';

class NotificationRepository {
  NotificationRepository._();

  static final NotificationRepository instance = NotificationRepository._();

  Future<CoupleNotificationFeed> loadFeed({bool forceRefresh = false}) async {
    final dashboardMap = await CoupleRepository.instance.dashboard(
      forceRefresh: forceRefresh,
    );
    return CoupleNotificationFeed.fromDashboard(
      CoupleDashboard.fromJson(dashboardMap),
    );
  }
}
