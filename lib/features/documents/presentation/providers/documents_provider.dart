import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/document_model.dart';
import '../../../../core/constants/app_constants.dart';

part 'documents_provider.g.dart';

// ── Cache Service ────────────────────────────────────────────────────────────

@riverpod
Future<Box<Map>> documentCacheBox(DocumentCacheBoxRef ref) async {
  return await Hive.openBox<Map>(AppConstants.documentCacheBox);
}

// ── Documents List with Pagination + Prefetch ────────────────────────────────

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
  }) {
    return DocumentsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

@riverpod
class DocumentsNotifier extends _$DocumentsNotifier {
  static final _mockDocuments = List.generate(
    60,
    (i) => DocumentModel(
      id: 'doc_$i',
      title: _mockTitles[i % _mockTitles.length],
      fileName: '${_mockTitles[i % _mockTitles.length].toLowerCase().replaceAll(' ', '_')}.pdf',
      mimeType: i % 5 == 0 ? 'image/png' : 'application/pdf',
      fileSizeBytes: (120 + i * 37) * 1024,
      status: i % 10 == 0
          ? DocumentStatus.processing
          : DocumentStatus.ready,
      summary: i % 3 == 0
          ? 'AI-generated summary: This document covers key topics including analysis, methodology, and findings across ${i + 3} pages.'
          : null,
      tags: [_mockTags[i % _mockTags.length], _mockTags[(i + 2) % _mockTags.length]],
      pageCount: 3 + (i % 18),
      queryCount: i * 3,
      createdAt: DateTime.now().subtract(Duration(days: i * 2)),
      processedAt: i % 10 == 0
          ? null
          : DateTime.now().subtract(Duration(days: i * 2 - 1)),
      cachedAt: DateTime.now(),
    ),
  );

  static const _mockTitles = [
    'Q4 Financial Report',
    'Product Roadmap 2025',
    'Engineering Design Spec',
    'Market Research Analysis',
    'User Interview Notes',
    'Architecture Decision Record',
    'Compliance Audit Report',
    'API Documentation v2',
    'Investor Pitch Deck',
    'Security Assessment',
  ];

  static const _mockTags = [
    'finance', 'product', 'engineering', 'research',
    'legal', 'hr', 'marketing', 'design',
  ];

  @override
  DocumentsState build() {
    // Load from cache on init, then refresh
    _initFromCache();
    return const DocumentsState(isLoading: true);
  }

  Future<void> _initFromCache() async {
    try {
      // Try cache first
      final cached = await _loadFromCache();
      if (cached.isNotEmpty) {
        state = DocumentsState(
          items: cached,
          isLoading: false,
          currentPage: 1,
        );
        // Background refresh
        _silentRefresh();
      } else {
        await _fetchPage(0, initial: true);
      }
    } catch (_) {
      await _fetchPage(0, initial: true);
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
    for (final doc in docs) {
      await box.put(doc.id, doc.toJson());
    }
    // Evict oldest if over limit
    if (box.length > AppConstants.maxCacheSize) {
      final keys = box.keys.toList();
      for (int i = 0; i < keys.length - AppConstants.maxCacheSize; i++) {
        await box.delete(keys[i]);
      }
    }
  }

  Future<void> _fetchPage(int page, {bool initial = false}) async {
    if (initial) {
      state = state.copyWith(isLoading: true);
    }

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      final start = page * AppConstants.pageSize;
      final end = (start + AppConstants.pageSize).clamp(0, _mockDocuments.length);
      final pageItems = _mockDocuments.sublist(start, end);

      await _saveToCache(pageItems);

      if (initial || page == 0) {
        state = DocumentsState(
          items: pageItems,
          isLoading: false,
          hasMore: end < _mockDocuments.length,
          currentPage: 1,
        );
      } else {
        state = state.copyWith(
          items: [...state.items, ...pageItems],
          isLoadingMore: false,
          hasMore: end < _mockDocuments.length,
          currentPage: page + 1,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: 'Failed to load documents',
      );
    }
  }

  Future<void> _silentRefresh() async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      final start = 0;
      final end = AppConstants.pageSize.clamp(0, _mockDocuments.length);
      final pageItems = _mockDocuments.sublist(start, end);
      await _saveToCache(pageItems);
      // Only update if user hasn't scrolled far
      if (state.currentPage <= 1) {
        state = state.copyWith(items: pageItems);
      }
    } catch (_) {}
  }

  /// Call this when the list scrolls near the end — prefetch trigger
  Future<void> onScrolledNearEnd() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true);
    await _fetchPage(state.currentPage);
  }


  Future<void> updateDocument(String id,
      {String? title, List<String>? tags}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final box = await ref.read(documentCacheBoxRef.future);
    final existing = box.get(id);
    if (existing != null) {
      final doc = DocumentModel.fromJson(Map<String,dynamic>.from(existing));
      final updated = doc.copyWith(
        title: title ?? doc.title,
        tags: tags ?? doc.tags,
      );
      await box.put(id, updated.toJson());
    }
    state = state.copyWith(
      items: state.items.map((d) {
        if (d.id != id) return d;
        return d.copyWith(
          title: title ?? d.title,
          tags: tags ?? d.tags,
        );
      }).toList(),
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _fetchPage(0, initial: true);
  }

  Future<void> deleteDocument(String id) async {
    final box = await ref.read(documentCacheBoxRef.future);
    await box.delete(id);
    state = state.copyWith(
      items: state.items.where((d) => d.id != id).toList(),
    );
  }
}

// ── Single document provider (with prefetch) ─────────────────────────────────

@riverpod
Future<DocumentModel?> documentById(DocumentByIdRef ref, String id) async {
  // Check cache first
  final box = await ref.read(documentCacheBoxRef.future);
  final cached = box.get(id);
  if (cached != null) {
    final doc = DocumentModel.fromJson(Map<String, dynamic>.from(cached));
    if (!doc.isStale) return doc;
  }

  // Fetch from network
  await Future.delayed(const Duration(milliseconds: 600));

  // Mock
  return DocumentModel(
    id: id,
    title: 'Document $id',
    fileName: 'document_$id.pdf',
    mimeType: 'application/pdf',
    fileSizeBytes: 2 * 1024 * 1024,
    status: DocumentStatus.ready,
    summary: 'This is a detailed AI-generated summary of document $id. It covers the main topics, key entities, and important findings extracted by Claude.',
    tags: ['analysis', 'report'],
    pageCount: 12,
    queryCount: 7,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    processedAt: DateTime.now().subtract(const Duration(days: 3)),
    cachedAt: DateTime.now(),
  );
}

// Provider alias to avoid name conflict
final documentCacheBoxRef = documentCacheBoxProvider;
