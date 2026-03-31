import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../documents/presentation/providers/documents_provider.dart';
import '../../../documents/data/models/document_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateNotifierProvider).valueOrNull?.user;
    final docsState = ref.watch(documentsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.void1,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.void1,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good ${_greeting()},',
                      style: AppTextStyles.bodyMD,
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 4),
                    Text(
                      user?.name.split(' ').first ?? 'User',
                      style: AppTextStyles.displayMD,
                    )
                        .animate()
                        .fadeIn(delay: 150.ms)
                        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surface1,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
                onPressed: () => context.push(AppRoutes.upload),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(width: 8),
            ],
          ),

          // Stats row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _StatsRow(
                docs: user?.documentsCount ?? 0,
                queries: user?.queriesCount ?? 0,
              ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1, end: 0),
            ),
          ),

          // Section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Documents',
                      style: AppTextStyles.headingSM),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.documents),
                    child: Text('View all',
                        style: AppTextStyles.bodyMD
                            .copyWith(color: AppColors.accent)),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms),
            ),
          ),

          // Doc list
          if (docsState.isLoading)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: _DocCardSkeleton(),
                ),
                childCount: 4,
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final doc = docsState.items.take(8).toList()[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: _DocCard(doc: doc, index: i)
                        .animate()
                        .fadeIn(delay: Duration(milliseconds: 350 + i * 60))
                        .slideY(
                          begin: 0.12,
                          end: 0,
                          delay: Duration(milliseconds: 350 + i * 60),
                          curve: Curves.easeOutCubic,
                        ),
                  );
                },
                childCount: docsState.items.take(8).length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int docs;
  final int queries;

  const _StatsRow({required this.docs, required this.queries});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: docs.toString(),
            label: 'Documents',
            icon: Icons.folder_outlined,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: queries.toString(),
            label: 'Queries',
            icon: Icons.chat_bubble_outline_rounded,
            color: AppColors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: '2.4GB',
            label: 'Storage',
            icon: Icons.storage_rounded,
            color: AppColors.info,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 10),
          Text(value,
              style: AppTextStyles.headingMD.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySM),
        ],
      ),
    );
  }
}

// ── Doc Card ──────────────────────────────────────────────────────────────────

class _DocCard extends ConsumerWidget {
  final DocumentModel doc;
  final int index;

  const _DocCard({required this.doc, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconData = _iconForType(doc.type);
    final typeColor = _colorForType(doc.type);

    return GestureDetector(
      onTap: () => context.push('/documents/${doc.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface0,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // File type icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconData, color: typeColor, size: 22),
            ),

            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.title,
                    style: AppTextStyles.headingSM,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(doc.displaySize,
                          style: AppTextStyles.bodySM),
                      const SizedBox(width: 8),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: AppColors.textTertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _relativeTime(doc.createdAt),
                        style: AppTextStyles.bodySM,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Status badge
            _StatusBadge(status: doc.status),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return Icons.picture_as_pdf_outlined;
      case DocumentType.image:
        return Icons.image_outlined;
      case DocumentType.docx:
        return Icons.description_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _colorForType(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return AppColors.error;
      case DocumentType.image:
        return AppColors.info;
      case DocumentType.docx:
        return AppColors.accent;
      default:
        return AppColors.textSecondary;
    }
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}

class _StatusBadge extends StatelessWidget {
  final DocumentStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == DocumentStatus.ready) {
      return const Icon(Icons.check_circle_outline_rounded,
          color: AppColors.success, size: 18);
    }
    if (status == DocumentStatus.processing) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          color: AppColors.amber,
        ),
      );
    }
    if (status == DocumentStatus.failed) {
      return const Icon(Icons.error_outline_rounded,
          color: AppColors.error, size: 18);
    }
    return const SizedBox.shrink();
  }
}

class _DocCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ShimmerBox(width: 44, height: 44, borderRadius: BorderRadius.circular(10)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: double.infinity, height: 14),
                const SizedBox(height: 8),
                ShimmerBox(width: 120, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
