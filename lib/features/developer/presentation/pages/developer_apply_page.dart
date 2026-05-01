import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:downapp/core/widgets/app_text_field.dart';
import 'package:downapp/core/widgets/app_button.dart';
import 'package:downapp/app/theme/app_colors.dart';

class DeveloperApplyPage extends StatelessWidget {
  const DeveloperApplyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => context.pop()),
        title: const Text('Geliştirici Başvurusu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.code, size: 40, color: Colors.white),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Geliştirici Ol', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                        Text('Uygulamalarını yükle ve paylaş', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const AppTextField(label: 'Neden geliştirici olmak istiyorsunuz?', hint: 'Motivasyonunuzu anlatın...', maxLines: 4, prefixIcon: Icons.edit_note),
            const SizedBox(height: 16),
            const AppTextField(label: 'Portfolio / GitHub', hint: 'https://github.com/...', prefixIcon: Icons.link, keyboardType: TextInputType.url),
            const SizedBox(height: 16),
            const AppTextField(label: 'Geliştirme Deneyimi', hint: 'Deneyimlerinizi kısaca anlatın...', maxLines: 3, prefixIcon: Icons.work_outline),
            const SizedBox(height: 32),
            AppButton(text: 'Başvuru Gönder', icon: Icons.send, onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Başvurunuz gönderildi! Admin onayı bekleniyor.')));
              context.pop();
            }),
          ],
        ),
      ),
    );
  }
}
