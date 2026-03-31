import 'package:docusense/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../providers/documents_provider.dart';
import '../../data/models/document_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SHARE BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────

class ShareBottomSheet extends ConsumerStatefulWidget {
  final DocumentModel doc;
  const ShareBottomSheet({super.key, required this.doc});

  @override
  ConsumerState<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends ConsumerState<ShareBottomSheet> {
  bool _linkCopied = false;
  bool _shareLoading = false;

  Future<void> _copyLink() async {
    final link = 'docusense://documents/${widget.doc.id}';
    await Clipboard.setData(ClipboardData(text: link));
    setState(() => _linkCopied = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _linkCopied = false);
  }

  Future<void> _shareFile() async {
    setState(() => _shareLoading = true);
    // In production: fetch file bytes then Share.shareXFiles(...)
    // Requires share_plus: ^7.2.1
    await Future.delayed(const Duration(milliseconds: 800)); // mock
    if (mounted) {
      setState(() => _shareLoading = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        _stitchSnack('Share sheet — wire share_plus package'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _StitchSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _DocTypeIcon(mimeType: widget.doc.mimeType, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.doc.title,
                    style: AppTextStyles.headingSM,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 0.5),
          _SheetRow(
            icon: _linkCopied
                ? Icons.check_rounded
                : Icons.link_rounded,
            iconColor: _linkCopied ? AppColors.green : null,
            label: _linkCopied ? 'Link copied!' : 'Copy deep link',
            labelColor: _linkCopied ? AppColors.green : null,
            onTap: _copyLink,
          ),
          const Divider(height: 0.5),
          _SheetRow(
            icon: Icons.ios_share_rounded,
            label: 'Share file',
            isLoading: _shareLoading,
            onTap: _shareFile,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DOCUMENT ACTIONS SHEET (3-dot menu)
// ─────────────────────────────────────────────────────────────────────────────

class DocumentActionsSheet extends ConsumerWidget {
  final DocumentModel doc;
  const DocumentActionsSheet({super.key, required this.doc});

  void _pop(BuildContext ctx) => Navigator.pop(ctx);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _StitchSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                Text(
                  doc.fileName,
                  style: AppTextStyles.monoSM,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Divider(height: 0.5),
          _SheetRow(
            icon: Icons.edit_outlined,
            label: 'Rename',
            onTap: () {
              _pop(context);
              Future.delayed(const Duration(milliseconds: 120), () {
                if (context.mounted) _showRenameDialog(context, ref, doc);
              });
            },
          ),
          const Divider(height: 0.5),
          _SheetRow(
            icon: Icons.label_outline_rounded,
            label: 'Edit tags',
            onTap: () {
              _pop(context);
              Future.delayed(const Duration(milliseconds: 120), () {
                if (context.mounted) _showTagsSheet(context, ref, doc);
              });
            },
          ),
          const Divider(height: 0.5),
          _SheetRow(
            icon: Icons.download_outlined,
            label: 'Save to device',
            onTap: () {
              _pop(context);
              Future.delayed(const Duration(milliseconds: 120), () {
                if (context.mounted) _downloadFile(context, doc);
              });
            },
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('DANGER ZONE',
                  style: AppTextStyles.labelMD
                      .copyWith(color: AppColors.ink3)),
            ),
          ),
          const SizedBox(height: 4),
          const Divider(height: 0.5),
          _SheetRow(
            icon: Icons.refresh_rounded,
            label: 'Re-process',
            iconColor: AppColors.amber,
            labelColor: AppColors.amber,
            onTap: () {
              _pop(context);
              Future.delayed(const Duration(milliseconds: 120), () {
                if (context.mounted) _showReprocessDialog(context, ref, doc);
              });
            },
          ),
          const Divider(height: 0.5),
          _SheetRow(
            icon: Icons.delete_outline_rounded,
            label: 'Delete',
            iconColor: AppColors.red,
            labelColor: AppColors.red,
            onTap: () {
              _pop(context);
              Future.delayed(const Duration(milliseconds: 120), () {
                if (context.mounted) _showDeleteDialog(context, ref, doc);
              });
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION IMPLEMENTATIONS
// ─────────────────────────────────────────────────────────────────────────────

void _showRenameDialog(BuildContext ctx, WidgetRef ref, DocumentModel doc) {
  final ctrl = TextEditingController(text: doc.title);
  bool loading = false;

  showDialog(
    context: ctx,
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (_) => StatefulBuilder(
      builder: (ctx2, setState) => AlertDialog(
        backgroundColor: AppColors.surface1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.wire, width: 0.5),
        ),
        title: Text('Rename document', style: AppTextStyles.headingSM),
        content: AppTextField(
          label: 'Title',
          controller: ctrl,
          autofocus: true,
          textInputAction: TextInputAction.done,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx2),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 40),
            ),
            onPressed: loading
                ? null
                : () async {
                    final newTitle = ctrl.text.trim();
                    if (newTitle.isEmpty || newTitle == doc.title) {
                      Navigator.pop(ctx2);
                      return;
                    }
                    setState(() => loading = true);
                    try {
                      await ref
                          .read(documentsNotifierProvider.notifier)
                          .updateDocument(doc.id, title: newTitle);
                      ref.invalidate(documentByIdProvider(doc.id));
                      if (ctx2.mounted) Navigator.pop(ctx2);
                    } catch (_) {
                      setState(() => loading = false);
                    }
                  },
            child: loading
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: AppColors.void0))
                : const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

void _showTagsSheet(BuildContext ctx, WidgetRef ref, DocumentModel doc) {
  showModalBottomSheet(
    context: ctx,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _TagsEditorSheet(doc: doc, ref: ref),
  );
}

void _downloadFile(BuildContext ctx, DocumentModel doc) {
  // Production: use path_provider + dio bytes + open_file_plus
  // For now show a Stitch-styled snack with progress sim
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      backgroundColor: AppColors.surface1,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.wire, width: 0.5),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saving ${doc.fileName}',
              style: AppTextStyles.bodyMD.copyWith(color: AppColors.ink0)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            color: AppColors.signal,
            backgroundColor: AppColors.wire,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

void _showReprocessDialog(BuildContext ctx, WidgetRef ref, DocumentModel doc) {
  showDialog(
    context: ctx,
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.surface1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.wire, width: 0.5),
      ),
      title: Text('Re-process document', style: AppTextStyles.headingSM),
      content: Text(
        'This will re-run Claude extraction and rebuild the vector index. '
        'Existing search results will be replaced.',
        style: AppTextStyles.bodyMD,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.amber,
            minimumSize: const Size(120, 40),
          ),
          onPressed: () async {
            Navigator.pop(ctx);
            // Production: POST /documents/{id}/reprocess
            ref.invalidate(documentByIdProvider(doc.id));
            ScaffoldMessenger.of(ctx).showSnackBar(
              _stitchSnack('Reprocessing started'),
            );
          },
          child: const Text('Re-process',
              style: TextStyle(color: AppColors.void0)),
        ),
      ],
    ),
  );
}

void _showDeleteDialog(BuildContext ctx, WidgetRef ref, DocumentModel doc) {
  bool loading = false;
  showDialog(
    context: ctx,
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (_) => StatefulBuilder(
      builder: (ctx2, setState) => AlertDialog(
        backgroundColor: AppColors.surface1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.red.withOpacity(0.3), width: 0.5),
        ),
        title: Text('Delete document', style: AppTextStyles.headingSM),
        content: Text(
          '"${doc.title}" will be permanently deleted including all search '
          'index chunks. This cannot be undone.',
          style: AppTextStyles.bodyMD,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx2),
            child: Text('Cancel',
                style: AppTextStyles.bodyMD
                    .copyWith(color: AppColors.ink1)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              minimumSize: const Size(80, 40),
            ),
            onPressed: loading
                ? null
                : () async {
                    setState(() => loading = true);
                    try {
                      await ref
                          .read(documentsNotifierProvider.notifier)
                          .deleteDocument(doc.id);
                      ref.invalidate(documentsNotifierProvider);
                      if (ctx2.mounted) {
                        Navigator.pop(ctx2);
                        ctx.go(AppRoutes.documents);
                      }
                    } catch (_) {
                      setState(() => loading = false);
                    }
                  },
            child: loading
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: AppColors.void0))
                : const Text('Delete',
                    style: TextStyle(color: AppColors.void0)),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// TAGS EDITOR SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _TagsEditorSheet extends StatefulWidget {
  final DocumentModel doc;
  final WidgetRef ref;
  const _TagsEditorSheet({required this.doc, required this.ref});

  @override
  State<_TagsEditorSheet> createState() => _TagsEditorSheetState();
}

class _TagsEditorSheetState extends State<_TagsEditorSheet> {
  late List<String> _tags;
  final _ctrl = TextEditingController();
  bool _saving = false;
  String? _tagError;

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.doc.tags);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _addTag(String raw) {
    final tag = raw.toLowerCase().trim().replaceAll(',', '');
    if (tag.isEmpty) return;
    if (tag.length > 30) {
      setState(() => _tagError = 'Max 30 chars');
      return;
    }
    if (_tags.length >= 8) {
      setState(() => _tagError = 'Max 8 tags');
      return;
    }
    if (_tags.contains(tag)) {
      setState(() => _tagError = 'Already added');
      return;
    }
    setState(() { _tags.add(tag); _tagError = null; });
    _ctrl.clear();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.ref
          .read(documentsNotifierProvider.notifier)
          .updateDocument(widget.doc.id, tags: _tags);
      widget.ref.invalidate(documentByIdProvider(widget.doc.id));
      if (mounted) Navigator.pop(context);
    } catch (_) {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _StitchSheet(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHandle(),
            const SizedBox(height: 16),
            Text('Edit tags', style: AppTextStyles.headingSM),
            const SizedBox(height: 16),

            // Tag chips
            if (_tags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) => _TagChip(
                  label: tag,
                  onRemove: () => setState(() => _tags.remove(tag)),
                )).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: AppTextStyles.bodyMD
                        .copyWith(color: AppColors.ink0),
                    cursorColor: AppColors.signal,
                    decoration: InputDecoration(
                      hintText: 'Add tag, press Enter...',
                      hintStyle: AppTextStyles.bodyMD
                          .copyWith(color: AppColors.ink3),
                      errorText: _tagError,
                    ),
                    onSubmitted: _addTag,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) =>
                        setState(() => _tagError = null),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _addTag(_ctrl.text),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.signalTrace,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppColors.signal.withOpacity(0.3),
                          width: 0.5),
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: AppColors.signal, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            GlowButton(
              onPressed: _saving ? null : _save,
              isLoading: _saving,
              child: const Text('Save tags'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _TagChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.signalTrace,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
            color: AppColors.signal.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('#$label', style: AppTextStyles.monoSM),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded,
                size: 12, color: AppColors.ink2),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED PRIMITIVES
// ─────────────────────────────────────────────────────────────────────────────

class _StitchSheet extends StatelessWidget {
  final Widget child;
  const _StitchSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: AppColors.wire, width: 0.5),
          left: BorderSide(color: AppColors.wire, width: 0.5),
          right: BorderSide(color: AppColors.wire, width: 0.5),
        ),
      ),
      child: child,
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      margin: const EdgeInsets.only(top: 10),
      width: 32,
      height: 3,
      decoration: BoxDecoration(
        color: AppColors.wireHot,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

class _SheetRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? labelColor;
  final bool isLoading;

  const _SheetRow({
    required this.icon,
    required this.label,
    this.onTap,
    this.iconColor,
    this.labelColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            isLoading
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 1.5, color: AppColors.signal))
                : Icon(icon,
                    color: iconColor ?? AppColors.ink1, size: 18),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLG.copyWith(
                  color: labelColor ?? AppColors.ink0,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.ink3, size: 16),
          ],
        ),
      ),
    );
  }
}

class _DocTypeIcon extends StatelessWidget {
  final String mimeType;
  final double size;
  const _DocTypeIcon({required this.mimeType, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final isPdf  = mimeType.contains('pdf');
    final isImg  = mimeType.contains('image');
    final color  = isPdf ? AppColors.red
                 : isImg ? AppColors.signal
                 : AppColors.amber;
    final icon   = isPdf ? Icons.picture_as_pdf_outlined
                 : isImg ? Icons.image_outlined
                 : Icons.description_outlined;
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

SnackBar _stitchSnack(String msg) => SnackBar(
  backgroundColor: AppColors.surface1,
  behavior: SnackBarBehavior.floating,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
    side: const BorderSide(color: AppColors.wire, width: 0.5),
  ),
  content: Text(msg,
      style: AppTextStyles.bodyMD.copyWith(color: AppColors.ink0)),
  duration: const Duration(seconds: 2),
);
