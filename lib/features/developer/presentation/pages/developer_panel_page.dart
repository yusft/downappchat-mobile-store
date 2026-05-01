import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:downapp/app/theme/app_colors.dart';
import 'package:downapp/app/router.dart';
import 'package:downapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:downapp/features/marketplace/presentation/providers/marketplace_provider.dart';
import 'package:downapp/features/stories/presentation/providers/story_provider.dart';
import 'package:downapp/app/di/providers.dart';

class DeveloperPanelPage extends ConsumerWidget {
  const DeveloperPanelPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Lütfen giriş yapın')));
    }

    final appsAsync = ref.watch(developerAppsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: const Text('Geliştirici Paneli'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => context.push(AppRoutes.uploadApp)),
        ],
      ),
      body: appsAsync.when(
        data: (apps) {
          final totalDownloads = apps.fold(0, (sum, app) => sum + app.downloadCount);
          final avgRating = apps.isEmpty ? 0.0 : apps.fold(0.0, (sum, app) => sum + app.ratingAverage) / apps.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // İstatistik kartları (Gerçek Veriler)
                Row(
                  children: [
                    _StatCard(title: 'Toplam İndirme', value: '$totalDownloads', icon: Icons.download, color: AppColors.primary),
                    const SizedBox(width: 12),
                    _StatCard(title: 'Uygulamalar', value: '${apps.length}', icon: Icons.apps, color: AppColors.accentGreen),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatCard(title: 'Ort. Puan', value: avgRating.toStringAsFixed(1), icon: Icons.star, color: AppColors.accentOrange),
                    const SizedBox(width: 12),
                    _StatCard(title: 'Durum', value: user.role == 'admin' ? 'Admin' : 'Dev', icon: Icons.verified_user, color: AppColors.secondary),
                  ],
                ),
                
                // ── Story Paylaş Bölümü ─────────────────
                const SizedBox(height: 24),
                Text('📸 Hikaye Paylaş', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Tüm kullanıcıların görebileceği bir hikaye paylaş.', style: theme.textTheme.bodySmall),
                const SizedBox(height: 12),
                _StoryCreationCard(isDark: isDark),

                const SizedBox(height: 24),
                Text('Uygulamalarım', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                
                if (apps.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        children: [
                          Icon(Icons.cloud_off, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          const Text('Henüz uygulama yüklememişsin kanka! 🚀', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  )
                else
                  ...apps.map((app) {
                    final statusColor = switch (app.status) {
                      'approved' => AppColors.accentGreen,
                      'pending' => AppColors.accentOrange,
                      'rejected' => Colors.red,
                      _ => Colors.grey,
                    };

                    final statusText = switch (app.status) {
                      'approved' => 'Onaylı',
                      'pending' => 'Beklemede',
                      'rejected' => 'Reddedildi',
                      _ => 'Bilinmiyor',
                    };

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              app.iconUrl,
                              width: 52,
                              height: 52,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 52, height: 52,
                                color: AppColors.primary.withValues(alpha: 0.1),
                                child: const Icon(Icons.apps, color: AppColors.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(app.name, style: theme.textTheme.titleSmall),
                              Text('${app.currentVersion} · ${app.downloadCount} indirme', style: theme.textTheme.bodySmall),
                            ],
                          )),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          );
        },
        loading: () => const Center(child: LoadingWidget()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.uploadApp),
        icon: const Icon(Icons.upload),
        label: const Text('Uygulama Yükle'),
      ),
    );
  }
}

/// Story oluşturma kartı — Developer panelinde
class _StoryCreationCard extends ConsumerStatefulWidget {
  final bool isDark;
  const _StoryCreationCard({required this.isDark});

  @override
  ConsumerState<_StoryCreationCard> createState() => _StoryCreationCardState();
}

class _StoryCreationCardState extends ConsumerState<_StoryCreationCard> {
  File? _selectedImage;
  final _captionController = TextEditingController();
  bool _isUploading = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1080, imageQuality: 85);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _pickCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, maxWidth: 1080, imageQuality: 85);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _publishStory() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir fotoğraf seçin.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final pb = ref.read(pocketBaseProvider);

      // 1. Dosyayı PocketBase'e yükle (stories collection'ına multipart)
      final now = DateTime.now().toUtc();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${pb.baseURL}/api/collections/stories/records'),
      );

      // Auth header
      if (pb.authStore.token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer ${pb.authStore.token}';
      }

      request.fields['userId'] = user.uid;
      request.fields['userName'] = user.displayName.isNotEmpty ? user.displayName : user.username;
      request.fields['userAvatar'] = user.avatarUrl;
      request.fields['mediaType'] = 'image';
      request.fields['caption'] = _captionController.text.trim();
      request.fields['viewCount'] = '0';
      request.fields['expiresAt'] = now.add(const Duration(hours: 12)).toIso8601String();

      request.files.add(
        await http.MultipartFile.fromPath(
          'mediaUrl', 
          _selectedImage!.path,
        )
      );

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Başarılı
        ref.invalidate(activeStoriesProvider('all'));

        if (mounted) {
          setState(() {
            _selectedImage = null;
            _captionController.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hikaye paylaşıldı! 🎉'), backgroundColor: AppColors.accentGreen),
          );
        }
      } else {
        // Multipart başarısız olduysa, text-only dene
        await ref.read(storyNotifierProvider.notifier).createStory(
          userId: user.uid,
          userName: user.displayName.isNotEmpty ? user.displayName : user.username,
          mediaUrl: '', // Dosyasız
          caption: _captionController.text.trim(),
        );
        
        ref.invalidate(activeStoriesProvider('all'));
        if (mounted) {
          setState(() {
            _selectedImage = null;
            _captionController.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hikaye paylaşıldı! 🎉'), backgroundColor: AppColors.accentGreen),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hikaye paylaşılamadı: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seçili görsel önizleme
          if (_selectedImage != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedImage!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedImage = null),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            )
          else
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.primary.withValues(alpha: 0.5)),
                    const SizedBox(height: 8),
                    Text('Fotoğraf Seç', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Caption
          TextField(
            controller: _captionController,
            decoration: InputDecoration(
              hintText: 'Hikaye açıklaması (opsiyonel)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            maxLines: 2,
            minLines: 1,
          ),

          const SizedBox(height: 12),

          // Butonlar
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _MiniActionButton(
                      icon: Icons.photo_library,
                      label: 'Galeri',
                      onTap: _pickImage,
                    ),
                    const SizedBox(width: 8),
                    _MiniActionButton(
                      icon: Icons.camera_alt,
                      label: 'Kamera',
                      onTap: _pickCamera,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _publishStory,
                  icon: _isUploading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(_isUploading ? 'Paylaşılıyor...' : 'Paylaş'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

class _MiniActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MiniActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ));
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator());
}

