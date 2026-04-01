import 'dart:async';
import 'package:dio/dio.dart';
import 'package:docusense/core/utils/dio_client.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:docusense/features/documents/data/models/document_model.dart';

part 'documents_remote_datasource.g.dart';

@riverpod

DocumentsRemoteDatasource documentsRemoteDatasource(Ref ref) {
  return DocumentsRemoteDatasource(dio: ref.watch(dioClientProvider));
}

class DocumentsRemoteDatasource {
  final Dio _dio;
  DocumentsRemoteDatasource({required Dio dio}) : _dio = dio;

  // ── Upload (multipart) ────────────────────────────────────────────────────

  Future<({DocumentModel document, String jobId})> upload({
    required PlatformFile file,
    void Function(int sent, int total)? onProgress,
  }) async {
    if (file.bytes == null) {
      throw const ApiException(message: 'File bytes not available');
    }

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        file.bytes!,
        filename: file.name,
      ),
    });

    try {
      final res = await _dio.post(
        '/documents',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(minutes: 5),
        ),
        onSendProgress: onProgress,
      );

      final data = res.data['data'] as Map<String, dynamic>;
      return (
        document:
            DocumentModel.fromJson(data['document'] as Map<String, dynamic>),
        jobId: data['jobId'] as String,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── List ──────────────────────────────────────────────────────────────────

  Future<({List<DocumentModel> items, int total, bool hasMore})> list({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
    String? tag,
  }) async {
    try {
      final res = await _dio.get('/documents', queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        if (tag != null) 'tag': tag,
      });
      final data = res.data['data'] as Map<String, dynamic>;
      final items = (data['items'] as List)
          .map((j) => DocumentModel.fromJson(j as Map<String, dynamic>))
          .toList();
      return (
        items: items,
        total: data['total'] as int,
        hasMore: data['hasMore'] as bool,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Get one ───────────────────────────────────────────────────────────────

  Future<DocumentModel> getById(String id) async {
    try {
      final res = await _dio.get('/documents/$id');
      return DocumentModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<DocumentModel> update(String id,
      {String? title, List<String>? tags}) async {
    try {
      final res = await _dio.patch('/documents/$id', data: {
        if (title != null) 'title': title,
        if (tags != null) 'tags': tags,
      });
      return DocumentModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> delete(String id) async {
    try {
      await _dio.delete('/documents/$id');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Job status polling ────────────────────────────────────────────────────

  Future<JobStatus> getJobStatus(String jobId) async {
    try {
      final res = await _dio.get('/documents/jobs/$jobId/status');
      final data = res.data['data'] as Map<String, dynamic>;
      return JobStatus.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Poll job until state is 'completed' or 'failed', emitting progress
  Stream<JobStatus> pollJobUntilDone(
    String jobId, {
    Duration interval = const Duration(seconds: 2),
    Duration timeout = const Duration(minutes: 5),
  }) async* {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      final status = await getJobStatus(jobId);
      yield status;
      if (status.state == 'completed' || status.state == 'failed') return;
      await Future.delayed(interval);
    }
    yield const JobStatus(
      id: '',
      state: 'failed',
      progress: 0,
      failedReason: 'Processing timed out after 5 minutes',
    );
  }

  // ── Re-process ────────────────────────────────────────────────────────────

  Future<String> reprocess(String id) async {
    try {
      final res = await _dio.post('/documents/$id/reprocess');
      return res.data['data']['jobId'] as String;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  String _mimeType(PlatformFile file) {
    final ext = file.extension?.toLowerCase() ?? '';
    const map = {
      'pdf': 'application/pdf',
      'png': 'image/png',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'webp': 'image/webp',
      'txt': 'text/plain',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    };
    return map[ext] ?? 'application/octet-stream';
  }
}

// ── JobStatus model ───────────────────────────────────────────────────────────

class JobStatus {
  final String id;
  final String state; // waiting | active | completed | failed
  final num progress; // 0-100
  final String? failedReason;

  const JobStatus({
    required this.id,
    required this.state,
    required this.progress,
    this.failedReason,
  });

  factory JobStatus.fromJson(Map<String, dynamic> json) => JobStatus(
        id: json['id'] as String? ?? '',
        state: json['state'] as String? ?? 'waiting',
        progress: json['progress'] as num? ?? 0,
        failedReason: json['failedReason'] as String?,
      );

  bool get isCompleted => state == 'completed';
  bool get isFailed => state == 'failed';
  bool get isActive => state == 'active' || state == 'waiting';

  double get progressFraction => (progress / 100).clamp(0.0, 1.0).toDouble();
}
