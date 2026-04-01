import 'dart:async';
import 'package:docusense/core/constants/app_constants.dart';
import 'package:docusense/features/documents/presentation/providers/documents_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:docusense/features/documents/data/models/document_model.dart';
import 'package:docusense/features/documents/data/datasources/documents_remote_datasource.dart';
import 'package:docusense/features/documents/data/datasources/search_remote_datasource.dart';
import 'package:docusense/core/theme/app_theme.dart';
import 'package:docusense/core/utils/dio_client.dart';

part 'documents_provider.g.dart';

@riverpod
Future<Box<Map>> documentCacheBox(DocumentCacheBoxRef ref) async {
  return await Hive.openBox<Map>(AppConstants.documentCacheBox);
}

class DocumentsState {
  final List<DocumentModel> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final int currentPage;

  const DocumentsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.currentPage = 0,
  });

  DocumentsState copyWith({
    List<DocumentModel>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    int? currentPage,
    bool clearError = false,
  }) =>
      DocumentsState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        error: clearError ? null : (error ?? this.error),
        currentPage: currentPage ?? this.currentPage,
      );
}

@riverpod
class DocumentsNotifier extends _$DocumentsNotifier {
  @override
  DocumentsState build() {
    _init();
    return const DocumentsState(isLoading: true);
  }

  Future<void> _init() async {
    final cached = await _loadFromCache();
    if (cached.isNotEmpty) {
      state = DocumentsState(items: cached, isLoading: false, currentPage: 1);
      _backgroundRefresh();
    } else {
      await _fetchPage(1, initial: true);
    }
  }

  Future<List<DocumentModel>> _loadFromCache() async {
    final box = await ref.read(documentCacheBoxRef.future);
    return box.values
        .map((raw) => DocumentModel.fromJson(Map<String, dynamic>.from(raw)))
        .where((d) => !d.isStale)
        .take(AppConstants.pageSize)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _saveToCache(List<DocumentModel> docs) async {
    final box = await ref.read(documentCacheBoxRef.future);
    for (final doc in docs) await box.put(doc.id, doc.toJson());
    if (box.length > AppConstants.maxCacheSize) {
      final keys = box.keys.toList();
      for (int i = 0; i < keys.length - AppConstants.maxCacheSize; i++) {
        await box.delete(keys[i]);
      }
    }
  }

  Future<void> _removeFromCache(String id) async {
    final box = await ref.read(documentCacheBoxRef.future);
    await box.delete(id);
  }

  Future<void> _fetchPage(int page, {bool initial = false}) async {
    if (initial) state = state.copyWith(isLoading: true);
    try {
      final result = await ref
          .read(documentsRemoteDatasourceProvider)
          .list(page: page, limit: AppConstants.pageSize);
      await _saveToCache(result.items);
      if (initial || page == 1) {
        state = DocumentsState(
            items: result.items,
            isLoading: false,
            hasMore: result.hasMore,
            currentPage: 1);
      } else {
        state = state.copyWith(
            items: [...state.items, ...result.items],
            isLoadingMore: false,
            hasMore: result.hasMore,
            currentPage: page);
      }
    } on ApiException catch (e) {
      state = state.copyWith(
          isLoading: false, isLoadingMore: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: 'Failed to load documents');
    }
  }

  Future<void> _backgroundRefresh() async {
    try {
      final r = await ref
          .read(documentsRemoteDatasourceProvider)
          .list(page: 1, limit: AppConstants.pageSize);
      await _saveToCache(r.items);
      if (state.currentPage <= 1) {
        state = state.copyWith(items: r.items, hasMore: r.hasMore);
      }
    } catch (_) {}
  }

  Future<void> onScrolledNearEnd() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true);
    await _fetchPage(state.currentPage + 1);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _fetchPage(1, initial: true);
  }

  Future<void> deleteDocument(String id) async {
    await ref.read(documentsRemoteDatasourceProvider).delete(id);
    await _removeFromCache(id);
    state =
        state.copyWith(items: state.items.where((d) => d.id != id).toList());
  }

  Future<void> updateDocument(String id,
      {String? title, List<String>? tags}) async {
    final updated = await ref
        .read(documentsRemoteDatasourceProvider)
        .update(id, title: title, tags: tags);
    final box = await ref.read(documentCacheBoxRef.future);
    await box.put(id, updated.toJson());
    state = state.copyWith(
        items: [for (final d in state.items) d.id == id ? updated : d]);
  }
}

@riverpod
Future<DocumentModel?> documentById(DocumentByIdRef ref, String id) async {
  final box = await ref.read(documentCacheBoxRef.future);
  final raw = box.get(id);
  if (raw != null) {
    final cached = DocumentModel.fromJson(Map<String, dynamic>.from(raw));
    if (!cached.isStale) {
      _refreshDocumentInBackground(ref, id, box);
      return cached;
    }
  }
  final doc = await ref.read(documentsRemoteDatasourceProvider).getById(id);
  await box.put(id, doc.toJson());
  return doc;
}

Future<void> _refreshDocumentInBackground(
    Ref ref, String id, Box<Map> box) async {
  try {
    final fresh = await ref.read(documentsRemoteDatasourceProvider).getById(id);
    await box.put(id, fresh.toJson());
  } catch (_) {}
}

@riverpod
Stream<JobStatus> jobStatusStream(JobStatusStreamRef ref, String jobId) {
  return ref.read(documentsRemoteDatasourceProvider).pollJobUntilDone(jobId,
      interval: const Duration(seconds: 2),
      timeout: const Duration(minutes: 5));
}

final documentCacheBoxRef = documentCacheBoxProvider;
