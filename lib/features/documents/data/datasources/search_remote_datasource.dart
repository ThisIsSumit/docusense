import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:docusense/core/constants/app_constants.dart';
import 'package:docusense/core/utils/dio_client.dart';
import 'package:docusense/features/auth/presentation/providers/auth_provider.dart';
import 'package:docusense/features/chat/data/models/chat_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';



part 'search_remote_datasource.g.dart';

@riverpod
SearchRemoteDatasource searchRemoteDatasource(Ref ref) {
  return SearchRemoteDatasource(
    dio: ref.watch(dioClientProvider),
    authNotifier: ref.watch(authStateNotifierProvider.notifier),
  );
}

class SearchRemoteDatasource {
  final Dio _dio;
  final AuthStateNotifier _auth;

  SearchRemoteDatasource({
    required Dio dio,
    required AuthStateNotifier authNotifier,
  }) : _dio = dio, _auth = authNotifier;

  // ── Semantic chunk search (no AI answer) ──────────────────────────────────

  Future<List<SearchResult>> search({
    required String query,
    String? documentId,
    int limit = 8,
    double minSimilarity = 0.3,
  }) async {
    try {
      final res = await _dio.get('/search', queryParameters: {
        'q': query,
        'limit': limit,
        'minSimilarity': minSimilarity,
        if (documentId != null) 'documentId': documentId,
      });
      final data = res.data['data'] as Map<String, dynamic>;
      return (data['results'] as List)
          .map((j) => SearchResult.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── RAG query — non-streaming ─────────────────────────────────────────────

  Future<({String answer, List<SourceCitation> sources, int tokensUsed, int latencyMs})>
      query({
    required String question,
    String? documentId,
  }) async {
    try {
      final res = await _dio.post('/search/query', data: {
        'question': question,
        if (documentId != null) 'documentId': documentId,
        'stream': false,
      });
      final data = res.data['data'] as Map<String, dynamic>;
      final sources = (data['sources'] as List)
          .map((s) => SourceCitation.fromJson(s as Map<String, dynamic>))
          .toList();
      return (
        answer: data['answer'] as String,
        sources: sources,
        tokensUsed: (data['meta']?['tokensUsed'] as int?) ?? 0,
        latencyMs: (data['meta']?['latencyMs'] as int?) ?? 0,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── RAG query — SSE streaming ─────────────────────────────────────────────
  //
  // Emits three event types in order:
  //   SseSourcesEvent  — fired once with the source citation list
  //   SseDeltaEvent    — fired N times, one per streamed token
  //   SseDoneEvent     — fired once when stream is complete
  //
  // Usage:
  //   await for (final event in datasource.queryStream(question: '...')) {
  //     if (event is SseDeltaEvent) appendToken(event.text);
  //     if (event is SseSourcesEvent) showSources(event.sources);
  //     if (event is SseDoneEvent) markComplete();
  //   }

  Stream<SseEvent> queryStream({
    required String question,
    String? documentId,
  }) async* {
    final token = await _auth.getCurrentAccessToken();
    final uri = Uri.parse('${AppConstants.baseUrl}/search/query');

    final request = http.Request('POST', uri)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
        'Cache-Control': 'no-cache',
        if (token != null) 'Authorization': 'Bearer $token',
      })
      ..body = jsonEncode({
        'question': question,
        if (documentId != null) 'documentId': documentId,
        'stream': true,
      });

    late http.StreamedResponse response;
    try {
      response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw const ApiException(
          message: 'Stream connection timed out',
          code: 'STREAM_TIMEOUT',
        ),
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        message: 'Failed to connect to stream: ${e.message}',
        code: 'STREAM_CONNECT_FAILED',
      );
    }

    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      Map<String, dynamic> errorBody = {};
      try { errorBody = jsonDecode(body) as Map<String, dynamic>; } catch (_) {}
      throw ApiException(
        statusCode: response.statusCode,
        message: (errorBody['error']?['message'] as String?) ?? 'Stream failed',
        code: (errorBody['error']?['code'] as String?) ?? 'STREAM_ERROR',
      );
    }

    // Parse SSE stream
    final buffer = StringBuffer();
    await for (final chunk in response.stream
        .transform(utf8.decoder)) {
      buffer.write(chunk);
      final content = buffer.toString();
      final lines = content.split('\n');

      // Process all complete lines (everything except last partial line)
      for (int i = 0; i < lines.length - 1; i++) {
        final line = lines[i].trim();
        if (!line.startsWith('data: ')) continue;

        final rawJson = line.substring(6).trim();
        if (rawJson.isEmpty) continue;

        try {
          final payload = jsonDecode(rawJson) as Map<String, dynamic>;
          final type = payload['type'] as String?;

          switch (type) {
            case 'sources':
              final sources = (payload['sources'] as List?)
                  ?.map((s) => SourceCitation.fromJson(
                      s as Map<String, dynamic>))
                  .toList() ?? [];
              yield SseSourcesEvent(sources: sources);

            case 'delta':
              final text = payload['text'] as String? ?? '';
              if (text.isNotEmpty) yield SseDeltaEvent(text: text);

            case 'error':
              throw ApiException(
                message: payload['message'] as String? ?? 'Stream error',
                code: 'STREAM_ERROR',
              );

            case 'done':
              yield SseDoneEvent(
                totalTokens: payload['totalTokens'] as int? ?? 0,
              );
              return;
          }
        } catch (e) {
          if (e is ApiException) rethrow;
          // Malformed JSON line — skip silently
        }
      }

      // Keep the last partial line in the buffer
      buffer.clear();
      if (lines.isNotEmpty) buffer.write(lines.last);
    }
  }

  // ── Query history ─────────────────────────────────────────────────────────

  Future<({List<QueryHistoryItem> items, int total, bool hasMore})>
      getHistory({int page = 1, int limit = 20}) async {
    try {
      final res = await _dio.get('/search/history', queryParameters: {
        'page': page,
        'limit': limit,
      });
      final data = res.data['data'] as Map<String, dynamic>;
      final items = (data['items'] as List)
          .map((j) => QueryHistoryItem.fromJson(j as Map<String, dynamic>))
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
}

// ── SSE event types ───────────────────────────────────────────────────────────

sealed class SseEvent {}

class SseSourcesEvent extends SseEvent {
  final List<SourceCitation> sources;
  SseSourcesEvent({required this.sources});
}

class SseDeltaEvent extends SseEvent {
  final String text;
  SseDeltaEvent({required this.text});
}

class SseDoneEvent extends SseEvent {
  final int totalTokens;
  SseDoneEvent({required this.totalTokens});
}

// ── Search result model ───────────────────────────────────────────────────────

class SearchResult {
  final String chunkId;
  final String documentId;
  final String documentTitle;
  final String content;
  final int? pageNumber;
  final double similarity;

  const SearchResult({
    required this.chunkId,
    required this.documentId,
    required this.documentTitle,
    required this.content,
    this.pageNumber,
    required this.similarity,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) => SearchResult(
    chunkId: json['chunkId'] as String,
    documentId: json['documentId'] as String,
    documentTitle: json['documentTitle'] as String,
    content: json['content'] as String,
    pageNumber: json['pageNumber'] as int?,
    similarity: (json['similarity'] as num).toDouble(),
  );
}

// ── Query history item ────────────────────────────────────────────────────────

class QueryHistoryItem {
  final String id;
  final String question;
  final String answer;
  final int tokensUsed;
  final int latencyMs;
  final DateTime createdAt;
  final ({String id, String title})? document;

  const QueryHistoryItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.tokensUsed,
    required this.latencyMs,
    required this.createdAt,
    this.document,
  });

  factory QueryHistoryItem.fromJson(Map<String, dynamic> json) {
    final doc = json['document'] as Map<String, dynamic>?;
    return QueryHistoryItem(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      tokensUsed: json['tokensUsed'] as int? ?? 0,
      latencyMs: json['latencyMs'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      document: doc != null
          ? (id: doc['id'] as String, title: doc['title'] as String)
          : null,
    );
  }
}
