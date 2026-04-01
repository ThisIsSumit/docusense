import 'dart:math' as math;
import 'package:docusense/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../data/datasources/documents_remote_datasource.dart';
import '../providers/documents_provider.dart';
import '../../../../core/utils/dio_client.dart';

part 'document_upload_screen.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Lottie asset paths — place these files in assets/lottie/
//
//   upload_dropzone.json  — looping idle animation (cloud + arrow bounce)
//                           Recommended: lottiefiles.com/animations/upload-file
//   upload_progress.json  — looping AI scan / processing ring
//                           Recommended: lottiefiles.com/animations/loading-animation
//   upload_success.json   — one-shot check mark celebration (non-looping)
//                           Recommended: lottiefiles.com/animations/success-checkmark
//   upload_error.json     — one-shot shake / red X (non-looping)
//                           Recommended: lottiefiles.com/animations/error-animation
//
// If any asset is missing, the widget renders a built-in CustomPaint fallback
// so the screen stays functional without assets.
// ─────────────────────────────────────────────────────────────────────────────

const _kDropzoneLottie = 'assets/lottie/upload-drop-zone.json';
const _kProgressLottie = 'assets/lottie/upload-progress.json';
const _kSuccessLottie = 'assets/lottie/upload-success.json';
const _kErrorLottie = 'assets/lottie/upload-error.json';

// ── Upload state ──────────────────────────────────────────────────────────────

enum UploadPhase { idle, picked, uploading, processing, success, failed }

class UploadState {
  final UploadPhase phase;
  final PlatformFile? file;
  final double progress;
  final String? processingStep;
  final String? error;
  final String? jobId;
  final int pollProgress;

  const UploadState({
    this.phase = UploadPhase.idle,
    this.file,
    this.progress = 0,
    this.processingStep,
    this.error,
    this.jobId,
    this.pollProgress = 0,
  });

  UploadState copyWith({
    UploadPhase? phase,
    PlatformFile? file,
    double? progress,
    String? processingStep,
    String? error,
    String? jobId,
    int? pollProgress,
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
        pollProgress: pollProgress ?? this.pollProgress,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

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
      if (file.size > AppConstants.maxFileSizeMB * 1024 * 1024) {
        state = state.copyWith(
          phase: UploadPhase.failed,
          error: 'File exceeds the ${AppConstants.maxFileSizeMB} MB limit.',
        );
        return;
      }
      state = state.copyWith(phase: UploadPhase.picked, file: file);
    } catch (_) {
      state = state.copyWith(
        phase: UploadPhase.failed,
        error: 'Could not open file picker.',
      );
    }
  }

  Future<void> upload() async {
    if (state.file == null) return;

    state = state.copyWith(phase: UploadPhase.uploading, progress: 0);

    try {
      final result = await ref.read(documentsRemoteDatasourceProvider).upload(
            file: state.file!,
            onProgress: (sent, total) {
              if (total > 0) {
                state = state.copyWith(
                    progress: (sent / total * 0.60).clamp(0.0, 0.60));
              }
            },
          );

      state = state.copyWith(
        phase: UploadPhase.processing,
        progress: 0.62,
        jobId: result.jobId,
        processingStep: 'Extracting text content...',
      );

      await for (final job in ref
          .read(documentsRemoteDatasourceProvider)
          .pollJobUntilDone(result.jobId)) {
        final display = 0.62 + job.progressFraction * 0.36;
        state = state.copyWith(
          progress: display,
          processingStep: _stepLabel(job.progressFraction),
          pollProgress: job.progress.toInt(),
        );

        if (job.isCompleted) {
          ref.invalidate(documentsNotifierProvider);
          state = state.copyWith(
              phase: UploadPhase.success,
              progress: 1.0,
              processingStep: 'Ready to search');
          return;
        }
        if (job.isFailed) {
          state = state.copyWith(
              phase: UploadPhase.failed,
              error: job.failedReason ?? 'Processing failed');
          return;
        }
      }
    } on ApiException catch (e) {
      state = state.copyWith(
        phase: UploadPhase.failed,
        error: e.isConflict
            ? 'A document with this name already exists.'
            : e.message,
      );
    } catch (_) {
      state = state.copyWith(
        phase: UploadPhase.failed,
        error: 'Upload failed. Check your connection and try again.',
      );
    }
  }

