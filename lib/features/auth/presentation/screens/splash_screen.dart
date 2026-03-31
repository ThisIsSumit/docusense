import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _logoController;
  late AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _logoController.forward();

    // Wait for auth to resolve + splash minimum time
    await Future.wait([
      Future.delayed(AppConstants.splashDuration),
      ref.read(authStateNotifierProvider.future),
    ]);

    if (!mounted) return;
    _navigate();
  }

  void _navigate() {
    final authState = ref.read(authStateNotifierProvider).valueOrNull;
    if (authState == null) {
      context.go(AppRoutes.login);
      return;
    }
    if (!authState.isOnboarded) {
      context.go(AppRoutes.onboarding);
    } else if (!authState.isAuthenticated) {
      context.go(AppRoutes.login);
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    _logoController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void0,
      body: Stack(
        children: [
          // Particle field
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, _) => CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _ParticlePainter(_particleController.value),
            ),
          ),

          // Radial rings
          Center(
            child: AnimatedBuilder(
              animation: _ringController,
              builder: (context, _) => CustomPaint(
                size: const Size(400, 400),
                painter: _RingPainter(_ringController.value),
              ),
            ),
          ),

          // Logo + wordmark
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon mark
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, _) {
                    final t = Curves.elasticOut.transform(
                      _logoController.value.clamp(0.0, 1.0),
                    );
                    return Transform.scale(
                      scale: 0.4 + (0.6 * t),
                      child: Opacity(
                        opacity: t.clamp(0.0, 1.0),
                        child: _LogoMark(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Wordmark
                const Text('DocuSense', style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -1.5,
                ))
                    .animate(controller: _logoController)
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: 8),

                Text('AI Document Intelligence', style: AppTextStyles.monoSM)
                    .animate(controller: _logoController)
                    .fadeIn(delay: 600.ms, duration: 600.ms),
              ],
            ),
          ),

          // Loading bar at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: _LoadingBar()
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 400.ms),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.accentFaint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 1),
      ),
      child: CustomPaint(
        painter: _LogoPainter(),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Document icon
    final docPath = Path()
      ..moveTo(cx - 14, cy - 18)
      ..lineTo(cx + 6, cy - 18)
      ..lineTo(cx + 14, cy - 10)
      ..lineTo(cx + 14, cy + 18)
      ..lineTo(cx - 14, cy + 18)
      ..close();

    // Fold
    final foldPath = Path()
      ..moveTo(cx + 6, cy - 18)
      ..lineTo(cx + 6, cy - 10)
      ..lineTo(cx + 14, cy - 10);

    // Lines in doc
    final line1 = Path()
      ..moveTo(cx - 8, cy - 3)
      ..lineTo(cx + 8, cy - 3);
    final line2 = Path()
      ..moveTo(cx - 8, cy + 4)
      ..lineTo(cx + 8, cy + 4);
    final line3 = Path()
      ..moveTo(cx - 8, cy + 11)
      ..lineTo(cx + 2, cy + 11);

    // AI dot grid (top right corner of doc space)
    final dotPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    canvas.drawPath(docPath, paint);
    canvas.drawPath(foldPath, paint);
    canvas.drawPath(line1, paint..color = AppColors.accentDim);
    canvas.drawPath(line2, paint);
    canvas.drawPath(line3, paint..color = AppColors.accent.withOpacity(0.4));
    canvas.drawCircle(Offset(cx + 14, cy + 14), 4, dotPaint..color = AppColors.accentGlow);
    canvas.drawCircle(Offset(cx + 14, cy + 14), 2, dotPaint..color = AppColors.accent);
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => false;
}

class _ParticlePainter extends CustomPainter {
  final double t;
  static final List<_Particle> _particles = List.generate(
    40,
    (i) => _Particle(i),
  );

  _ParticlePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final progress = (t + p.offset) % 1.0;
      final x = p.x * size.width;
      final y = (p.y + progress * p.speed) % 1.0 * size.height;
      final opacity = math.sin(progress * math.pi) * 0.4 * p.opacity;

      if (opacity <= 0) continue;

      final paint = Paint()
        ..color = (p.isAccent ? AppColors.accent : AppColors.textTertiary)
            .withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t;
}

class _Particle {
  late final double x;
  late final double y;
  late final double speed;
  late final double offset;
  late final double opacity;
  late final double radius;
  late final bool isAccent;

  _Particle(int seed) {
    final r = math.Random(seed * 73);
    x = r.nextDouble();
    y = r.nextDouble();
    speed = 0.1 + r.nextDouble() * 0.3;
    offset = r.nextDouble();
    opacity = 0.3 + r.nextDouble() * 0.7;
    radius = 0.5 + r.nextDouble() * 1.5;
    isAccent = r.nextInt(5) == 0;
  }
}

class _RingPainter extends CustomPainter {
  final double t;
  _RingPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    for (int i = 0; i < 3; i++) {
      final progress = (t + i * 0.33) % 1.0;
      final radius = 80.0 + progress * 100;
      final opacity = (1 - progress) * 0.12;

      final paint = Paint()
        ..color = AppColors.accent.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.t != t;
}

class _LoadingBar extends StatefulWidget {
  @override
  State<_LoadingBar> createState() => _LoadingBarState();
}

class _LoadingBarState extends State<_LoadingBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(
          milliseconds: AppConstants.splashDuration.inMilliseconds - 800),
    )..forward();

    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Initializing', style: AppTextStyles.monoSM),
              Text('${(_anim.value * 100).round()}%',
                  style: AppTextStyles.monoSM),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              FractionallySizedBox(
                widthFactor: _anim.value,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(1),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
