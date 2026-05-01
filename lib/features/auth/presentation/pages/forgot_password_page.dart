import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:downapp/app/theme/app_colors.dart';
import 'package:downapp/core/widgets/app_text_field.dart';
import 'package:downapp/core/widgets/app_button.dart';
import 'package:downapp/core/utils/validators.dart';
import 'package:downapp/features/auth/presentation/providers/auth_provider.dart';

/// Şifremi unuttum sayfası
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleReset() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref.read(authNotifierProvider.notifier)
          .resetPassword(_emailController.text.trim());
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _emailSent ? _buildSuccessView(theme) : _buildFormView(theme, isLoading),
        ),
      ),
    );
  }

  Widget _buildFormView(ThemeData theme, bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.lock_reset, size: 32, color: AppColors.primary),
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

          const SizedBox(height: 24),

          Text(
            'Şifreni Sıfırla',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 8),

          Text(
            'Email adresinize şifre sıfırlama bağlantısı göndereceğiz.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

          const SizedBox(height: 32),

          AppTextField(
            label: 'Email',
            hint: 'email@ornek.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.email_outlined,
            validator: Validators.validateEmail,
            onSubmitted: (_) => _handleReset(),
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

          const SizedBox(height: 32),

          AppButton(
            text: 'Sıfırlama Linki Gönder',
            onPressed: _handleReset,
            isLoading: isLoading,
          ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildSuccessView(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read, size: 40, color: AppColors.success),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

        const SizedBox(height: 24),

        Text(
          'Email Gönderildi!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

        const SizedBox(height: 12),

        Text(
          'Şifre sıfırlama bağlantısı ${_emailController.text} adresine gönderildi.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

        const SizedBox(height: 32),

        AppButton(
          text: 'Giriş Sayfasına Dön',
          onPressed: () => context.pop(),
        ).animate().fadeIn(duration: 300.ms, delay: 400.ms),
      ],
    );
  }
}