  String _stepLabel(double p) {
    if (p < 0.20) return 'Extracting text content...';
    if (p < 0.40) return 'Running Claude extraction...';
    if (p < 0.60) return 'Chunking document...';
    if (p < 0.80) return 'Generating Voyage AI embeddings...';
    return 'Building HNSW search index...';
  }

  void reset() => state = const UploadState();

  void clearError() => state = state.copyWith(
        phase: UploadPhase.idle,
        clearError: true,
        clearFile: true,
      );
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
        title: Text('Upload Document', style: AppTextStyles.headingSM),
        centerTitle: true,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: AppConstants.standardDuration,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.04), end: Offset.zero)
                  .animate(CurvedAnimation(
                      parent: anim, curve: Curves.easeOutCubic)),
              child: child,
            ),
          ),
          child: switch (upload.phase) {
            UploadPhase.idle => _IdleView(key: const ValueKey('idle')),
            UploadPhase.picked =>
              _PickedView(key: const ValueKey('picked'), file: upload.file!),
            UploadPhase.uploading ||
            UploadPhase.processing =>
              _ProgressView(key: const ValueKey('progress'), upload: upload),
            UploadPhase.success =>
              _SuccessView(key: const ValueKey('success'), file: upload.file!),
            UploadPhase.failed => _FailedView(
                key: const ValueKey('failed'),
                error: upload.error ?? 'Upload failed'),
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// IDLE — Drop zone with Lottie or CustomPaint fallback
// ─────────────────────────────────────────────────────────────────────────────

class _IdleView extends ConsumerWidget {
  const _IdleView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // ── Drop zone ──────────────────────────────────────────────────
          _TappableDropZone(
            onTap: () => ref.read(uploadNotifierProvider.notifier).pickFile(),
          ).animate().fadeIn(delay: 100.ms).scale(
                begin: const Offset(0.96, 0.96),
                curve: Curves.easeOutCubic,
              ),

          const SizedBox(height: 32),

          Text('SUPPORTED FORMATS', style: AppTextStyles.labelMD)
              .animate()
              .fadeIn(delay: 200.ms),

          const SizedBox(height: 16),

          const Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: const [
              _FormatBadge(
                  ext: 'PDF',
                  icon: Icons.picture_as_pdf_outlined,
                  color: AppColors.red),
              _FormatBadge(
                  ext: 'PNG',
                  icon: Icons.image_outlined,
                  color: AppColors.signal),
              _FormatBadge(
                  ext: 'JPG',
                  icon: Icons.image_outlined,
                  color: AppColors.signal),
              _FormatBadge(
                  ext: 'DOCX',
                  icon: Icons.description_outlined,
                  color: AppColors.amber),
              _FormatBadge(
                  ext: 'TXT',
                  icon: Icons.article_outlined,
                  color: AppColors.ink1),
            ],
          ).animate().fadeIn(delay: 280.ms),

          const Spacer(),

          Text('Maximum file size: ${AppConstants.maxFileSizeMB} MB',
                  style: AppTextStyles.bodySM, textAlign: TextAlign.center)
              .animate()
              .fadeIn(delay: 380.ms),
        ],
      ),
    );
  }
}

/// Drop zone — shows Lottie animation when asset exists,
/// falls back to the pulsing CustomPaint orbit otherwise.
class _TappableDropZone extends StatefulWidget {
  final VoidCallback onTap;
  const _TappableDropZone({required this.onTap});

  @override
  State<_TappableDropZone> createState() => _TappableDropZoneState();
}

