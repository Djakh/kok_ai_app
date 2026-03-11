import 'package:dio/dio.dart';
import 'package:kok_ai_app/core/network/api_config.dart';
import 'package:kok_ai_app/core/network/api_exception.dart';
import 'package:kok_ai_app/core/network/auth_token_store.dart';

class ApiClient {
  ApiClient({required this.tokenStore})
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: {'Accept': 'application/json'},
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStore.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio dio;
  final AuthTokenStore tokenStore;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return envelopeData(response.data);
    } on DioException catch (error) {
      throw mapDioError(error);
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: body,
        options: Options(headers: headers),
        queryParameters: queryParameters,
      );
      return envelopeData(response.data);
    } on DioException catch (error) {
      throw mapDioError(error);
    }
  }

  Future<dynamic> patch(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.patch(
        path,
        data: body,
        options: Options(headers: headers),
        queryParameters: queryParameters,
      );
      return envelopeData(response.data);
    } on DioException catch (error) {
      throw mapDioError(error);
    }
  }

  dynamic envelopeData(dynamic raw) {
    if (raw is Map<String, dynamic> && raw.containsKey('success')) {
      final success = raw['success'] == true;
      if (success) return raw['data'];
      final error = raw['error'] as Map<String, dynamic>?;
      throw ApiException(
        code: '${error?['code'] ?? 'unknown_error'}',
        message: '${error?['message'] ?? 'Unexpected API error'}',
        details: error?['details'],
      );
    }
    return raw;
  }

  ApiException mapDioError(DioException error) {
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      try {
        envelopeData(responseData);
      } catch (exception) {
        if (exception is ApiException) return exception;
      }
    }
    return ApiException(
      code: 'network_error',
      message: error.message ?? 'Network error',
      details: responseData,
    );
  }
}
