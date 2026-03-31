import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardPage(
      tag: '01 / UPLOAD',
      title: 'Drop your\ndocuments.',
      body:
          'PDFs, images, contracts, reports — any format. We handle the rest.',
      icon: Icons.upload_file_rounded,
      accentColor: AppColors.accent,
    ),
    _OnboardPage(
      tag: '02 / EXTRACT',
      title: 'AI reads\neverything.',
      body:
          'Claude extracts structure, entities, dates and key data automatically.',
      icon: Icons.document_scanner_rounded,
      accentColor: AppColors.amber,
    ),
    _OnboardPage(
      tag: '03 / QUERY',
      title: 'Ask in plain\nEnglish.',
      body:
          'Semantic search across your entire library. Get cited, grounded answers.',
      icon: Icons.chat_bubble_outline_rounded,
      accentColor: AppColors.info,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.pageTransitionDuration,
        curve: const Cubic(0.16, 1, 0.3, 1),
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await ref.read(authStateNotifierProvider.notifier).markOnboarded();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void1,
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text('Skip', style: AppTextStyles.labelLG),
              ),
            ).animate().fadeIn(delay: 200.ms),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) => _pages[i],
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: AppConstants.microDuration,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 24 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppColors.accent
                              : AppColors.surface3,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // CTA button
                  AnimatedSwitcher(
                    duration: AppConstants.microDuration,
                    child: ElevatedButton(
                      key: ValueKey(_currentPage),
                      onPressed: _next,
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Continue',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final String tag;
  final String title;
  final String body;
  final IconData icon;
  final Color accentColor;

  const _OnboardPage({
    required this.tag,
    required this.title,
    required this.body,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),

          // Icon stage
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(28),
                border:
                    Border.all(color: accentColor.withOpacity(0.2), width: 1),
              ),
              child: Icon(icon, color: accentColor, size: 48),
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.7, 0.7),
                end: const Offset(1, 1),
                curve: const Cubic(0.34, 1.56, 0.64, 1),
                duration: 600.ms,
              )
              .fadeIn(duration: 400.ms),

          const SizedBox(height: 56),

          // Tag
          Text(tag, style: AppTextStyles.monoSM.copyWith(color: accentColor))
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideX(begin: -0.1, end: 0, curve: Curves.easeOutCubic),

          const SizedBox(height: 12),

          // Title
          Text(title, style: AppTextStyles.displayMD)
              .animate()
              .fadeIn(delay: 150.ms, duration: 500.ms)
              .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),

          const SizedBox(height: 16),

          // Body
          Text(body, style: AppTextStyles.bodyLG)
              .animate()
              .fadeIn(delay: 250.ms, duration: 500.ms)
              .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),

          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
