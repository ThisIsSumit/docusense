import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

import 'package:docusense/core/theme/app_theme.dart';
import 'package:docusense/shared/widgets/app_widgets.dart';
import 'package:docusense/features/documents/data/models/document_model.dart';
import 'package:docusense/features/documents/presentation/providers/documents_provider.dart';

class DocumentActionsSheet extends ConsumerWidget {
  final DocumentModel doc;
  final WidgetRef ref;
  final String documentId;

  const DocumentActionsSheet({
    required this.doc,
    required this.ref,
    required this.documentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget action({
      required IconData icon,
      required String label,
      Color? color,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: () {
          context.pop();
          Future.delayed(const Duration(milliseconds: 120), onTap);
        },
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color ?? AppColors.textPrimary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMD.copyWith(color: color),
                ),
              ),
              const Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.void2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentFaint,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        doc.mimeType.split('/').last.toUpperCase(),
                        style: AppTextStyles.monoSM,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        doc.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.monoSM,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              const Divider(height: 0.5),

              // normal actions
              action(
                icon: Icons.edit_outlined,
                label: "Rename",
                onTap: () => _rename(context),
              ),
              const Divider(height: 0.5),
              action(
                icon: Icons.label_outline,
                label: "Edit tags",
                onTap: () => _editTags(context),
              ),
              const Divider(height: 0.5),
              action(
                icon: Icons.download_outlined,
                label: "Save to device",
                onTap: () => _download(context),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Danger zone",
                    style: AppTextStyles.labelLG
                        .copyWith(color: AppColors.textTertiary),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              action(
                icon: Icons.refresh_rounded,
                label: "Re-process",
                color: AppColors.accentAmber,
                onTap: () => _reprocess(context),
              ),
              const Divider(height: 0.5),
              action(
                icon: Icons.delete_outline_rounded,
                label: "Delete",
                color: AppColors.error,
                onTap: () => _delete(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // 1. RENAME
  // =========================
  void _rename(BuildContext context) {
    final controller = TextEditingController(text: doc.title);
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            final text = controller.text.trim();

            return AlertDialog(
              title: const Text("Rename document"),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "Enter new title",
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: (text.isEmpty || text.length > 255 || isLoading)
                      ? null
                      : () async {
                          setState(() => isLoading = true);
                          // Use provider notifier for update
                          // You may need to add an update method to DocumentsNotifier if not present
                          // await ref
                          //     .read(documentsNotifierProvider.notifier)
                          //     .updateDocumentTitle(doc.id, text);
                          ref.invalidate(documentByIdProvider(documentId));
                          context.pop();
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =========================
  // 2. TAGS
  // =========================
  void _editTags(BuildContext context) {
    final tags = [...doc.tags];
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          void addTag(String value) {
            final t = value.trim().toLowerCase();
            if (t.isEmpty || t.length > 30 || tags.length >= 8) return;
            if (!tags.contains(t)) {
              setState(() => tags.add(t));
            }
            controller.clear();
          }

          return Padding(
            padding: MediaQuery.of(ctx).viewInsets,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 8,
                    children: tags
                        .map((tag) => Chip(
                              label: Text(tag),
                              onDeleted: () => setState(() => tags.remove(tag)),
                            ))
                        .toList(),
                  ),
                  TextField(
                    controller: controller,
                    onSubmitted: addTag,
                    decoration: const InputDecoration(hintText: "Add tag"),
                  ),
                  const SizedBox(height: 12),
                  GlowButton(
                    onPressed: () async {
                      // await ref
                      //     .read(documentsNotifierProvider.notifier)
                      //     .updateDocumentTags(doc.id, tags);
                      ref.invalidate(documentByIdProvider(documentId));
                      context.pop();
                    },
                    child: const Text("Save tags"),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  // =========================
  // 3. DOWNLOAD
  // =========================
  Future<void> _download(BuildContext context) async {
    final dio = Dio();

    final dir = Platform.isAndroid
        ? await getDownloadsDirectory()
        : await getApplicationDocumentsDirectory();

    final path = "${dir!.path}/${doc.fileName}";

    final response = await dio.get(
      "YOUR_API/files/${doc.storageKey}",
      options: Options(responseType: ResponseType.bytes),
      onReceiveProgress: (rec, total) {
        final progress = rec / total;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Downloading..."),
                LinearProgressIndicator(value: progress),
              ],
            ),
          ),
        );
      },
    );

    final file = File(path);
    await file.writeAsBytes(response.data);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Saved to Downloads"),
        action: SnackBarAction(
          label: "Open",
          onPressed: () => OpenFile.open(path),
        ),
      ),
    );
  }

  // =========================
  // 4. REPROCESS
  // =========================
  void _reprocess(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Re-process document"),
        content: const Text("This will rebuild the vector index. Continue?"),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              // await ref
              //     .read(documentsNotifierProvider.notifier)
              //     .reprocessDocument(doc.id);
              ref.invalidate(documentByIdProvider(documentId));
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Reprocessing started")),
              );
            },
            child: const Text("Re-process"),
          ),
        ],
      ),
    );
  }

  // =========================
  // 5. DELETE
  // =========================
  void _delete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.void1,
        title: Text(
          "Delete document",
          style: AppTextStyles.headingMD,
        ),
        content: Text(
          '"${doc.title}" will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () async {
              await ref
                  .read(documentsNotifierProvider.notifier)
                  .deleteDocument(doc.id);
              ref.invalidate(documentsNotifierProvider);
              context.go("/documents");
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
