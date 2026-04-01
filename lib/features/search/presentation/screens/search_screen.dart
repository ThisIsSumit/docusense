import 'dart:async';
import 'package:docusense/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../documents/data/datasources/search_remote_datasource.dart';

part 'search_screen.g.dart';

// ── Search state ──────────────────────────────────────────────────────────────

@riverpod
class SearchNotifier extends _$SearchNotifier {
  Timer? _debounce;

  @override
  ({
    String query,
    List<SearchResult> results,
    bool isSearching,
    String? error,
    List<String> recentQueries,
  }) build() {
    ref.onDispose(() => _debounce?.cancel());
    return (
      query: '',
      results: [],
      isSearching: false,
      error: null,
      recentQueries: [
        'annual report',
        'product roadmap',
        'security audit',
        'API documentation',
      ],
    );
  }

  void onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.isEmpty) {
      state = (
        query: '',
        results: [],
        isSearching: false,
        error: null,
        recentQueries: state.recentQueries,
      );
      return;
    }
    state = (
      query: query,
      results: state.results,
      isSearching: true,
      error: null,
      recentQueries: state.recentQueries,
    );
    _debounce = Timer(
      const Duration(milliseconds: 380),
      () => _search(query),
    );
  }

  Future<void> _search(String query) async {
    try {
      final results = await ref
          .read(searchRemoteDatasourceProvider)
          .search(query: query, limit: 20);

      final recent =
          [query, ...state.recentQueries.where((r) => r != query)].take(6).toList();

      state = (
        query: query,
        results: results,
        isSearching: false,
        error: null,
        recentQueries: recent,
      );
    } catch (e) {
      state = (
        query: query,
        results: const [],
        isSearching: false,
        error: e.toString(),
        recentQueries: state.recentQueries,
      );
    }
  }

  void selectRecent(String query) => onQueryChanged(query);

  void clearQuery() {
    state = (
      query: '',
      results: [],
      isSearching: false,
      error: null,
      recentQueries: state.recentQueries,
    );
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl   = TextEditingController();
  final _focus  = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.void1,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _SearchBar(
                ctrl: _ctrl,
                focus: _focus,
                isSearching: state.isSearching,
                onChanged: (q) =>
                    ref.read(searchNotifierProvider.notifier).onQueryChanged(q),
                onClear: () {
                  _ctrl.clear();
                  ref.read(searchNotifierProvider.notifier).clearQuery();
                },
              ).animate().fadeIn(duration: 300.ms),
            ),
            const SizedBox(height: 16),

            // ── Content ────────────────────────────────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: AppConstants.standardDuration,
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: state.query.isEmpty
                    ? _EmptyState(
                        key: const ValueKey('empty'),
                        recentQueries: state.recentQueries,
                        onSelectRecent: (q) {
                          _ctrl.text = q;
                          _ctrl.selection = TextSelection.fromPosition(
                            TextPosition(offset: q.length),
                          );
                          ref
                              .read(searchNotifierProvider.notifier)
                              .selectRecent(q);
                        },
                      )
                    : state.isSearching
                        ? const _SearchingState(key: ValueKey('searching'))
                        : state.error != null
                            ? _ErrorState(
                                key: const ValueKey('error'),
                                error: state.error!,
                                onRetry: () => ref
                                    .read(searchNotifierProvider.notifier)
                                    .onQueryChanged(state.query),
                              )
                            : state.results.isEmpty
                                ? _NoResults(
                                    key: const ValueKey('no-results'),
                                    query: state.query,
                                  )
                                : _ResultsList(
                                    key: const ValueKey('results'),
                                    results: state.results,
                                    query: state.query,
                                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController ctrl;
  final FocusNode focus;
  final bool isSearching;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.ctrl,
    required this.focus,
    required this.isSearching,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: focus.hasFocus ? AppColors.signal : AppColors.wire,
          width: focus.hasFocus ? 1 : 0.5,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          AnimatedSwitcher(
            duration: AppConstants.microDuration,
            child: isSearching
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5, color: AppColors.signal),
                  )
                : const Icon(Icons.search_rounded,
                    color: AppColors.ink2, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: ctrl,
              focusNode: focus,
              onChanged: onChanged,
              style: AppTextStyles.bodyLG.copyWith(color: AppColors.ink0),
              cursorColor: AppColors.signal,
              decoration: InputDecoration(
                hintText: 'Search documents...',
                hintStyle: AppTextStyles.bodyLG.copyWith(color: AppColors.ink3),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.ink2),
              onPressed: onClear,
            ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final List<String> recentQueries;
  final ValueChanged<String> onSelectRecent;

  const _EmptyState({super.key, required this.recentQueries, required this.onSelectRecent});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Text('RECENT', style: AppTextStyles.labelMD.copyWith(color: AppColors.ink3)),
        const SizedBox(height: 10),
        ...recentQueries.asMap().entries.map((e) =>
          _RecentRow(
            query: e.value,
            index: e.key,
            onTap: () => onSelectRecent(e.value),
          ),
        ),
        const SizedBox(height: 28),
        Text('TOPICS', style: AppTextStyles.labelMD.copyWith(color: AppColors.ink3)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: ['finance', 'contracts', 'research', 'technical', 'reports', 'legal']
              .map((t) => _TopicChip(label: t, onTap: () => onSelectRecent(t)))
              .toList(),
        ),
      ],
    );
  }
}

