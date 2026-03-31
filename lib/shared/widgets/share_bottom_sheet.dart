import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:docusense/core/theme/app_theme.dart';
import 'package:docusense/features/documents/data/models/document_model.dart';

class ShareBottomSheet extends StatefulWidget {
  final DocumentModel doc;

  const ShareBottomSheet({required this.doc});

  @override
  State<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  bool isCopySuccess = false;
  bool isSharing = false;
  String? error;

  String get deepLink =>
      "docusense://documents/${widget.doc.id}";

  String get webLink =>
      "https://app.docusense.app/d/${widget.doc.id}";

  Future<void> _copyLink() async {
    final link = "$deepLink\n$webLink";

    await Clipboard.setData(ClipboardData(text: link));

    setState(() => isCopySuccess = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Link copied"),
        duration: Duration(milliseconds: 1400),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => isCopySuccess = false);
      }
    });
  }

  Future<void> _shareFile() async {
    setState(() {
      isSharing = true;
      error = null;
    });

    try {
      final dio = Dio();

      final dir = await getTemporaryDirectory();
      final ext = _extensionFromMime(widget.doc.mimeType);
      final fileName = "${widget.doc.title}.$ext";
      final path = "${dir.path}/$fileName";

      final response = await dio.get(
        "YOUR_API/files/${widget.doc.resolvedStorageKey}",
        options: Options(responseType: ResponseType.bytes),
      );

      final file = File(path);
      await file.writeAsBytes(response.data);

      await Share.shareXFiles(
        [XFile(path)],
        text: widget.doc.title,
      );
    } catch (e) {
      setState(() {
        error = "Failed to share file";
      });
    } finally {
      if (mounted) {
        setState(() => isSharing = false);
      }
    }
  }

  String _extensionFromMime(String mime) {
    if (mime.contains("pdf")) return "pdf";
    if (mime.contains("image")) return "jpg";
    if (mime.contains("word")) return "docx";
    if (mime.contains("text")) return "txt";
    return "file";
  }

  Widget _row({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool loading = false,
    bool success = false,
  }) {
    return InkWell(
      onTap: loading ? null : onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.border,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              success ? Icons.check_rounded : icon,
              size: 18,
              color: success
                  ? AppColors.success
                  : AppColors.textPrimary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMD,
              ),
            ),
            if (loading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(Icons.chevron_right, size: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.doc;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // drag handle
              Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  doc.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.monoSM,
                ),
              ),

              const SizedBox(height: 12),

              // Copy link
              _row(
                icon: Icons.link_rounded,
                label: "Copy link",
                onTap: _copyLink,
                success: isCopySuccess,
              ),

              // Share file
              _row(
                icon: Icons.ios_share_rounded,
                label: "Share file",
                onTap: _shareFile,
                loading: isSharing,
              ),

              if (error != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      error!,
                      style: AppTextStyles.bodyMD
                          .copyWith(color: AppColors.error),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}