class _TappableDropZoneState extends State<_TappableDropZone>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: AppConstants.microDuration,
        height: 240,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _pressed ? AppColors.signalTrace : AppColors.surface0,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _pressed ? AppColors.signal : AppColors.wire,
            width: _pressed ? 1.0 : 0.5,
          ),
        ),
        child: Stack(
          children: [
            // Corner brackets
            ..._corners(),
            // Lottie OR fallback
            Center(
              child: _LottieOrFallback(
                assetPath: _kDropzoneLottie,
                height: 160,
                repeat: true, // idle animation loops forever
                fallback: _DropzoneFallback(pressed: _pressed),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _corners() {
    Widget c(double top, double? bottom, double? left, double? right,
            double rot) =>
        Positioned(
          top: top >= 0 ? top : null,
          bottom: bottom,
          left: left,
          right: right,
          child: Transform.rotate(
            angle: rot * math.pi / 180,
            child: SizedBox(
              width: 18,
              height: 18,
              child: CustomPaint(
                painter: _CornerPainter(
                  color: AppColors.signal.withOpacity(0.35),
                  thickness: 1.5,
                ),
              ),
            ),
          ),
        );
    return [
      c(12, null, 12, null, 0),
      c(12, null, null, 12, 90),
      c(-1, 12, null, 12, 180),
      c(-1, 12, 12, null, 270),
    ];
  }
}

/// Shows Lottie if the asset is bundled, otherwise renders [fallback].
class _LottieOrFallback extends StatelessWidget {
  final String assetPath;
  final double height;
  final bool repeat;
  final Widget fallback;
  final VoidCallback? onLoaded;

  const _LottieOrFallback({
    required this.assetPath,
    required this.height,
    required this.repeat,
    required this.fallback,
    this.onLoaded,
  });

  @override
  Widget build(BuildContext context) {
    return _LottieAssetChecker(
      assetPath: assetPath,
      height: height,
      repeat: repeat,
      fallback: fallback,
      onLoaded: onLoaded,
    );
  }
}

/// Tries to load a Lottie asset; shows [fallback] on any error.
class _LottieAssetChecker extends StatefulWidget {
  final String assetPath;
  final double height;
  final bool repeat;
  final Widget fallback;
  final VoidCallback? onLoaded;

  const _LottieAssetChecker({
    required this.assetPath,
    required this.height,
    required this.repeat,
    required this.fallback,
    this.onLoaded,
  });

  @override
  State<_LottieAssetChecker> createState() => _LottieAssetCheckerState();
}

class _LottieAssetCheckerState extends State<_LottieAssetChecker> {
  bool _failed = false;

  @override
  Widget build(BuildContext context) {
    if (_failed) return widget.fallback;

    return Lottie.asset(
      widget.assetPath,
      height: widget.height,
      repeat: widget.repeat,
      // animate: true → default, plays immediately
      errorBuilder: (_, __, ___) {
        // Called when asset is missing or corrupt
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _failed = true);
        });
        return widget.fallback;
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROGRESS — Lottie looping scan, falls back to OrbitRing
// ─────────────────────────────────────────────────────────────────────────────

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
        children: [
          // Lottie processing animation (loops while active)
          // Falls back to the spinning OrbitRing CustomPaint
          SizedBox(
            height: 180,
            child: _LottieOrFallback(
              assetPath: _kProgressLottie,
              height: 180,
              repeat: true, // loops until phase changes
              fallback: _OrbitRing(isProcessing: isProcessing),
            ),
          ),

          const SizedBox(height: 32),

          AnimatedSwitcher(
            duration: AppConstants.microDuration,
            child: Text(
              isProcessing ? 'Processing' : 'Uploading',
              key: ValueKey(upload.phase),
              style: AppTextStyles.headingMD,
            ).animate().fadeIn(),
          ),

          const SizedBox(height: 8),

          AnimatedSwitcher(
            duration: AppConstants.standardDuration,
            child: Text(
              upload.processingStep ?? (upload.file?.name ?? '').truncate(40),
              key: ValueKey(upload.processingStep),
              style: AppTextStyles.bodyMD,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 32),

          // Progress bar
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isProcessing ? 'AI pipeline' : 'Uploading',
                      style: AppTextStyles.monoSM),
                  Text('$pct%', style: AppTextStyles.monoSM),
                ],
              ),
              const SizedBox(height: 8),
              Stack(children: [
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 300),
                  widthFactor: upload.progress,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.signal,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUCCESS — one-shot Lottie, falls back to check circle
// ─────────────────────────────────────────────────────────────────────────────

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
          // One-shot success animation — plays once, no loop
          SizedBox(
            height: 160,
            child: _LottieOrFallback(
              assetPath: _kSuccessLottie,
              height: 160,
              repeat: false, // ← plays exactly once
              fallback: _SuccessFallback(),
            ),
          ).animate().scale(
                begin: const Offset(0.7, 0.7),
                curve: const Cubic(0.34, 1.56, 0.64, 1),
                duration: 600.ms,
              ),

          const SizedBox(height: 28),

          Text('Indexed and ready.', style: AppTextStyles.displayMD)
              .animate()
              .fadeIn(delay: 300.ms)
              .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),

          const SizedBox(height: 8),

          Text(
            '"${file.name.truncate(36)}" is searchable.\nAsk DocuSense anything about it.',
            style: AppTextStyles.bodyLG,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 40),

          // Live processing status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.signalTrace,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppColors.signal.withOpacity(0.2), width: 0.5),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 1.5, color: AppColors.signal),
                ),
                const SizedBox(width: 10),
                Text('Building search index in background...',
                    style: AppTextStyles.bodyMD),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms),

          const SizedBox(height: 32),

          GlowButton(
            onPressed: () {
              ref.read(uploadNotifierProvider.notifier).reset();
              context.go(AppRoutes.documents);
            },
            child: const Text('View Documents'),
          ).animate().fadeIn(delay: 600.ms),

          const SizedBox(height: 12),

          TextButton(
            onPressed: () => ref.read(uploadNotifierProvider.notifier).reset(),
            child: Text('Upload another',
                style: AppTextStyles.bodyMD.copyWith(color: AppColors.ink1)),
          ).animate().fadeIn(delay: 700.ms),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FAILED — one-shot Lottie, falls back to error circle
// ─────────────────────────────────────────────────────────────────────────────

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
          // One-shot error animation — plays once, no loop
          SizedBox(
            height: 160,
            child: _LottieOrFallback(
              assetPath: _kErrorLottie,
              height: 160,
              repeat: false, // ← plays exactly once
              fallback: _ErrorFallback(),
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.5, 0.5),
                curve: const Cubic(0.34, 1.56, 0.64, 1),
              )
              .fadeIn(),

          const SizedBox(height: 24),

          Text('Upload failed', style: AppTextStyles.displayMD)
              .animate()
              .fadeIn(delay: 200.ms),

          const SizedBox(height: 10),

          Text(error, style: AppTextStyles.bodyLG, textAlign: TextAlign.center)
              .animate()
              .fadeIn(delay: 280.ms),

          const SizedBox(height: 40),

          GlowButton(
            onPressed: () =>
                ref.read(uploadNotifierProvider.notifier).clearError(),
            color: AppColors.red,
            child: const Text('Try Again'),
          ).animate().fadeIn(delay: 360.ms),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PICKED — unchanged, no Lottie needed
// ─────────────────────────────────────────────────────────────────────────────

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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface0,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.wire, width: 0.5),
            ),
            child: Row(children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(ext,
                      style: AppTextStyles.monoSM.copyWith(
                          color: AppColors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(file.name,
                      style: AppTextStyles.headingSM,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text('$sizeMb MB', style: AppTextStyles.bodyMD),
                ],
              )),
              IconButton(
                icon: const Icon(Icons.swap_horiz_rounded,
                    color: AppColors.ink2, size: 18),
                onPressed: () =>
                    ref.read(uploadNotifierProvider.notifier).pickFile(),
              ),
            ]),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.signalTrace,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppColors.signal.withOpacity(0.15), width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What happens next',
                    style: AppTextStyles.headingSM
                        .copyWith(color: AppColors.signal)),
                const SizedBox(height: 10),
                ...[
                  (
                    'Claude extracts structure, entities & dates',
                    Icons.auto_awesome_outlined
                  ),
                  ('Voyage AI chunks & embeds all text', Icons.hub_outlined),
                  (
                    'HNSW vector index built for instant search',
                    Icons.search_rounded
                  ),
                ].map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(children: [
                        Icon(item.$2, color: AppColors.signalDim, size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(item.$1, style: AppTextStyles.bodyMD)),
                      ]),
                    )),
              ],
            ),
          ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
          const Spacer(),
          GlowButton(
            onPressed: () => ref.read(uploadNotifierProvider.notifier).upload(),
            child: const Text('Upload & Process'),
          ).animate().fadeIn(delay: 280.ms),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () =>
                  ref.read(uploadNotifierProvider.notifier).reset(),
              child: Text('Cancel',
                  style: AppTextStyles.bodyMD.copyWith(color: AppColors.ink2)),
            ),
          ).animate().fadeIn(delay: 330.ms),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FALLBACK WIDGETS — shown when Lottie assets are not bundled
