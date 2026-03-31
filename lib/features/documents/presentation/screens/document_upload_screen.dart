import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lottie/lottie.dart';
import 'package:docusense/core/theme/app_theme.dart';
import 'package:docusense/core/constants/app_constants.dart';
import 'package:docusense/shared/widgets/app_widgets.dart';

part 'document_upload_screen.g.dart';

// ── Upload state ──────────────────────────────────────────────────────────────

enum UploadPhase { idle, picked, uploading, processing, success, failed }

class UploadState {
  final UploadPhase phase;
  final PlatformFile? file;
  final double progress; // 0.0 → 1.0
  final String? processingStep; // shown during AI ingestion
  final String? error;
  final String? jobId;

  const UploadState({
    this.phase = UploadPhase.idle,
    this.file,
    this.progress = 0,
    this.processingStep,
    this.error,
    this.jobId,
  });

  UploadState copyWith({
    UploadPhase? phase,
    PlatformFile? file,
    double? progress,
    String? processingStep,
    String? error,
    String? jobId,
    bool clearFile = false,
    bool clearError = false,
  }) =>
      UploadState(
        phase: phase ?? this.phase,
        file: clearFile ? null : (file ?? this.file),
        progress: progress ?? this.progress,
        processingStep: processingStep ?? this.processingStep,
        error: clearError ? null : (error ?? this.error),
        jobId: jobId ?? this.jobId,
      );
}

@riverpod
class UploadNotifier extends _$UploadNotifier {
  @override
  UploadState build() => const UploadState();

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'txt', 'docx'],
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;

      // Validate size (50 MB)
      if ((file.size) > 50 * 1024 * 1024) {
        state = state.copyWith(
          phase: UploadPhase.failed,
          error: 'File exceeds the 50 MB limit.',
        );
        return;
      }

      state = state.copyWith(phase: UploadPhase.picked, file: file);
    } catch (e) {
      state = state.copyWith(
        phase: UploadPhase.failed,
        error: 'Could not open file picker.',
      );
    }
  }

  Future<void> upload() async {
    if (state.file == null) return;

    // ── Simulated upload + processing ────────────────────────────────────────
    // Replace the blocks below with real Dio multipart call:
    //
    //   final formData = FormData.fromMap({
    //     'file': MultipartFile.fromBytes(state.file!.bytes!, filename: state.file!.name),
    //   });
    //   final response = await ref.read(dioClientProvider).post('/documents', data: formData,
    //     onSendProgress: (sent, total) {
    //       state = state.copyWith(progress: sent / total * 0.6);
    //     });
    //   final jobId = response.data['data']['jobId'];
    //   // then poll /documents/jobs/:jobId/status

    // Phase 1: Uploading file
    state = state.copyWith(phase: UploadPhase.uploading, progress: 0);

    for (int i = 1; i <= 60; i++) {
      await Future.delayed(const Duration(milliseconds: 25));
      state = state.copyWith(progress: i / 100);
    }

    // Phase 2: AI processing steps
    state = state.copyWith(phase: UploadPhase.processing, progress: 0.6);
    final steps = [
      'Extracting text content...',
      'Analyzing document structure...',
      'Running Claude extraction...',
      'Generating embeddings...',
      'Building search index...',
    ];

    for (int i = 0; i < steps.length; i++) {
      state = state.copyWith(
        processingStep: steps[i],
        progress: 0.6 + (i + 1) / steps.length * 0.38,
      );
      await Future.delayed(const Duration(milliseconds: 700));
    }

    state = state.copyWith(
      phase: UploadPhase.success,
      progress: 1.0,
      jobId: 'job_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  void reset() {
    state = const UploadState();
  }

  void clearError() {
    state = state.copyWith(
      phase: UploadPhase.idle,
      clearError: true,
      clearFile: true,
    );
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class DocumentUploadScreen extends ConsumerWidget {
  const DocumentUploadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upload = ref.watch(uploadNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.void1,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Upload Document',
          style: AppTextStyles.headingSM,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: AppConstants.standardDuration,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
              child: child,
            ),
          ),
          child: switch (upload.phase) {
            UploadPhase.idle => _IdleView(key: const ValueKey('idle')),
            UploadPhase.picked => _PickedView(
                key: const ValueKey('picked'),
                file: upload.file!,
              ),
            UploadPhase.uploading ||
            UploadPhase.processing =>
              _ProgressView(key: const ValueKey('progress'), upload: upload),
            UploadPhase.success => _SuccessView(
                key: const ValueKey('success'),
                file: upload.file!,
              ),
            UploadPhase.failed => _FailedView(
                key: const ValueKey('failed'),
                error: upload.error ?? 'Upload failed',
              ),
          },
        ),
      ),
    );
  }
}

