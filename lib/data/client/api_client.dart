import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiClient {

  ApiClient({String? baseUrl})
      : _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl ?? 'https://adryd-backend.onrender.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  ) {
    _addInterceptors();
  }
  final Dio _dio;

  Dio get client => _dio;

  void _addInterceptors() {
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
      ),
    );

    // REQUEST INTERCEPTOR
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final skipAuth = options.extra['skipAuth'] == true;

          if (!skipAuth) {
            try {
              // Check if Supabase is initialized before accessing
              if (Supabase.instance.client.auth.currentSession != null) {
                final session = Supabase.instance.client.auth.currentSession;
                final token = session?.accessToken;

                if (token != null) {
                  options.headers['Authorization'] = 'Bearer $token';
                }
              }
            } catch (_) {
              // Not crying over session errors
            }
          }

          handler.next(options);
        },
      ),
    );

    // RESPONSE INTERCEPTOR (HANDLE 401 + REFRESH)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, handler) async {
          final response = error.response;
          final request = error.requestOptions;

          final skipAuth = request.extra['skipAuth'] == true;

          // skip refresh logic
          if (skipAuth) return handler.next(error);

          // Only retry once
          if (response?.statusCode == 401 &&
              request.extra['_retry'] != true) {
            request.extra['_retry'] = true;

            try {
              final supabase = Supabase.instance.client;

              final currentUser = supabase.auth.currentUser;
              if (currentUser == null) {
                return handler.next(error);
              }

              final refreshed = await supabase.auth.refreshSession();

              final newToken = refreshed.session?.accessToken;
              if (newToken == null) {
                return handler.next(error);
              }

              // Update request with new token
              request.headers['Authorization'] = 'Bearer $newToken';

              // Retry original request
              final result = await _dio.fetch<dynamic>(request);
              return handler.resolve(result);
            } catch (_) {
              return handler.next(error);
            }
          }

          handler.next(error);
        },
      ),
    );
  }
}
