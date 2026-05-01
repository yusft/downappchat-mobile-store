import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:downapp/app/theme/app_colors.dart';
import 'package:downapp/core/widgets/app_button.dart';

class CreateStoryPage extends StatelessWidget {
  const CreateStoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
        title: const Text('Hikaye Oluştur'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.darkBorder, style: BorderStyle.solid, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, size: 64, color: AppColors.primary.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('Fotoğraf veya Video Seç', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('GIF desteği mevcuttur', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StoryOption(icon: Icons.photo_library, label: 'Galeri', onTap: () {}),
                _StoryOption(icon: Icons.camera_alt, label: 'Kamera', onTap: () {}),
                _StoryOption(icon: Icons.gif_box, label: 'GIF', onTap: () {}),
              ],
            ),
            const Spacer(),
            AppButton(text: 'Hikaye Paylaş', onPressed: () => context.pop()),
          ],
        ),
      ),
    );
  }
}

class _StoryOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _StoryOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