// ── Idle state — drop zone ────────────────────────────────────────────────────

class _IdleView extends ConsumerWidget {
  const _IdleView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Drop zone
          GestureDetector(
            onTap: () => ref.read(uploadNotifierProvider.notifier).pickFile(),
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface0,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent, width: 1.2),
              ),
              child: Center(
                child: Column(
                  children: [
                    Lottie.asset(
                      'assets/lottie/upload-drop-zone.json',
                      height: 120,
                      repeat: true,
                    ),
                    Text(
                      'Tap to browse files or drop your document here',
                      style: AppTextStyles.monoSM,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: 100.ms).scale(
                begin: const Offset(0.96, 0.96),
                curve: Curves.easeOutCubic,
              ),

          const SizedBox(height: 32),

          // Supported types
          Text(
            'SUPPORTED FORMATS',
            style: AppTextStyles.labelMD,
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 16),

          const Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _FormatBadge(
                ext: 'PDF',
                icon: Icons.picture_as_pdf_outlined,
                color: AppColors.error,
              ),
              _FormatBadge(
                ext: 'PNG',
                icon: Icons.image_outlined,
                color: AppColors.info,
              ),
              _FormatBadge(
                  ext: 'JPG',
                  icon: Icons.image_outlined,
                  color: AppColors.info),
              _FormatBadge(
                  ext: 'DOCX',
                  icon: Icons.description_outlined,
                  color: AppColors.accent),
              _FormatBadge(
                  ext: 'TXT',
                  icon: Icons.article_outlined,
                  color: AppColors.amber),
            ],
          ).animate().fadeIn(delay: 280.ms),

// Removed misplaced Image.asset and textAlign from children list.
        ],
      ),
    );
  }
}

class _DropZone extends StatefulWidget {
  final VoidCallback onTap;
  const _DropZone({required this.onTap});

  @override
  State<_DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<_DropZone>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _hovering = true),
      onTapUp: (_) => setState(() => _hovering = false),
      onTapCancel: () => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: AppConstants.microDuration,
        height: 260,
        decoration: BoxDecoration(
          color: _hovering ? AppColors.accentFaint : AppColors.surface0,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovering ? AppColors.accent : AppColors.border,
            width: _hovering ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Animated corner accents
            ..._corners(),

            // Center content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pulsing upload icon container
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, __) => Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.accent
                            .withOpacity(0.06 + _pulse.value * 0.06),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.accent
                              .withOpacity(0.2 + _pulse.value * 0.15),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.cloud_upload_outlined,
                        color: AppColors.accent,
                        size: 36,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Tap to browse files',
                    style: AppTextStyles.headingSM,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'or drop your document here',
                    style: AppTextStyles.bodyMD,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _corners() {
    const size = 20.0;
    const thickness = 2.0;
    final color = AppColors.accent.withOpacity(0.4);

    Widget corner(Alignment alignment, double rotationDeg) {
      return Positioned(
        top: alignment.y < 0 ? 12 : null,
        bottom: alignment.y > 0 ? 12 : null,
        left: alignment.x < 0 ? 12 : null,
        right: alignment.x > 0 ? 12 : null,
        child: Transform.rotate(
          angle: rotationDeg * math.pi / 180,
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _CornerPainter(color: color, thickness: thickness),
            ),
          ),
        ),
      );
    }

    return [
      corner(Alignment.topLeft, 0),
      corner(Alignment.topRight, 90),
      corner(Alignment.bottomRight, 180),
      corner(Alignment.bottomLeft, 270),
    ];
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  const _CornerPainter({required this.color, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) =>
      old.color != color || old.thickness != thickness;
}

