import 'package:dio/dio.dart';
import 'package:docusense/core/utils/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';



part 'users_remote_datasource.g.dart';

@riverpod
UsersRemoteDatasource usersRemoteDatasource(Ref ref) {
  return UsersRemoteDatasource(dio: ref.watch(dioClientProvider));
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

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
        documentsCount: json['documentsCount'] as int? ?? 0,
        queriesCount: json['queriesCount'] as int? ?? 0,
        memberSince: DateTime.parse(json['memberSince'] as String),
        documentsByStatus: Map<String, int>.from(
          (json['documentsByStatus'] as Map<String, dynamic>? ?? {})
              .map((k, v) => MapEntry(k, v as int)),
        ),
        recentQueries: (json['recentQueries'] as List? ?? [])
            .map((q) => RecentQuery.fromJson(q as Map<String, dynamic>))
            .toList(),
      );
}

class RecentQuery {
  final String id;
  final String question;
  final DateTime createdAt;
  final ({String id, String title})? document;

  const RecentQuery({
    required this.id,
    required this.question,
    required this.createdAt,
    this.document,
  });

  factory RecentQuery.fromJson(Map<String, dynamic> json) {
    final doc = json['document'] as Map<String, dynamic>?;
    return RecentQuery(
      id: json['id'] as String,
      question: json['question'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      document: doc != null
          ? (id: doc['id'] as String, title: doc['title'] as String)
          : null,
    );
  }
}

class UsersRemoteDatasource {
  final Dio _dio;
  UsersRemoteDatasource({required Dio dio}) : _dio = dio;

  Future<UserStats> getStats() async {
    try {
      final res = await _dio.get('/users/me/stats');
      return UserStats.fromJson(res.data['data'] as Map<String, dynamic>);
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
