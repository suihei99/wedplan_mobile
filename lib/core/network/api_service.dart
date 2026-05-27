import 'package:dio/dio.dart';
import 'package:wedplan_mobile/core/network/dio_client.dart';
import 'package:wedplan_mobile/core/router/app_router.dart';

class ApiService {
  ApiService({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  Options _options({Options? options, bool requiresAuth = true}) {
    final extra = <String, Object?>{
      ...?options?.extra,
      'requiresAuth': requiresAuth,
    };

    return Options(
      method: options?.method,
      sendTimeout: options?.sendTimeout,
      receiveTimeout: options?.receiveTimeout,
      extra: extra,
      headers: options?.headers,
      responseType: options?.responseType,
      contentType: options?.contentType,
      followRedirects: options?.followRedirects,
      receiveDataWhenStatusError: options?.receiveDataWhenStatusError,
      validateStatus: options?.validateStatus,
      requestEncoder: options?.requestEncoder,
      responseDecoder: options?.responseDecoder,
      listFormat: options?.listFormat,
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: _options(options: options, requiresAuth: requiresAuth),
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _options(options: options, requiresAuth: requiresAuth),
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _options(options: options, requiresAuth: requiresAuth),
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _options(options: options, requiresAuth: requiresAuth),
      cancelToken: cancelToken,
    );
  }

  Future<Response<dynamic>> guestQr(String code) {
    return get<dynamic>(ApiRouter.guestQrByCode(code), requiresAuth: false);
  }

  Future<Response<dynamic>> guestInvitation(String code) {
    return get<dynamic>(
      ApiRouter.guestInvitationByCode(code),
      requiresAuth: false,
    );
  }

  Future<Response<dynamic>> login(dynamic data) {
    return post<dynamic>(ApiRouter.login, data: data, requiresAuth: false);
  }

  Future<Response<dynamic>> registerCouple(dynamic data) {
    return post<dynamic>(
      ApiRouter.registerCouple,
      data: data,
      requiresAuth: false,
    );
  }

  Future<Response<dynamic>> registerVendor(dynamic data) {
    return post<dynamic>(
      ApiRouter.registerVendor,
      data: data,
      requiresAuth: false,
    );
  }

  Future<Response<dynamic>> logout() {
    return post<dynamic>(ApiRouter.logout);
  }

  Future<Response<dynamic>> settings() {
    return get<dynamic>(ApiRouter.settings);
  }

  Future<Response<dynamic>> updateSettings(dynamic data) {
    return put<dynamic>(ApiRouter.settings, data: data);
  }

  Future<Response<dynamic>> vendorDashboard() {
    return get<dynamic>(ApiRouter.vendorDashboard);
  }

  Future<Response<dynamic>> vendorServices() {
    return get<dynamic>(ApiRouter.vendorServices);
  }

  Future<Response<dynamic>> vendorCouples() {
    return get<dynamic>(ApiRouter.vendorCouples);
  }

  Future<Response<dynamic>> vendorServiceCreate(dynamic data) {
    return post<dynamic>(ApiRouter.vendorServices, data: data);
  }

  Future<Response<dynamic>> vendorServiceShow(Object id) {
    return get<dynamic>(ApiRouter.vendorServiceById(id));
  }

  Future<Response<dynamic>> vendorServiceUpdate(Object id, dynamic data) {
    if (data is FormData) {
      final hasMethodField = data.fields.any((field) => field.key == '_method');
      if (!hasMethodField) {
        data.fields.add(const MapEntry('_method', 'PUT'));
      }

      return post<dynamic>(ApiRouter.vendorServiceById(id), data: data);
    }

    return put<dynamic>(ApiRouter.vendorServiceById(id), data: data);
  }

  Future<Response<dynamic>> vendorServiceDelete(Object id) {
    return delete<dynamic>(ApiRouter.vendorServiceById(id));
  }

  Future<Response<dynamic>> vendorBookings() {
    return get<dynamic>(ApiRouter.vendorBookings);
  }

  Future<Response<dynamic>> vendorBookingCreate(Map<String, dynamic> data) {
    return post<dynamic>(ApiRouter.vendorBookings, data: data);
  }

  Future<Response<dynamic>> vendorBookingShow(Object id) {
    return get<dynamic>(ApiRouter.vendorBookingById(id));
  }

  Future<Response<dynamic>> vendorBookingUpdate(
    Object id,
    Map<String, dynamic> data,
  ) {
    return put<dynamic>(ApiRouter.vendorBookingById(id), data: data);
  }

  Future<Response<dynamic>> vendorBookingDelete(Object id) {
    return delete<dynamic>(ApiRouter.vendorBookingById(id));
  }

  Future<Response<dynamic>> vendorNotifications() {
    return get<dynamic>(ApiRouter.vendorNotifications);
  }

  Future<Response<dynamic>> vendorNotificationShow(Object id) {
    return get<dynamic>(ApiRouter.vendorNotificationById(id));
  }

  Future<Response<dynamic>> vendorNotificationMarkAsRead(Object id) {
    return put<dynamic>(ApiRouter.vendorNotificationReadById(id));
  }

  Future<Response<dynamic>> vendorNotificationDelete(Object id) {
    return delete<dynamic>(ApiRouter.vendorNotificationById(id));
  }

  Future<Response<dynamic>> coupleDashboard() {
    return get<dynamic>(ApiRouter.coupleDashboard);
  }

  Future<Response<dynamic>> coupleVendorServices({
    Map<String, dynamic>? queryParameters,
  }) {
    return get<dynamic>(
      ApiRouter.coupleVendors,
      queryParameters: queryParameters,
    );
  }

  Future<Response<dynamic>> coupleVendorServiceShow(Object id) {
    return get<dynamic>(ApiRouter.coupleVendorById(id));
  }

  Future<Response<dynamic>> budgets() {
    return get<dynamic>(ApiRouter.budget);
  }

  Future<Response<dynamic>> budgetCreate(Map<String, dynamic> data) {
    return post<dynamic>(ApiRouter.budget, data: data);
  }

  Future<Response<dynamic>> budgetShow(Object id) {
    return get<dynamic>(ApiRouter.budgetById(id));
  }

  Future<Response<dynamic>> budgetUpdate(Object id, Map<String, dynamic> data) {
    return put<dynamic>(ApiRouter.budgetById(id), data: data);
  }

  Future<Response<dynamic>> budgetDelete(Object id) {
    return delete<dynamic>(ApiRouter.budgetById(id));
  }

  Future<Response<dynamic>> expenses() {
    return get<dynamic>(ApiRouter.expenses);
  }

  Future<Response<dynamic>> expenseCreate(dynamic data) {
    return post<dynamic>(ApiRouter.expenses, data: data);
  }

  Future<Response<dynamic>> expenseCreateWithPath(String path, dynamic data) {
    return post<dynamic>(path, data: data);
  }

  Future<Response<dynamic>> expenseShow(Object id) {
    return get<dynamic>(ApiRouter.expenseById(id));
  }

  Future<Response<dynamic>> expenseUpdate(Object id, dynamic data) {
    return put<dynamic>(ApiRouter.expenseById(id), data: data);
  }

  Future<Response<dynamic>> expenseDelete(Object id) {
    return delete<dynamic>(ApiRouter.expenseById(id));
  }

  Future<Response<dynamic>> guests() {
    return get<dynamic>(ApiRouter.guests);
  }

  Future<Response<dynamic>> guestCreate(Map<String, dynamic> data) {
    return post<dynamic>(ApiRouter.guests, data: data);
  }

  Future<Response<dynamic>> guestShow(Object id) {
    return get<dynamic>(ApiRouter.guestById(id));
  }

  Future<Response<dynamic>> guestUpdate(Object id, Map<String, dynamic> data) {
    return put<dynamic>(ApiRouter.guestById(id), data: data);
  }

  Future<Response<dynamic>> guestUpdateRsvp(
    Object id,
    Map<String, dynamic> data,
  ) {
    return put<dynamic>(ApiRouter.guestRsvpById(id), data: data);
  }

  Future<Response<dynamic>> guestPublicUpdateRsvp(
    String code,
    Map<String, dynamic> data,
  ) {
    return put<dynamic>(
      ApiRouter.guestPublicRsvpByCode(code),
      data: data,
      requiresAuth: false,
    );
  }

  Future<Response<dynamic>> guestPublicCheckIn(
    String code,
    Map<String, dynamic> data,
  ) {
    return post<dynamic>(
      ApiRouter.guestPublicCheckInByCode(code),
      data: data,
      requiresAuth: false,
    );
  }

  Future<Response<dynamic>> guestCheckIn(Object id, Map<String, dynamic> data) {
    return post<dynamic>(
      ApiRouter.guestCheckInById(id),
      data: data,
      requiresAuth: true,
    );
  }

  Future<Response<dynamic>> guestDelete(Object id) {
    return delete<dynamic>(ApiRouter.guestById(id));
  }

  Future<Response<dynamic>> tasks() {
    return get<dynamic>(ApiRouter.tasks);
  }

  Future<Response<dynamic>> taskCreate(Map<String, dynamic> data) {
    return post<dynamic>(ApiRouter.tasks, data: data);
  }

  Future<Response<dynamic>> taskShow(Object id) {
    return get<dynamic>(ApiRouter.taskById(id));
  }

  Future<Response<dynamic>> taskUpdate(Object id, Map<String, dynamic> data) {
    return put<dynamic>(ApiRouter.taskById(id), data: data);
  }

  Future<Response<dynamic>> taskComplete(Object id, Map<String, dynamic> data) {
    return put<dynamic>(ApiRouter.taskCompleteById(id), data: data);
  }

  Future<Response<dynamic>> taskDelete(Object id) {
    return delete<dynamic>(ApiRouter.taskById(id));
  }
}