class _FormatBadge extends StatelessWidget {
  final String ext;
  final IconData icon;
  final Color color;

  const _FormatBadge({
    required this.ext,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            ext,
            style: AppTextStyles.monoSM.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ── Picked state — file preview + confirm ─────────────────────────────────────

class _PickedView extends ConsumerWidget {
  final PlatformFile file;
  const _PickedView({super.key, required this.file});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ext = file.extension?.toUpperCase() ?? 'FILE';
    final sizeMb = (file.size / (1024 * 1024)).toStringAsFixed(2);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // File card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface0,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                // File type icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      ext,
                      style: AppTextStyles.monoSM.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name,
                        style: AppTextStyles.headingSM,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$sizeMb MB',
                        style: AppTextStyles.bodyMD,
                      ),
                    ],
                  ),
                ),

                // Re-pick
                IconButton(
                  icon: const Icon(
                    Icons.swap_horiz_rounded,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  onPressed: () =>
                      ref.read(uploadNotifierProvider.notifier).pickFile(),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

          const SizedBox(height: 20),

          // What happens next
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentFaint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What happens next',
                  style:
                      AppTextStyles.headingSM.copyWith(color: AppColors.accent),
                ),
                const SizedBox(height: 12),
                ...[
                  (
                    'Claude extracts structure, entities & dates',
                    Icons.auto_awesome_outlined
                  ),
                  (
                    'Text is chunked & embedded via Voyage AI',
                    Icons.hub_outlined
                  ),
                  (
                    'HNSW vector index built for instant search',
                    Icons.search_rounded
                  ),
                ].map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Icon(item.$2, color: AppColors.accentDim, size: 16),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(item.$1, style: AppTextStyles.bodyMD),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 150.ms, duration: 400.ms)
              .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

          const Spacer(),

          // Upload CTA
          GlowButton(
            onPressed: () => ref.read(uploadNotifierProvider.notifier).upload(),
            child: const Text('Upload & Process'),
          )
              .animate()
              .fadeIn(delay: 280.ms, duration: 400.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 12),

          Center(
            child: TextButton(
              onPressed: () =>
                  ref.read(uploadNotifierProvider.notifier).reset(),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyMD
                    .copyWith(color: AppColors.textTertiary),
              ),
            ),
          ).animate().fadeIn(delay: 330.ms),
        ],
      ),
    );
  }
}

// ── Progress state ────────────────────────────────────────────────────────────

class _ProgressView extends StatelessWidget {
  final UploadState upload;
  const _ProgressView({super.key, required this.upload});

