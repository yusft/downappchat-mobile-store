import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:downapp/app/theme/app_colors.dart';
import 'package:downapp/core/widgets/app_text_field.dart';
import 'package:downapp/core/widgets/app_button.dart';
import 'package:downapp/core/utils/validators.dart';
import 'package:downapp/features/auth/presentation/providers/auth_provider.dart';

/// Kayıt sayfası
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptedTerms = false;
  bool _isDeveloper = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kullanım koşullarını kabul etmelisiniz'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    ref.read(authNotifierProvider.notifier).signUpWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _usernameController.text.trim(),
      displayName: _nameController.text.trim(),
      isDeveloper: _isDeveloper,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    final isLoading = authState.status == AuthStatus.loading;

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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hesap Oluştur',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 8),

                Text(
                  'Hemen ücretsiz hesabını oluştur',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

                const SizedBox(height: 32),

                AppTextField(
                  label: 'Ad Soyad',
                  hint: 'Adınızı girin',
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.person_outlined,
                  validator: (v) => Validators.validateRequired(v, 'Ad Soyad'),
                ).animate().fadeIn(duration: 300.ms, delay: 150.ms),

                const SizedBox(height: 16),

                AppTextField(
                  label: 'Kullanıcı Adı',
                  hint: 'kullanici_adi',
                  controller: _usernameController,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.alternate_email,
                  validator: Validators.validateUsername,
                ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

                const SizedBox(height: 16),

                AppTextField(
                  label: 'Email',
                  hint: 'email@ornek.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.validateEmail,
                ).animate().fadeIn(duration: 300.ms, delay: 250.ms),

                const SizedBox(height: 16),

                AppTextField(
                  label: 'Şifre',
                  hint: '••••••••',
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.lock_outlined,
                  validator: Validators.validatePassword,
                ).animate().fadeIn(duration: 300.ms, delay: 300.ms),

                const SizedBox(height: 16),

                AppTextField(
                  label: 'Şifre Tekrar',
                  hint: '••••••••',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: Icons.lock_outlined,
                  validator: (v) => Validators.validateConfirmPassword(
                    v, _passwordController.text,
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 350.ms),

                const SizedBox(height: 20),

                // Koşullar
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _acceptedTerms,
                        onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
                        child: RichText(
                          text: TextSpan(
                            style: theme.textTheme.bodySmall,
                            children: [
                              const TextSpan(text: 'Devam ederek '),
                              TextSpan(
                                text: 'Kullanım Koşulları',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: ' ve '),
                              TextSpan(
                                text: 'Gizlilik Politikası',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: '\'nı kabul etmiş olursunuz.'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms, delay: 400.ms),
                
                const SizedBox(height: 16),

                // Geliştirici Seçeneği
                Container(
                  decoration: BoxDecoration(
                    color: _isDeveloper ? AppColors.primary.withValues(alpha: 0.05) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isDeveloper ? AppColors.primary.withValues(alpha: 0.3) : theme.dividerColor.withValues(alpha: 0.1),
                    ),
                  ),
                  child: CheckboxListTile(
                    value: _isDeveloper,
                    onChanged: (v) => setState(() => _isDeveloper = v ?? false),
                    title: const Text('Geliştirici Hesabı Oluştur', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Uygulama yüklemek ve yönetmek için geliştirici paneline erişin.', style: TextStyle(fontSize: 12)),
                    activeColor: AppColors.primary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 420.ms),

                const SizedBox(height: 28),

                AppButton(
                  text: 'Kayıt Ol',
                  onPressed: _handleRegister,
                  isLoading: isLoading,
                ).animate().fadeIn(duration: 300.ms, delay: 450.ms),

                const SizedBox(height: 24),

                // Google ile kayıt
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => ref.read(authNotifierProvider.notifier).signInWithGoogle(),
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: const Text('Google ile Kayıt Ol'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 500.ms),

                const SizedBox(height: 24),

                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Zaten hesabın var mı? ', style: theme.textTheme.bodyMedium),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          'Giriş Yap',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