class _RecentRow extends StatelessWidget {
  final String query;
  final int index;
  final VoidCallback onTap;
  const _RecentRow({required this.query, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface0,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.wire, width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.history_rounded, size: 15, color: AppColors.ink2),
            const SizedBox(width: 10),
            Expanded(child: Text(query, style: AppTextStyles.bodyMD.copyWith(color: AppColors.ink0))),
            const Icon(Icons.north_west_rounded, size: 12, color: AppColors.ink3),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 40 * index), duration: 300.ms)
        .slideX(begin: 0.04, end: 0, delay: Duration(milliseconds: 40 * index), curve: Curves.easeOutCubic);
  }
}

class _TopicChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _TopicChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.signalTrace,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.signal.withOpacity(0.2), width: 0.5),
        ),
        child: Text('#$label', style: AppTextStyles.monoSM),
      ),
    );
  }
}

// ── Searching skeleton ────────────────────────────────────────────────────────

class _SearchingState extends StatelessWidget {
  const _SearchingState({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface0,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.wire, width: 0.5),
          ),
          child: Row(
            children: [
              ShimmerBox(width: 38, height: 38, borderRadius: BorderRadius.circular(6)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ShimmerBox(width: double.infinity, height: 12),
                  const SizedBox(height: 7),
                  ShimmerBox(width: 140, height: 10),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorState({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppColors.ink2, size: 40),
            const SizedBox(height: 14),
            Text('Search unavailable', style: AppTextStyles.headingSM),
            const SizedBox(height: 6),
            Text('Check your connection and try again.',
                style: AppTextStyles.bodyMD, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.signalTrace,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.signal.withOpacity(0.3), width: 0.5),
                ),
                child: Text('Retry', style: AppTextStyles.bodyMD.copyWith(color: AppColors.signal)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── No results ────────────────────────────────────────────────────────────────

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded, color: AppColors.ink2, size: 40),
          const SizedBox(height: 14),
          Text('No results for "$query"',
              style: AppTextStyles.headingSM.copyWith(color: AppColors.ink1)),
          const SizedBox(height: 6),
          Text('Try different keywords or upload more documents.',
              style: AppTextStyles.bodyMD, textAlign: TextAlign.center),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}

// ── Results list ──────────────────────────────────────────────────────────────

class _ResultsList extends StatelessWidget {
  final List<SearchResult> results;
  final String query;
  const _ResultsList({super.key, required this.results, required this.query});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Row(children: [
            Text('${results.length} results', style: AppTextStyles.monoSM),
            const Spacer(),
            Text('semantic · pgvector',
                style: AppTextStyles.monoSM.copyWith(color: AppColors.signalDim)),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: results.length,
            itemBuilder: (_, i) {
              final r = results[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => context.push('/documents/${r.documentId}'),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface0,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.wire, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: _HighlightText(
                              text: r.documentTitle,
                              query: query,
                              style: AppTextStyles.headingSM,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.signalTrace,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              '${(r.similarity * 100).toStringAsFixed(0)}%',
                              style: AppTextStyles.monoSM,
                            ),
                          ),
                        ]),
                        const SizedBox(height: 6),
                        _HighlightText(
                          text: r.content,
                          query: query,
                          style: AppTextStyles.bodyMD,
                          maxLines: 2,
                        ),
                        if (r.pageNumber != null) ...[
                          const SizedBox(height: 6),
                          Text('p.${r.pageNumber}',
                              style: AppTextStyles.monoSM),
                        ],
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 35 * i), duration: 300.ms)
                      .slideY(begin: 0.05, end: 0,
                          delay: Duration(milliseconds: 35 * i),
                          curve: Curves.easeOutCubic),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Highlight text ────────────────────────────────────────────────────────────

class _HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final int? maxLines;

  const _HighlightText({
    required this.text,
    required this.query,
    required this.style,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: style, maxLines: maxLines,
          overflow: maxLines != null ? TextOverflow.ellipsis : null);
    }
    final lower = text.toLowerCase();
    final lowerQ = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    while (true) {
      final idx = lower.indexOf(lowerQ, start);
      if (idx == -1) { spans.add(TextSpan(text: text.substring(start), style: style)); break; }
      if (idx > start) spans.add(TextSpan(text: text.substring(start, idx), style: style));
      spans.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: style.copyWith(color: AppColors.signal, backgroundColor: AppColors.signalTrace),
      ));
      start = idx + query.length;
    }
    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip,
    );
  }
}