  @override
  Widget build(BuildContext context) {
    final isProcessing = upload.phase == UploadPhase.processing;
    final pct = (upload.progress * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Lottie progress animation (centered)
          Center(
            child: Lottie.asset(
              'assets/lottie/upload-progress.json',
              height: 320,
              repeat: true,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            isProcessing ? 'Processing' : 'Uploading',
            style: AppTextStyles.headingMD,
          ).animate(key: ValueKey(upload.phase)).fadeIn(),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: AppConstants.standardDuration,
            child: Text(
              upload.processingStep ??
                  '${upload.file?.name ?? ''}'.truncate(40),
              key: ValueKey(upload.processingStep),
              style: AppTextStyles.bodyMD,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitRing extends StatefulWidget {
  final bool isProcessing;
  const _OrbitRing({required this.isProcessing});

  @override
  State<_OrbitRing> createState() => _OrbitRingState();
}

class _OrbitRingState extends State<_OrbitRing> with TickerProviderStateMixin {
  late AnimationController _rotate;
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _rotate = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotate.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotate, _pulse]),
      builder: (_, __) => SizedBox(
        width: 120,
        height: 120,
        child: CustomPaint(
          painter: _OrbitPainter(
            rotation: _rotate.value,
            pulse: _pulse.value,
            isProcessing: widget.isProcessing,
          ),
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final double rotation;
  final double pulse;
  final bool isProcessing;

  const _OrbitPainter({
    required this.rotation,
    required this.pulse,
    required this.isProcessing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 4;

    // Outer glow ring
    final glowPaint = Paint()
      ..color = AppColors.accent.withOpacity(0.06 + pulse * 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;
    canvas.drawCircle(Offset(cx, cy), r, glowPaint);

    // Track ring
    final trackPaint = Paint()
      ..color = AppColors.surface2
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(cx, cy), r, trackPaint);

    // Arc
    final arcPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      rotation * 2 * math.pi - math.pi / 2,
      isProcessing ? math.pi * 1.5 : math.pi * 0.8,
      false,
      arcPaint,
    );

    // Center icon
    final iconPaint = Paint()
      ..color = AppColors.accent.withOpacity(0.8 + pulse * 0.2)
      ..style = PaintingStyle.fill;

    if (isProcessing) {
      // AI sparkle dots
      for (int i = 0; i < 3; i++) {
        final angle = rotation * 2 * math.pi + i * 2 * math.pi / 3;
        final dotR = 5.0 + pulse * 2;
        final ox = cx + math.cos(angle) * 14;
        final oy = cy + math.sin(angle) * 14;
        canvas.drawCircle(
          Offset(ox, oy),
          dotR * (i == 0 ? 1.0 : 0.6),
          iconPaint..color = AppColors.accent.withOpacity(i == 0 ? 1.0 : 0.5),
        );
      }
    } else {
      // Upload arrow
      final arrowPaint = Paint()
        ..color = AppColors.accent
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(cx, cy + 10), Offset(cx, cy - 10), arrowPaint);
      canvas.drawLine(Offset(cx - 7, cy - 3), Offset(cx, cy - 10), arrowPaint);
      canvas.drawLine(Offset(cx + 7, cy - 3), Offset(cx, cy - 10), arrowPaint);
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => true;
}

// ── Success state ─────────────────────────────────────────────────────────────

class _SuccessView extends ConsumerWidget {
  final PlatformFile file;
  const _SuccessView({super.key, required this.file});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/upload-success.json',
            height: 300,
            repeat: false,
          ),
          const SizedBox(height: 32),
          Text('Document uploaded!', style: AppTextStyles.displayMD)
              .animate()
              .fadeIn(delay: 300.ms)
              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
          const SizedBox(height: 8),
          Text(
            'AI is indexing "${file.name.truncate(36)}".\nYou\'ll be able to search it in seconds.',
            style: AppTextStyles.bodyLG,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 48),
          // Processing status indicator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface0,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Claude is analyzing your document...',
                  style: AppTextStyles.bodyMD,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 40),
          // CTAs
          GlowButton(
            onPressed: () {
              ref.read(uploadNotifierProvider.notifier).reset();
              context.go(AppRoutes.documents);
            },
            child: const Text('View Documents'),
          ).animate().fadeIn(delay: 600.ms),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () => ref.read(uploadNotifierProvider.notifier).reset(),
            child: Text(
              'Upload another',
              style:
                  AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary),
            ),
          ).animate().fadeIn(delay: 700.ms),
        ],
      ),
    );
  }
}

// ── Failed state ──────────────────────────────────────────────────────────────

class _FailedView extends ConsumerWidget {
  final String error;
  const _FailedView({super.key, required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/upload-error.json',
            height: 300,
            repeat: false,
          ),
          const SizedBox(height: 28),
          Text('Upload failed', style: AppTextStyles.displayMD)
              .animate()
              .fadeIn(delay: 200.ms),
          const SizedBox(height: 10),
          Text(error, style: AppTextStyles.bodyLG, textAlign: TextAlign.center)
              .animate()
              .fadeIn(delay: 280.ms),
          const SizedBox(height: 48),
          GlowButton(
            onPressed: () =>
                ref.read(uploadNotifierProvider.notifier).clearError(),
            color: AppColors.error,
            child: const Text('Try Again'),
          ).animate().fadeIn(delay: 360.ms),
        ],
      ),
    );
  }
}

// ── Extensions ────────────────────────────────────────────────────────────────

extension _StringX on String {
  String truncate(int max) => length <= max ? this : '${substring(0, max)}...';
}

// Pull AppRoutes in (it's defined in constants)
class AppRoutes {
  static const documents = '/documents';
}
