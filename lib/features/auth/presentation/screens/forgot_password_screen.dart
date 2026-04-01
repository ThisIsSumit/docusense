import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/dio_client.dart';
import '../../../../shared/widgets/app_widgets.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      // Real API call — backend sends reset email
      await ref.read(dioClientProvider).post('/auth/forgot-password', data: {
        'email': _emailCtrl.text.trim().toLowerCase(),
      });
      if (mounted) setState(() { _isLoading = false; _sent = true; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.message; });
    } catch (_) {
      if (mounted) setState(() { _isLoading = false; _error = 'Request failed. Try again.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: _sent ? _SuccessView() : _FormView(
            formKey: _formKey,
            emailCtrl: _emailCtrl,
            isLoading: _isLoading,
            error: _error,
            onSubmit: _submit,
          ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final bool isLoading;
  final String? error;
  final VoidCallback onSubmit;

  const _FormView({
    required this.formKey,
    required this.emailCtrl,
    required this.isLoading,
    required this.error,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Reset\npassword.', style: AppTextStyles.displayLG)
              .animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 8),
          Text('Enter your email — we\'ll send a reset link.',
              style: AppTextStyles.bodyMD)
              .animate().fadeIn(delay: 80.ms),
          const SizedBox(height: 40),
          if (error != null) ...[
            ErrorBanner(message: error!),
            const SizedBox(height: 16),
          ],
          AppTextField(
            label: 'Email',
            hint: 'you@example.com',
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.mail_outline_rounded),
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ).animate().fadeIn(delay: 160.ms),
          const SizedBox(height: 32),
          GlowButton(
            onPressed: isLoading ? null : onSubmit,
            isLoading: isLoading,
            child: const Text('Send Reset Link'),
          ).animate().fadeIn(delay: 240.ms),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.greenTrace,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.green.withOpacity(0.3), width: 1),
            ),
            child: const Icon(Icons.check_rounded, color: AppColors.green, size: 36),
          )
              .animate()
              .scale(begin: const Offset(0.5, 0.5),
                  curve: const Cubic(0.34, 1.56, 0.64, 1))
              .fadeIn(),
          const SizedBox(height: 24),
          Text('Check your inbox', style: AppTextStyles.headingMD)
              .animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text('We sent a password reset link to your email.',
              style: AppTextStyles.bodyMD, textAlign: TextAlign.center)
              .animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 40),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Back to Sign In'),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}
