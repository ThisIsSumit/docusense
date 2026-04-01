import 'package:dio/dio.dart';
import 'package:docusense/core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../theme/app_theme.dart';

part 'dio_client.g.dart';

// ── Token storage ─────────────────────────────────────────────────────────────

@riverpod
FlutterSecureStorage tokenStorage(TokenStorageRef ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
}

// ── Authenticated Dio ─────────────────────────────────────────────────────────

@riverpod
Dio dioClient(DioClientRef ref) {
  final storage = ref.read(tokenStorageProvider);

  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: AppConstants.connectTimeout,
    receiveTimeout: AppConstants.receiveTimeout,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  dio.interceptors.add(_AuthInterceptor(dio: dio, storage: storage));

  if (AppConstants.baseUrl.contains('localhost')) {
    dio.interceptors.add(LogInterceptor(
      requestBody: false, responseBody: false,
      requestHeader: false, responseHeader: false,
      // ignore: avoid_print
      logPrint: (o) => print('[Dio] $o'),
    ));
  }

  return dio;
}

// ── Auth interceptor: inject + rotate ────────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  final Dio dio;
  final FlutterSecureStorage storage;
  bool _refreshing = false;
  final _queue = <({RequestOptions opts, ErrorInterceptorHandler handler})>[];

  _AuthInterceptor({required this.dio, required this.storage});

  @override
  Future<void> onRequest(
    RequestOptions options, RequestInterceptorHandler handler) async {
    final skip = options.path.contains('/auth/login')
        || options.path.contains('/auth/register')
        || options.path.contains('/auth/refresh');
    if (!skip) {
      final token = await storage.read(key: AppConstants.accessTokenKey);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401
        || err.requestOptions.path.contains('/auth/refresh')) {
      handler.next(err); return;
    }
    if (_refreshing) {
      _queue.add((opts: err.requestOptions, handler: handler)); return;
    }
    _refreshing = true;
    try {
      final rt = await storage.read(key: AppConstants.refreshTokenKey);
      if (rt == null) throw Exception('no_refresh_token');

      final res = await Dio(BaseOptions(baseUrl: AppConstants.baseUrl))
          .post('/auth/refresh', data: {'refreshToken': rt});
      final d = res.data['data'] as Map<String, dynamic>;
      final at = d['accessToken'] as String;
      final newRt = d['refreshToken'] as String;

      await Future.wait([
        storage.write(key: AppConstants.accessTokenKey, value: at),
        storage.write(key: AppConstants.refreshTokenKey, value: newRt),
      ]);

      err.requestOptions.headers['Authorization'] = 'Bearer $at';
      handler.resolve(await dio.fetch(err.requestOptions));

      for (final p in _queue) {
        p.opts.headers['Authorization'] = 'Bearer $at';
        try { p.handler.resolve(await dio.fetch(p.opts)); }
        catch (_) { p.handler.next(err); }
      }
    } catch (_) {
      await storage.delete(key: AppConstants.accessTokenKey);
      await storage.delete(key: AppConstants.refreshTokenKey);
      handler.next(err);
      for (final p in _queue) p.handler.next(err);
    } finally {
      _queue.clear();
      _refreshing = false;
    }
  }
}

// ── ApiException ──────────────────────────────────────────────────────────────

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final String? code;
  final dynamic details;

  const ApiException({
    this.statusCode, required this.message, this.code, this.details,
  });

  factory ApiException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(message: 'Connection timed out', code: 'TIMEOUT');
      case DioExceptionType.connectionError:
        return const ApiException(message: 'Cannot reach server', code: 'OFFLINE');
      case DioExceptionType.badResponse:
        final s = e.response?.statusCode;
        final b = e.response?.data;
        final msg = (b is Map) ? (b['error']?['message'] as String? ?? 'Server error') : 'Server error';
        final code = (b is Map) ? (b['error']?['code'] as String?) : null;
        return ApiException(
          statusCode: s,
          message: msg,
          code: code,
          details: (b is Map) ? b['error']?['details'] : null: null,
        );
      default:
        return ApiException(message: e.message ?? 'Unknown error', code: 'UNKNOWN');
    }
  }

  bool get isUnauthorized  => statusCode == 401;
  bool get isForbidden     => statusCode == 403;
  bool get isNotFound      => statusCode == 404;
  bool get isConflict      => statusCode == 409;
  bool get isServerError   => (statusCode ?? 0) >= 500;

  @override
  String toString() => 'ApiException($statusCode/$code): $message';
}
