import 'dart:async';
import 'dart:typed_data';
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

  Map<String, dynamic> _asMap(dynamic value,
      {String error = 'Invalid documents response'}) {
    if (value is Map) return Map<String, dynamic>.from(value);
    throw FormatException(error);
  }

  Map<String, dynamic> _unwrapData(dynamic payload) {
    final json = _asMap(payload);

    // Try 'data' key first
    final data = json['data'];
    if (data is Map) return Map<String, dynamic>.from(data);

    // Then try 'payload' key
    final payloadData = json['payload'];
    if (payloadData is Map) return Map<String, dynamic>.from(payloadData);

    return json;
  }

  String _stringValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
      if (value is num) {
        return value.toString();
      }
    }
    throw const FormatException('Missing documents field');
  }

  int _intValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return 0;
  }

  bool _boolValue(Map<String, dynamic> json, List<String> keys,
      {required bool fallback}) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.toLowerCase();
        if (normalized == 'true') return true;
        if (normalized == 'false') return false;
      }
    }
    return fallback;
  }

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

      final data = _unwrapData(res.data);
      final documentJson = data['document'] is Map
          ? Map<String, dynamic>.from(data['document'] as Map)
          : data;
      return (
        document: DocumentModel.fromJson(documentJson),
        jobId: _stringValue(data, ['jobId', 'job_id']),
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
      final data = _unwrapData(res.data);
      final items = ((data['items'] as List?) ?? const [])
          .map((j) => DocumentModel.fromJson(_asMap(j)))
          .toList();
      return (
        items: items,
        total: _intValue(data, ['total', 'itemsCount', 'items_count']),
        hasMore: _boolValue(data, ['hasMore', 'has_more'],
            fallback: items.isNotEmpty && items.length >= limit),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Get one ───────────────────────────────────────────────────────────────

  Future<DocumentModel> getById(String id) async {
    try {
      final res = await _dio.get('/documents/$id');
      final data = _unwrapData(res.data);
      return DocumentModel.fromJson(data);
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
      final data = _unwrapData(res.data);
      return DocumentModel.fromJson(data);
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
      final data = _unwrapData(res.data);
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
      final data = _unwrapData(res.data);
      return _stringValue(data, ['jobId', 'job_id']);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Download file bytes ──────────────────────────────────────────────────

  Future<({Uint8List bytes, String fileName, String mimeType})> downloadFile(
    String id, {
    String? fallbackFileName,
    String? fallbackMimeType,
  }) async {
    try {
      final endpoint = '/documents/$id/download';
      print('DEBUG: download request -> GET ${_dio.options.baseUrl}$endpoint');
      final res = await _dio.get<List<int>>(
        endpoint,
        options: Options(responseType: ResponseType.bytes),
      );

      print(
          'DEBUG: download response -> status: ${res.statusCode}, content-type: ${res.headers.value('content-type')}');

      final bytes = Uint8List.fromList(res.data ?? const <int>[]);
      if (bytes.isEmpty) {
        throw const ApiException(message: 'Downloaded file is empty');
      }

      final headers = res.headers.map;
      final contentDisposition = headers['content-disposition']?.join(',');
      final contentType = headers['content-type']?.join(',');
      final fileName = _extractFileName(
            contentDisposition,
            fallback: fallbackFileName,
          ) ??
          'document-$id';

      return (
        bytes: bytes,
        fileName: fileName,
        mimeType: contentType ?? fallbackMimeType ?? 'application/octet-stream',
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  String? _extractFileName(String? contentDisposition, {String? fallback}) {
    final header = contentDisposition;
    if (header != null) {
      for (final part in header.split(';')) {
        final trimmed = part.trim();
        if (trimmed.startsWith('filename=')) {
          return trimmed
              .substring('filename='.length)
              .replaceAll('"', '')
              .trim();
        }
        if (trimmed.startsWith('filename*=')) {
          final value =
              trimmed.substring('filename*='.length).replaceAll('"', '').trim();
          final decoded = value.contains("''") ? value.split("''").last : value;
          return Uri.decodeFull(decoded);
        }
      }
    }
    return fallback;
  }

  // ── Helper ────────────────────────────────────────────────────────────────
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
