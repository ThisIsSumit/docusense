import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authStateNotifierProvider.notifier).login(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
    if (ok && mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateNotifierProvider).valueOrNull;
    final isLoading = authState?.isLoading ?? false;
    final error = authState?.error;

    return Scaffold(
      backgroundColor: AppColors.void1,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),

                    // Header
                    Text('DS', style: AppTextStyles.monoMD)
                        .animate()
                        .fadeIn(delay: 50.ms, duration: 400.ms),

                    const SizedBox(height: 32),

                    Text('Welcome\nback.', style: AppTextStyles.displayLG)
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 500.ms)
                        .slideY(
                            begin: 0.15,
                            end: 0,
                            curve: Curves.easeOutCubic,
                            delay: 100.ms),

                    const SizedBox(height: 8),

                    Text('Sign in to your account',
                            style: AppTextStyles.bodyMD)
                        .animate()
                        .fadeIn(delay: 180.ms, duration: 400.ms),

                    const SizedBox(height: 48),

                    // Error
                    if (error != null) ...[
                      ErrorBanner(message: error),
                      const SizedBox(height: 20),
                    ],

                    // Email
                    AppTextField(
                      label: 'Email',
                      hint: 'you@example.com',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.mail_outline_rounded),
                      autofocus: true,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

                    const SizedBox(height: 20),

                    // Password
                    AppTextField(
                      label: 'Password',
                      hint: '••••••••',
                      controller: _passwordCtrl,
                      isPassword: true,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    )
                        .animate()
                        .fadeIn(delay: 280.ms, duration: 400.ms)
                        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            context.push(AppRoutes.forgotPassword),
                        child: Text('Forgot password?',
                            style: AppTextStyles.bodySM
                                .copyWith(color: AppColors.accent)),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 320.ms, duration: 400.ms),

                    const SizedBox(height: 32),

                    // Sign in button
                    GlowButton(
                      onPressed: isLoading ? null : _submit,
                      isLoading: isLoading,
                      child: const Text('Sign In'),
                    )
                        .animate()
                        .fadeIn(delay: 360.ms, duration: 400.ms)
                        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        const Expanded(
                            child: Divider(color: AppColors.border)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('or', style: AppTextStyles.bodySM),
                        ),
                        const Expanded(
                            child: Divider(color: AppColors.border)),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 400.ms),

                    const SizedBox(height: 24),

                    // Sign up link
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Don't have an account? ",
                              style: AppTextStyles.bodyMD),
                          TextButton(
                            onPressed: () =>
                                context.push(AppRoutes.register),
                            child: const Text('Sign up'),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 440.ms, duration: 400.ms),

                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