// ─────────────────────────────────────────────────────────────────────────────

/// Fallback for drop zone — pulsing cloud icon
class _DropzoneFallback extends StatefulWidget {
  final bool pressed;
  const _DropzoneFallback({required this.pressed});

  @override
  State<_DropzoneFallback> createState() => _DropzoneFallbackState();
}

class _DropzoneFallbackState extends State<_DropzoneFallback>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

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
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _pulse,
        builder: (_, __) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.signal.withOpacity(0.06 + _pulse.value * 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      AppColors.signal.withOpacity(0.2 + _pulse.value * 0.15),
                  width: 0.5,
                ),
              ),
              child: const Icon(Icons.cloud_upload_outlined,
                  color: AppColors.signal, size: 32),
            ),
            const SizedBox(height: 16),
            Text('Tap to browse files', style: AppTextStyles.headingSM),
            const SizedBox(height: 4),
            Text('PDF · PNG · JPG · DOCX · TXT', style: AppTextStyles.bodyMD),
          ],
        ),
      );
}

/// Fallback for progress — spinning orbit ring
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
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotate.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
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

class _OrbitPainter extends CustomPainter {
  final double rotation, pulse;
  final bool isProcessing;
  const _OrbitPainter(
      {required this.rotation,
      required this.pulse,
      required this.isProcessing});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = size.width / 2 - 4;
    canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = AppColors.surface2
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      rotation * 2 * math.pi - math.pi / 2,
      isProcessing ? math.pi * 1.5 : math.pi * 0.8,
      false,
      Paint()
        ..color = AppColors.signal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    if (isProcessing) {
      for (int i = 0; i < 3; i++) {
        final angle = rotation * 2 * math.pi + i * 2 * math.pi / 3;
        canvas.drawCircle(
          Offset(cx + math.cos(angle) * 14, cy + math.sin(angle) * 14),
          i == 0 ? 5 + pulse * 2 : 3 + pulse,
          Paint()
            ..color = AppColors.signal.withOpacity(i == 0 ? 1.0 : 0.4)
            ..style = PaintingStyle.fill,
        );
      }
    } else {
      final p = Paint()
        ..color = AppColors.signal
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx, cy + 10), Offset(cx, cy - 10), p);
      canvas.drawLine(Offset(cx - 7, cy - 3), Offset(cx, cy - 10), p);
      canvas.drawLine(Offset(cx + 7, cy - 3), Offset(cx, cy - 10), p);
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter _) => true;
}

/// Fallback for success — animated check circle
class _SuccessFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.greenTrace,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.green.withOpacity(0.3), width: 1),
        ),
        child:
            const Icon(Icons.check_rounded, color: AppColors.green, size: 48),
      );
}

/// Fallback for error — error icon circle
class _ErrorFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.redTrace,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.red.withOpacity(0.3), width: 1),
        ),
        child: const Icon(Icons.error_outline_rounded,
            color: AppColors.red, size: 44),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED TINY WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  const _CornerPainter({required this.color, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), p);
    canvas.drawLine(Offset.zero, Offset(0, size.height), p);
  }

  @override
  bool shouldRepaint(_CornerPainter o) =>
      o.color != color || o.thickness != thickness;
}

class _FormatBadge extends StatelessWidget {
  final String ext;
  final IconData icon;
  final Color color;
  const _FormatBadge(
      {required this.ext, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.2), width: 0.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(ext, style: AppTextStyles.monoSM.copyWith(color: color)),
        ]),
      );
}

// ── AppRoutes stub (defined in constants/app_theme) ───────────────────────────
extension on String {
  String truncate(int max) => length <= max ? this : '${substring(0, max)}...';
}

class AppRoutes {
  static const documents = '/documents';
}
