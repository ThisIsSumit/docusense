import 'package:dio/dio.dart';
import 'package:docusense/core/utils/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'users_remote_datasource.g.dart';

@riverpod
UsersRemoteDatasource usersRemoteDatasource(Ref ref) {
  return UsersRemoteDatasource(dio: ref.watch(dioClientProvider));
}

// Note: keep only helpers actually used by this datasource.

Map<String, dynamic> _unwrapData(dynamic payload) {
  if (payload is Map) {
    final data = payload['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    return Map<String, dynamic>.from(payload);
  }
  throw const FormatException('Invalid users response');
}

class UserStats {
  final int documentsCount;
  final int queriesCount;
  final DateTime memberSince;
  final Map<String, int> documentsByStatus;
  final List<RecentQuery> recentQueries;

  const UserStats({
    required this.documentsCount,
    required this.queriesCount,
    required this.memberSince,
    required this.documentsByStatus,
    required this.recentQueries,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      documentsCount: json['documentsCount'] as int,
      queriesCount: json['queriesCount'] as int,
      memberSince: DateTime.parse(json['memberSince'] as String),
      documentsByStatus: Map<String, int>.from(
        json['documentsByStatus'] as Map<String, dynamic>,
      ),
      recentQueries: (json['recentQueries'] as List)
          .map((e) => RecentQuery.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RecentQuery {
  final String id;
  final String question;
  final DateTime createdAt;
  final QueryDocument document;

  const RecentQuery({
    required this.id,
    required this.question,
    required this.createdAt,
    required this.document,
  });

  factory RecentQuery.fromJson(Map<String, dynamic> json) {
    return RecentQuery(
      id: json['id'] as String,
      question: json['question'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      document:
          QueryDocument.fromJson(json['document'] as Map<String, dynamic>),
    );
  }
}

class QueryDocument {
  final String id;
  final String title;

  const QueryDocument({
    required this.id,
    required this.title,
  });

  factory QueryDocument.fromJson(Map<String, dynamic> json) {
    return QueryDocument(
      id: json['id'] as String,
      title: json['title'] as String,
    );
  }
}

class UsersRemoteDatasource {
  final Dio _dio;
  UsersRemoteDatasource({required Dio dio}) : _dio = dio;

  Future<UserStats> getStats() async {
    try {
      final res = await _dio.get('/users/me/stats');
      return UserStats.fromJson(_unwrapData(res.data));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> updateProfile({String? name, String? avatarUrl}) async {
    try {
      await _dio.patch('/users/me', data: {
        if (name != null) 'name': name,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      });
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _dio.delete('/users/me');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
