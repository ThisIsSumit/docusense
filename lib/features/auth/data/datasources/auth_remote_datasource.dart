import 'package:dio/dio.dart';
import 'package:docusense/core/utils/dio_client.dart';
import 'package:docusense/features/auth/data/models/auth_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_remote_datasource.g.dart';

@riverpod
AuthRemoteDatasource authRemoteDatasource(Ref ref) {
  return AuthRemoteDatasource(dio: ref.watch(dioClientProvider));
}

class AuthRemoteDatasource {
  final Dio _dio;
  AuthRemoteDatasource({required Dio dio}) : _dio = dio;

  Map<String, dynamic> _asMap(dynamic value,
      {String error = 'Invalid auth response'}) {
    if (value is Map) return Map<String, dynamic>.from(value);
    throw FormatException(error);
  }

  Map<String, dynamic> _unwrapData(dynamic payload) {
    final json = _asMap(payload);
    final data = json['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    return json;
  }

  String _stringValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    throw const FormatException('Missing auth field');
  }

  int _intValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
    }
    return 0;
  }

  DateTime? _dateValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.isNotEmpty) {
        return DateTime.parse(value);
      }
    }
    return null;
  }

  UserModel _parseUser(Map<String, dynamic> json) {
    return UserModel(
      id: _stringValue(json, ['id']),
      email: _stringValue(json, ['email']),
      name: _stringValue(json, ['name']),
      avatarUrl: (json['avatar_url'] ?? json['avatarUrl']) as String?,
      documentsCount: _intValue(json, ['documents_count', 'documentsCount']),
      queriesCount: _intValue(json, ['queries_count', 'queriesCount']),
      createdAt:
          _dateValue(json, ['created_at', 'createdAt']) ?? DateTime.now(),
      lastLoginAt: _dateValue(json, ['last_login_at', 'lastLoginAt']),
    );
  }

  AuthTokens _parseTokens(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: _stringValue(json, ['access_token', 'accessToken', 'token']),
      refreshToken: _stringValue(json, ['refresh_token', 'refreshToken']),
      expiresAt: _dateValue(json, ['expires_at', 'expiresAt']) ??
          DateTime.now().add(const Duration(minutes: 14)),
    );
  }

  AuthResponse _parseAuthResponse(dynamic payload) {
    final data = _unwrapData(payload);
    final userJson = data['user'] ?? data['userInfo'] ?? data['profile'];
    final tokensJson = data['tokens'] ?? data['auth'] ?? data;
    if (userJson is! Map) {
      throw const FormatException('Invalid auth response: missing user');
    }

    return AuthResponse(
      user: _parseUser(_asMap(userJson, error: 'Invalid user payload')),
      tokens: _parseTokens(_asMap(tokensJson, error: 'Invalid token payload')),
    );
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      return _parseAuthResponse(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return _parseAuthResponse(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, String>> refresh(String refreshToken) async {
    try {
      final res = await _dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });
      final d = _unwrapData(res.data);
      return {
        'accessToken': _stringValue(d, ['access_token', 'accessToken']),
        'refreshToken': _stringValue(d, ['refresh_token', 'refreshToken']),
      };
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> logout({String? refreshToken}) async {
    try {
      await _dio.post('/auth/logout', data: {
        if (refreshToken != null) 'refreshToken': refreshToken,
      });
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<UserModel> getMe() async {
    try {
      final res = await _dio.get('/auth/me');
      return _parseUser(_unwrapData(res.data));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.put('/auth/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
