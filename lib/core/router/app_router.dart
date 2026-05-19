class ApiRouter {
  ApiRouter._();

  static const String defaultBaseUrl = 'https://wedplan.projectse.io/api/v1';

  static String baseUrl = defaultBaseUrl;

  static void configure({String? baseUrl}) {
    if (baseUrl != null && baseUrl.trim().isNotEmpty) {
      ApiRouter.baseUrl = baseUrl.trim();
    }
  }

  static const String guestQr = '/guest/qr';
  static String guestQrByCode(String code) => '$guestQr/$code';
  static const String guestInvitation = '/guest/invitation';
  static String guestInvitationByCode(String code) => '$guestInvitation/$code';

  static const String authPrefix = '/auth';
  static const String registerCouple = '$authPrefix/register/couple';
  static const String registerVendor = '$authPrefix/register/vendor';
  static const String login = '$authPrefix/login';
  static const String logout = '$authPrefix/logout';

  static const String settings = '/settings';

  static const String vendorPrefix = '/vendor';
  static const String vendorDashboard = '$vendorPrefix/dashboard';
  static const String vendorServices = '$vendorPrefix/services';
  static String vendorServiceById(Object id) => '$vendorServices/$id';
  static const String vendorBookings = '$vendorPrefix/bookings';
  static String vendorBookingById(Object id) => '$vendorBookings/$id';
  static const String vendorNotifications = '$vendorPrefix/notifications';
  static String vendorNotificationById(Object id) => '$vendorNotifications/$id';
  static String vendorNotificationReadById(Object id) =>
      '$vendorNotifications/$id/read';

  static const String couplePrefix = '/couple';
  static const String coupleDashboard = '$couplePrefix/dashboard';

  static const String budget = '$couplePrefix/budget';
  static String budgetById(Object id) => '$budget/$id';

  static const String expenses = '$couplePrefix/expenses';
  static String expenseById(Object id) => '$expenses/$id';

  static const String guests = '$couplePrefix/guests';
  static String guestById(Object id) => '$guests/$id';
  static String guestRsvpById(Object id) => '$guests/$id/rsvp';
  static String guestCheckInById(Object id) => '$guests/$id/check-in';
  static String guestPublicRsvpByCode(String code) => '/guest/rsvp/$code';
  static String guestPublicCheckInByCode(String code) => '/guest/checkin/$code';

  static const String tasks = '$couplePrefix/tasks';
  static String taskById(Object id) => '$tasks/$id';
  static String taskCompleteById(Object id) => '$tasks/$id/complete';
}
