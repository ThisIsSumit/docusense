import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:docusense/core/constants/app_constants.dart';
import 'package:docusense/core/theme/app_theme.dart';
import 'package:docusense/shared/widgets/app_widgets.dart';
import 'package:docusense/features/auth/presentation/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authStateNotifierProvider.notifier).register(
          name: _nameCtrl.text.trim(),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text('Create\naccount.', style: AppTextStyles.displayLG)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 8),
                Text('Start for free, no credit card required.',
                        style: AppTextStyles.bodyMD)
                    .animate()
                    .fadeIn(delay: 80.ms, duration: 400.ms),
                const SizedBox(height: 40),
                if (error != null) ...[
                  ErrorBanner(message: error),
                  const SizedBox(height: 20),
                ],
                AppTextField(
                  label: 'Full Name',
                  hint: 'First and last name',
                  controller: _nameCtrl,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  autofocus: true,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.mail_outline_rounded),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ).animate().fadeIn(delay: 160.ms, duration: 400.ms),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passwordCtrl,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length < 8) return 'Minimum 8 characters';
                    return null;
                  },
                ).animate().fadeIn(delay: 220.ms, duration: 400.ms),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Confirm Password',
                  hint: '••••••••',
                  controller: _confirmCtrl,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  validator: (v) {
                    if (v != _passwordCtrl.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 280.ms, duration: 400.ms),
                const SizedBox(height: 40),
                GlowButton(
                  onPressed: isLoading ? null : _submit,
                  isLoading: isLoading,
                  child: const Text('Create Account'),
                ).animate().fadeIn(delay: 340.ms, duration: 400.ms),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'By signing up you agree to our Terms of Service\nand Privacy Policy.',
                    style: AppTextStyles.bodySM,
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
