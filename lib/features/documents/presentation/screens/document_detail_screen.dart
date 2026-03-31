import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../providers/documents_provider.dart';
import '../../data/models/document_model.dart';
import 'document_actions.dart';

class DocumentDetailScreen extends ConsumerWidget {
  final String documentId;
  const DocumentDetailScreen({super.key, required this.documentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docAsync = ref.watch(documentByIdProvider(documentId));
    return Scaffold(
      backgroundColor: AppColors.void1,
      body: docAsync.when(
        loading: () => const _LoadingView(),
        error: (e, _) => Center(
            child: Text('Error: $e', style: AppTextStyles.bodyMD)),
        data: (doc) => doc == null
            ? const Center(child: Text('Not found'))
            : _DetailView(doc: doc),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size:18,
              color: AppColors.ink1),
          onPressed: () => context.pop(),
        ),
        const SizedBox(height: 24),
        ShimmerBox(width: 200, height: 24),
        const SizedBox(height: 12),
        ShimmerBox(width: 120, height: 14),
        const SizedBox(height: 32),
        ShimmerBox(width: double.infinity, height: 100,
            borderRadius: BorderRadius.circular(10)),
      ]),
    ),
  );
}

class _DetailView extends ConsumerWidget {
  final DocumentModel doc;
  const _DetailView({required this.doc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.void1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size:18),
            onPressed: () => context.pop(),
          ),
          actions: [
            // Share
            IconButton(
              icon: const Icon(Icons.ios_share_rounded, size: 20),
              onPressed: () => showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => ShareBottomSheet(doc: doc),
              ),
            ),
            // 3-dot
            IconButton(
              icon: const Icon(Icons.more_horiz_rounded, size: 20),
              onPressed: () => showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => DocumentActionsSheet(doc: doc),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status + type badges
                Row(children: [
                  _Badge(
                    label: doc.mimeType.split('/').last.toUpperCase(),
                    color: AppColors.red,
                  ),
                  const SizedBox(width: 8),
                  if (doc.status == DocumentStatus.ready)
                    _Badge(label: 'INDEXED', color: AppColors.green),
                  if (doc.status == DocumentStatus.processing)
                    _Badge(label: 'PROCESSING', color: AppColors.amber,
                        pulse: true),
                  if (doc.status == DocumentStatus.failed)
                    _Badge(label: 'FAILED', color: AppColors.red),
                ]).animate().fadeIn(delay: 50.ms),

                const SizedBox(height: 16),

                Text(doc.title, style: AppTextStyles.displayMD)
                    .animate()
                    .fadeIn(delay: 100.ms)
                    .slideY(begin:0.08, end:0,
                    curve:Curves.easeOutCubic),

                const SizedBox(height: 8),

                Text(
                  '${doc.displaySize}  ·  ${doc.pageCount}p  ·  ${doc.queryCount} queries',
                  style: AppTextStyles.bodyMD,
                ).animate().fadeIn(delay: 150.ms),

                const SizedBox(height: 20),

                // Tags
                if (doc.tags.isNotEmpty)
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: doc.tags.map((t) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.signalTrace,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                            color: AppColors.signal.withOpacity(0.2),
                            width: 0.5),
                      ),
                      child: Text('#$t', style: AppTextStyles.monoSM),
                    )).toList(),
                  ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 24),

                // Summary
                if (doc.summary != null) ...[
                  Text('AI SUMMARY',
                      style: AppTextStyles.labelMD
                          .copyWith(color: AppColors.ink2)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.signalTrace,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.signal.withOpacity(0.15),
                          width: 0.5),
                    ),
                    child: Text(doc.summary!,
                        style: AppTextStyles.bodyMD
                            .copyWith(color: AppColors.ink0)),
                  ).animate().fadeIn(delay: 250.ms)
                      .slideY(begin:0.08, end:0,
                      curve:Curves.easeOutCubic),
                  const SizedBox(height: 24),
                ],

                // Ask CTA
                GlowButton(
                  onPressed: () => context.push(
                    '/chat/${doc.id}',
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded,
                          size: 16, color: AppColors.void0),
                      const SizedBox(width: 8),
                      const Text('Ask about this document'),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 24),

                // Metadata
                Text('DETAILS',
                    style: AppTextStyles.labelMD
                        .copyWith(color: AppColors.ink2)),
                const SizedBox(height: 10),
                _MetaGrid(doc: doc)
                    .animate().fadeIn(delay: 350.ms),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatefulWidget {
  final String label;
  final Color color;
  final bool pulse;
  const _Badge({required this.label, required this.color, this.pulse=false});

  @override
  State<_Badge> createState() => _BadgeState();
}

class _BadgeState extends State<_Badge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.pulse) _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: widget.pulse ? 0.5 + _ctrl.value * 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
                color: widget.color.withOpacity(0.3),
                width: 0.5),
          ),
          child: Text(
            widget.label,
            style: AppTextStyles.monoSM
                .copyWith(color: widget.color),
          ),
        ),
      ),
    );
  }
}

class _MetaGrid extends StatelessWidget {
  final DocumentModel doc;
  const _MetaGrid({required this.doc});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('File', doc.fileName),
      ('Created', _fmt(doc.createdAt)),
      ('Processed',
          doc.processedAt != null ? _fmt(doc.processedAt!) : '—'),
      ('Pages', '${doc.pageCount}'),
      ('Size', doc.displaySize),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.wire, width: 0.5),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(
                      bottom: BorderSide(
                          color: AppColors.wireDim, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(e.value.$1,
                    style: AppTextStyles.bodyMD),
                Flexible(
                  child: Text(
                    e.value.$2,
                    style: AppTextStyles.bodyMD
                        .copyWith(color: AppColors.ink0),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year}';
}
