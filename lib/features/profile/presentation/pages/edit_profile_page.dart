import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:downapp/core/widgets/app_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:downapp/core/widgets/app_text_field.dart';
import 'package:downapp/core/widgets/app_button.dart';
import 'package:downapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:downapp/features/profile/presentation/providers/profile_provider.dart';
import 'package:downapp/app/theme/app_colors.dart';

/// Profil düzenleme sayfası
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _websiteController = TextEditingController();
  File? _selectedImage;
  File? _selectedCoverImage;
  String? _currentAvatarUrl;
  String? _currentCoverUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        _nameController.text = user.displayName;
        _usernameController.text = user.username;
        _bioController.text = user.bio;
        _websiteController.text = user.website;
        _currentAvatarUrl = user.avatarUrl;
        _currentCoverUrl = user.coverUrl;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    if (_selectedImage != null) {
      await ref.read(profileNotifierProvider.notifier).uploadAvatar(
        userId: user.uid,
        file: _selectedImage!,
      );
    }

    if (_selectedCoverImage != null) {
      await ref.read(profileNotifierProvider.notifier).uploadCover(
        userId: user.uid,
        file: _selectedCoverImage!,
      );
    }

    await ref.read(profileNotifierProvider.notifier).updateProfile(
      userId: user.uid,
      displayName: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      website: _websiteController.text.trim(),
    );

    if (mounted) {
      final state = ref.read(profileNotifierProvider);
      if (!state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil başarıyla güncellendi'), backgroundColor: AppColors.success),
        );
        context.pop();
        // Refresh profile data
        ref.invalidate(profileUserProvider(user.uid));
        ref.read(authNotifierProvider.notifier).refreshUser();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileState = ref.watch(profileNotifierProvider);
    final isLoading = profileState.isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, size: 24),
          onPressed: () => context.pop(),
        ),
        title: const Text('Profili Düzenle'),
        actions: [
          if (!isLoading)
            TextButton(
              onPressed: _handleSave,
              child: const Text('Kaydet'),
            )
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // Kapak fotoğrafı değiştirme
            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() => _selectedCoverImage = File(image.path));
                }
              },
              child: Stack(
                children: [
                   Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      image: _selectedCoverImage != null
                          ? DecorationImage(image: FileImage(_selectedCoverImage!), fit: BoxFit.cover)
                          : (_currentCoverUrl != null && _currentCoverUrl!.isNotEmpty
                              ? DecorationImage(image: NetworkImage(_currentCoverUrl!), fit: BoxFit.cover)
                              : null),
                    ),
                    child: (_selectedCoverImage == null && (_currentCoverUrl == null || _currentCoverUrl!.isEmpty))
                        ? Center(child: Icon(Icons.add_photo_alternate_outlined, size: 40, color: theme.colorScheme.primary))
                        : null,
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Avatar değiştirme
            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() => _selectedImage = File(image.path));
                }
              },
              child: Stack(
                children: [
                  if (_selectedImage != null)
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: FileImage(_selectedImage!),
                    )
                  else if (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty)
                    AppAvatar(imageUrl: _currentAvatarUrl!, size: 100)
                  else
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                      child: Icon(Icons.person, size: 50, color: theme.colorScheme.primary),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppTextField(label: 'Ad Soyad', controller: _nameController, prefixIcon: Icons.person_outlined, enabled: !isLoading),
            const SizedBox(height: 16),
            AppTextField(label: 'Kullanıcı Adı', controller: _usernameController, prefixIcon: Icons.alternate_email, enabled: false), // Username genelde değişmez veya özel işlem gerekir
            const SizedBox(height: 16),
            AppTextField(label: 'Biyografi', controller: _bioController, maxLines: 3, prefixIcon: Icons.info_outlined, enabled: !isLoading),
            const SizedBox(height: 16),
            AppTextField(label: 'Web Sitesi', controller: _websiteController, prefixIcon: Icons.link, keyboardType: TextInputType.url, enabled: !isLoading),
            const SizedBox(height: 32),
            AppButton(
              text: 'Değişiklikleri Kaydet', 
              onPressed: _handleSave,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

