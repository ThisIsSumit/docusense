import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../providers/documents_provider.dart';
import '../../data/models/document_model.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  final _scrollController = ScrollController();
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final pos = _scrollController.position;
    final threshold =
        pos.maxScrollExtent - AppConstants.prefetchThreshold * 120.0;
    if (pos.pixels >= threshold) {
      ref.read(documentsNotifierProvider.notifier).onScrolledNearEnd();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(documentsNotifierProvider);

    final filtered = _filter == 'all'
        ? state.items
        : state.items.where((d) {
            if (_filter == 'pdf') return d.type == DocumentType.pdf;
            if (_filter == 'image') return d.type == DocumentType.image;
            if (_filter == 'processing') {
              return d.status == DocumentStatus.processing;
            }
            return true;
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.void1,
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.surface1,
        onRefresh: () =>
            ref.read(documentsNotifierProvider.notifier).refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.void1,
              expandedHeight: 100,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Documents',
                          style: AppTextStyles.displayMD),
                      Text('${state.items.length}',
                          style: AppTextStyles.monoMD),
                    ],
                  ),
                ),
              ),
            ),

            // Filter chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _FilterChip(label: 'All', value: 'all', current: _filter,
                        onTap: (v) => setState(() => _filter = v)),
                    _FilterChip(label: 'PDF', value: 'pdf', current: _filter,
                        onTap: (v) => setState(() => _filter = v)),
                    _FilterChip(label: 'Images', value: 'image', current: _filter,
                        onTap: (v) => setState(() => _filter = v)),
                    _FilterChip(label: 'Processing', value: 'processing', current: _filter,
                        onTap: (v) => setState(() => _filter = v)),
                  ],
                ),
              ).animate().fadeIn(delay: 150.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Loading state
            if (state.isLoading)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: _DocumentListTileSkeleton(),
                  ),
                  childCount: 8,
                ),
              )
            else if (filtered.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_open_outlined,
                          color: AppColors.textTertiary, size: 48),
                      SizedBox(height: 16),
                      Text('No documents',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontFamily: 'Syne',
                            fontSize: 16,
                          )),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    if (i == filtered.length) {
                      return state.isLoadingMore
                          ? const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                            )
                          : state.hasMore
                              ? const SizedBox(height: 40)
                              : const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Center(
                                    child: Text('All documents loaded',
                                        style: TextStyle(
                                          color: AppColors.textTertiary,
                                          fontFamily: 'JetBrainsMono',
                                          fontSize: 11,
                                        )),
                                  ),
                                );
                    }
                    final doc = filtered[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: _DocumentListTile(
                        doc: doc,
                        onTap: () => context.push('/documents/${doc.id}'),
                        onDelete: () => ref
                            .read(documentsNotifierProvider.notifier)
                            .deleteDocument(doc.id),
                      )
                          .animate()
                          .fadeIn(
                            delay: Duration(
                                milliseconds: 50 * (i % 10)),
                          )
                          .slideX(
                            begin: 0.04,
                            end: 0,
                            delay: Duration(milliseconds: 50 * (i % 10)),
                            curve: Curves.easeOutCubic,
                          ),
                    );
                  },
                  childCount: filtered.length + 1,
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.upload),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.void0,
        elevation: 0,
        child: const Icon(Icons.add_rounded),
      ).animate().scale(
            delay: 400.ms,
            duration: 400.ms,
            curve: const Cubic(0.34, 1.56, 0.64, 1),
          ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final void Function(String) onTap;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = value == current;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: AppConstants.microDuration,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.accent.withOpacity(0.12) : AppColors.surface0,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLG.copyWith(
            color: active ? AppColors.accent : AppColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _DocumentListTile extends StatelessWidget {
  final DocumentModel doc;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DocumentListTile({
    required this.doc,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(doc.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.error, size: 22),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface0,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _typeColor(doc.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_typeIcon(doc.type),
                    color: _typeColor(doc.type), size: 20),
              ),
              const SizedBox(width: 14),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc.title,
                        style: AppTextStyles.headingSM,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(doc.displaySize, style: AppTextStyles.bodySM),
                        const SizedBox(width: 6),
                        const Text('·',
                            style: TextStyle(color: AppColors.textTertiary)),
                        const SizedBox(width: 6),
                        Text('${doc.pageCount}p',
                            style: AppTextStyles.bodySM),
                        if (doc.tags.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          const Text('·',
                              style:
                                  TextStyle(color: AppColors.textTertiary)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              doc.tags.first,
                              style: AppTextStyles.monoSM,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textTertiary, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  IconData _typeIcon(DocumentType t) {
    switch (t) {
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

  Color _typeColor(DocumentType t) {
    switch (t) {
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
}

class _DocumentListTileSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ShimmerBox(width: 40, height: 40, borderRadius: BorderRadius.circular(8)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: double.infinity, height: 13),
                const SizedBox(height: 8),
                ShimmerBox(width: 100, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
