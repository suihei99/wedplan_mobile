import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:wedplan_mobile/core/router/app_router.dart';
import 'package:wedplan_mobile/core/services/auth_service.dart';

class DioClient {
  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiRouter.baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        responseType: ResponseType.json,
        headers: const <String, Object>{'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.addAll(<Interceptor>[
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final requiresAuth = options.extra['requiresAuth'] != false;

          if (requiresAuth) {
            final token = await AuthService.instance.token;
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await AuthService.instance.clearToken();
          }
          handler.next(error);
        },
      ),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => debugPrint(object.toString()),
      ),
    ]);
  }

  static final DioClient instance = DioClient._internal();

  late final Dio _dio;

  Dio get dio => _dio;

  void setBaseUrl(String baseUrl) {
    ApiRouter.configure(baseUrl: baseUrl);
    _dio.options.baseUrl = ApiRouter.baseUrl;
  }

  Future<void> setAuthToken(String? token) =>
      AuthService.instance.setToken(token);

  Future<void> clearAuthToken() => AuthService.instance.clearToken();
}
