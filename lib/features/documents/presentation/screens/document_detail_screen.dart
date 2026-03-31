import 'package:docusense/shared/widgets/document_action_sheet.dart';
import 'package:docusense/shared/widgets/share_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:docusense/core/theme/app_theme.dart';
import 'package:docusense/shared/widgets/app_widgets.dart';
import 'package:docusense/features/documents/presentation/providers/documents_provider.dart';
import 'package:docusense/features/documents/data/models/document_model.dart';

// --- Share Bottom Sheet Widget ---

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
          child: Text('Error: $e', style: AppTextStyles.bodyMD),
        ),
        data: (doc) => doc == null
            ? const Center(child: Text('Document not found'))
            : _DetailView(doc: doc, ref: ref, documentId: documentId),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: AppColors.textSecondary),
              onPressed: () => context.pop(),
            ),
            const SizedBox(height: 24),
            ShimmerBox(width: 200, height: 24),
            const SizedBox(height: 12),
            ShimmerBox(width: 120, height: 14),
            const SizedBox(height: 32),
            ShimmerBox(
                width: double.infinity,
                height: 100,
                borderRadius: BorderRadius.circular(14)),
          ],
        ),
      ),
    );
  }
}

class _DetailView extends StatelessWidget {
  final DocumentModel doc;
  final WidgetRef ref;
  final String documentId;

  const _DetailView(
      {required this.doc, required this.ref, required this.documentId});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // App bar
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.void1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined, size: 20),
              onPressed: () async {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: AppColors.surface1,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (ctx) => ShareBottomSheet(doc: doc),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz_rounded, size: 20),
              onPressed: () => showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => DocumentActionsSheet(
                  doc: doc,
                  ref: ref,
                  documentId: documentId,
                ),
              ),
            ),
          ],
          // ...existing code...
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // File type + status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        doc.mimeType.split('/').last.toUpperCase(),
                        style: AppTextStyles.monoSM
                            .copyWith(color: AppColors.error),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (doc.status == DocumentStatus.ready)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('INDEXED',
                            style: AppTextStyles.monoSM
                                .copyWith(color: AppColors.success)),
                      ),
                  ],
                ).animate().fadeIn(delay: 50.ms),

                const SizedBox(height: 16),

                // Title
                Text(doc.title, style: AppTextStyles.displayMD)
                    .animate()
                    .fadeIn(delay: 100.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: 8),

                // Meta
                Text(
                  '${doc.displaySize}  ·  ${doc.pageCount} pages  ·  ${doc.queryCount} queries',
                  style: AppTextStyles.bodyMD,
                ).animate().fadeIn(delay: 150.ms),

                const SizedBox(height: 24),

                // Tags
                if (doc.tags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: doc.tags
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accentFaint,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppColors.accent.withOpacity(0.2)),
                              ),
                              child: Text(
                                '#$tag',
                                style: AppTextStyles.monoSM,
                              ),
                            ))
                        .toList(),
                  ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 28),

                // Summary
                if (doc.summary != null) ...[
                  Text('AI Summary',
                          style: AppTextStyles.labelLG
                              .copyWith(color: AppColors.textTertiary))
                      .animate()
                      .fadeIn(delay: 250.ms),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accentFaint,
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: AppColors.accent.withOpacity(0.15)),
                    ),
                    child: Text(doc.summary!, style: AppTextStyles.bodyMD),
                  )
                      .animate()
                      .fadeIn(delay: 280.ms)
                      .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                  const SizedBox(height: 28),
                ],

                // Ask button
                GlowButton(
                  onPressed: () {},
                  child: const Text('Ask About This Document'),
                ).animate().fadeIn(delay: 350.ms),

                const SizedBox(height: 16),

                // Metadata grid
                Text('Details',
                        style: AppTextStyles.labelLG
                            .copyWith(color: AppColors.textTertiary))
                    .animate()
                    .fadeIn(delay: 400.ms),
                const SizedBox(height: 12),
                _MetaGrid(doc: doc).animate().fadeIn(delay: 430.ms),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaGrid extends StatelessWidget {
  final DocumentModel doc;

  const _MetaGrid({required this.doc});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('File name', doc.fileName),
      ('Created', _fmt(doc.createdAt)),
      ('Processed', doc.processedAt != null ? _fmt(doc.processedAt!) : '—'),
      ('Pages', '${doc.pageCount}'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(
                      bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.value.$1,
                    style: AppTextStyles.bodyMD
                        .copyWith(color: AppColors.textTertiary)),
                Flexible(
                  child: Text(
                    e.value.$2,
                    style: AppTextStyles.bodyMD
                        .copyWith(color: AppColors.textPrimary),
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

  String _fmt(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
}
