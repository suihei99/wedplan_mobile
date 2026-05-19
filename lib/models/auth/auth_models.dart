import 'package:dio/dio.dart';

enum AuthMode { login, registerCouple, registerVendor }

typedef WelcomeAuthMode = AuthMode;

class AuthSubmission {
  const AuthSubmission({required this.mode, required this.body});

  final AuthMode mode;
  final Map<String, dynamic> body;
}

typedef WelcomeAuthPayload = AuthSubmission;

String extractAuthErrorMessage(DioException error) {
  final data = error.response?.data;
  if (data is Map<String, dynamic>) {
    final message = data['message'] ?? data['error'];
    if (message is String && message.isNotEmpty) {
      return message;
    }
  }

  if (data is Map) {
    final message = data['message'] ?? data['error'];
    if (message is String && message.isNotEmpty) {
      return message;
    }
  }

  return error.message ?? 'Something went wrong. Please try again.';
}
