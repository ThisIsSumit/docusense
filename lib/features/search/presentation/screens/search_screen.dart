import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../documents/data/models/document_model.dart';
import '../../../documents/presentation/providers/documents_provider.dart';

part 'search_screen.g.dart';

// ── Search Provider ───────────────────────────────────────────────────────────

@riverpod
class SearchNotifier extends _$SearchNotifier {
  Timer? _debounce;

  @override
  ({
    String query,
    List<DocumentModel> results,
    bool isSearching,
    List<String> recentQueries,
  }) build() {
    ref.onDispose(() => _debounce?.cancel());
    return (
      query: '',
      results: [],
      isSearching: false,
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
        recentQueries: state.recentQueries,
      );
      return;
    }

    state = (
      query: query,
      results: state.results,
      isSearching: true,
      recentQueries: state.recentQueries,
    );

    _debounce = Timer(const Duration(milliseconds: 380), () => _search(query));
  }

  Future<void> _search(String query) async {
    // Simulate RAG search with vector similarity
    await Future.delayed(const Duration(milliseconds: 600));

    final allDocs = ref.read(documentsNotifierProvider).items;
    final q = query.toLowerCase();

    final results = allDocs
        .where((d) =>
            d.title.toLowerCase().contains(q) ||
            d.tags.any((t) => t.contains(q)) ||
            (d.summary?.toLowerCase().contains(q) ?? false))
        .take(20)
        .toList();

    // Add to recent if meaningful
    final recent = [query, ...state.recentQueries.where((r) => r != query)]
        .take(6)
        .toList();

    state = (
      query: query,
      results: results,
      isSearching: false,
      recentQueries: recent,
    );
  }

  void selectRecent(String query) => onQueryChanged(query);

  void clearQuery() {
    state = (
      query: '',
      results: [],
      isSearching: false,
      recentQueries: state.recentQueries,
    );
  }
}

// ── Search Screen ─────────────────────────────────────────────────────────────

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
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
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _SearchBar(
                ctrl: _ctrl,
                focusNode: _focusNode,
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

            // Content
            Expanded(
              child: AnimatedSwitcher(
                duration: AppConstants.standardDuration,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: child,
                ),
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
                        : state.results.isEmpty
                            ? _NoResults(
                                key: const ValueKey('no-results'),
                                query: state.query)
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

class _SearchBar extends StatelessWidget {
  final TextEditingController ctrl;
  final FocusNode focusNode;
  final bool isSearching;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.ctrl,
    required this.focusNode,
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: focusNode.hasFocus ? AppColors.accent : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          AnimatedSwitcher(
            duration: AppConstants.microDuration,
            child: isSearching
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: AppColors.accent,
                    ),
                  )
                : const Icon(Icons.search_rounded,
                    color: AppColors.textTertiary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: ctrl,
              focusNode: focusNode,
              onChanged: onChanged,
              style: AppTextStyles.bodyLG.copyWith(color: AppColors.textPrimary),
              cursorColor: AppColors.accent,
              decoration: InputDecoration(
                hintText: 'Search documents...',
                hintStyle: AppTextStyles.bodyLG
                    .copyWith(color: AppColors.textTertiary),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded,
                  size: 18, color: AppColors.textTertiary),
              onPressed: onClear,
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final List<String> recentQueries;
  final ValueChanged<String> onSelectRecent;

  const _EmptyState({
    super.key,
    required this.recentQueries,
    required this.onSelectRecent,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Text('Recent Searches',
            style: AppTextStyles.labelLG
                .copyWith(color: AppColors.textTertiary)),
        const SizedBox(height: 12),
        ...recentQueries.asMap().entries.map(
              (e) => _RecentChip(
                query: e.value,
                index: e.key,
                onTap: () => onSelectRecent(e.value),
              ),
            ),
        const SizedBox(height: 32),
        Text('Suggested Topics',
            style: AppTextStyles.labelLG
                .copyWith(color: AppColors.textTertiary)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'finance',
            'contracts',
            'research',
            'technical',
            'reports',
            'legal',
          ]
              .map((t) => _TopicPill(
                    label: t,
                    onTap: () => onSelectRecent(t),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _RecentChip extends StatelessWidget {
  final String query;
  final int index;
  final VoidCallback onTap;

  const _RecentChip({
    required this.query,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface0,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.history_rounded,
                size: 16, color: AppColors.textTertiary),
            const SizedBox(width: 12),
            Text(query, style: AppTextStyles.bodyMD),
            const Spacer(),
            const Icon(Icons.north_west_rounded,
                size: 14, color: AppColors.textTertiary),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 50 * index), duration: 300.ms)
        .slideX(
            begin: 0.05,
            end: 0,
            delay: Duration(milliseconds: 50 * index),
            curve: Curves.easeOutCubic);
  }
}

class _TopicPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TopicPill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.accentFaint,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accent.withOpacity(0.2)),
        ),
        child: Text('#$label', style: AppTextStyles.monoSM),
      ),
    );
  }
}

class _SearchingState extends StatelessWidget {
  const _SearchingState({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface0,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              ShimmerBox(
                  width: 40,
                  height: 40,
                  borderRadius: BorderRadius.circular(8)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: double.infinity, height: 13),
                    const SizedBox(height: 8),
                    ShimmerBox(width: 160, height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded,
              color: AppColors.textTertiary, size: 48),
          const SizedBox(height: 16),
          Text('No results for "$query"',
              style: AppTextStyles.headingSM
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('Try different keywords or upload more documents.',
              style: AppTextStyles.bodyMD,
              textAlign: TextAlign.center),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}

class _ResultsList extends StatelessWidget {
  final List<DocumentModel> results;
  final String query;

  const _ResultsList({super.key, required this.results, required this.query});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            children: [
              Text('${results.length} results',
                  style: AppTextStyles.monoSM),
              const Spacer(),
              Text('semantic match',
                  style: AppTextStyles.monoSM
                      .copyWith(color: AppColors.accentDim)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: results.length,
            itemBuilder: (_, i) {
              final doc = results[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => context.push('/documents/${doc.id}'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface0,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _HighlightText(
                                text: doc.title,
                                query: query,
                                style: AppTextStyles.headingSM,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.accentFaint,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${(0.7 + i * 0.03).clamp(0.0, 1.0).toStringAsFixed(2)}',
                                style: AppTextStyles.monoSM,
                              ),
                            ),
                          ],
                        ),
                        if (doc.summary != null) ...[
                          const SizedBox(height: 8),
                          _HighlightText(
                            text: doc.summary!,
                            query: query,
                            style: AppTextStyles.bodyMD,
                            maxLines: 2,
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            ...doc.tags.take(2).map((t) => Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface2,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('#$t',
                                      style: AppTextStyles.monoSM),
                                )),
                            const Spacer(),
                            Text(doc.displaySize, style: AppTextStyles.bodySM),
                          ],
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(
                          delay: Duration(milliseconds: 40 * i),
                          duration: 300.ms)
                      .slideY(
                          begin: 0.06,
                          end: 0,
                          delay: Duration(milliseconds: 40 * i),
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

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final idx = lowerText.indexOf(lowerQuery, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start), style: style));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx), style: style));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: style.copyWith(
          color: AppColors.accent,
          backgroundColor: AppColors.accentFaint,
        ),
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
