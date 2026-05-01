import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:downapp/app/theme/app_colors.dart';
import 'package:downapp/app/router.dart';
import 'package:downapp/core/widgets/app_text_field.dart';
import 'package:downapp/core/widgets/app_button.dart';
import 'package:downapp/core/utils/validators.dart';
import 'package:downapp/features/auth/presentation/providers/auth_provider.dart';

/// Giriş sayfası
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authNotifierProvider.notifier).signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  void _handleGoogleLogin() {
    ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    final isLoading = authState.status == AuthStatus.loading;

    // Hata gösterimi
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.status == AuthStatus.error && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Logo ve başlık
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

                const SizedBox(height: 32),

                Center(
                  child: Text(
                    'Hoş Geldin!',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    'Hesabınıza giriş yapın',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                const SizedBox(height: 40),

                // Email
                AppTextField(
                  label: 'Email',
                  hint: 'email@ornek.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.validateEmail,
                ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideX(begin: -0.1),

                const SizedBox(height: 20),

                // Şifre
                AppTextField(
                  label: 'Şifre',
                  hint: '••••••••',
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: Icons.lock_outlined,
                  validator: Validators.validatePassword,
                  onSubmitted: (_) => _handleLogin(),
                ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideX(begin: -0.1),

                const SizedBox(height: 12),

                // Beni Hatırla & Şifremi unuttum
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (val) => setState(() => _rememberMe = val ?? true),
                        activeColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Beni Hatırla', style: theme.textTheme.bodyMedium),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.forgotPassword),
                      child: const Text('Şifremi Unuttum'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Giriş butonu
                AppButton(
                  text: 'Giriş Yap',
                  onPressed: _handleLogin,
                  isLoading: isLoading,
                ).animate().fadeIn(duration: 300.ms, delay: 400.ms),

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: theme.dividerColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'veya',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    Expanded(child: Divider(color: theme.dividerColor)),
                  ],
                ),

                const SizedBox(height: 24),

                // Google ile giriş
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : _handleGoogleLogin,
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: const Text('Google ile Giriş Yap'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 500.ms),

                const SizedBox(height: 32),

                // Kayıt ol linki
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Hesabın yok mu? ',
                        style: theme.textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.register),
                        child: Text(
                          'Kayıt Ol',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
