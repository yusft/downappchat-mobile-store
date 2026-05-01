import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:downapp/app/router.dart';
import 'package:downapp/core/widgets/app_text_field.dart';
import 'package:downapp/core/widgets/app_button.dart';
import 'package:downapp/app/theme/app_colors.dart';
import 'package:downapp/features/developer/presentation/providers/developer_provider.dart';
import 'package:downapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:downapp/features/marketplace/presentation/providers/marketplace_provider.dart';

class UploadAppPage extends ConsumerStatefulWidget {
  const UploadAppPage({super.key});

  @override
  ConsumerState<UploadAppPage> createState() => _UploadAppPageState();
}

class _UploadAppPageState extends ConsumerState<UploadAppPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _packageController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _descController = TextEditingController();
  final _versionController = TextEditingController(text: '1.0.0');
  final _changelogController = TextEditingController();

  String? _selectedCategory;
  final categories = ['Oyunlar', 'Araçlar', 'Sosyal', 'Eğitim', 'Müzik', 'Fotoğraf', 'Sağlık', 'Finans'];

  // Files
  File? _apkFile;
  File? _iconFile;
  final List<File> _screenshots = [];

  @override
  void dispose() {
    _nameController.dispose();
    _packageController.dispose();
    _shortDescController.dispose();
    _descController.dispose();
    _versionController.dispose();
    _changelogController.dispose();
    super.dispose();
  }

  Future<void> _pickApk() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['apk'],
    );
    if (result != null) {
      setState(() => _apkFile = File(result.files.single.path!));
    }
  }

  Future<void> _pickIcon() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _iconFile = File(image.path));
    }
  }

  Future<void> _pickScreenshot() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _screenshots.addAll(images.map((img) => File(img.path))));
    }
  }

  void _handleUpload() async {
    if (!_formKey.currentState!.validate()) return;
    if (_apkFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen bir APK dosyası seçin')));
      return;
    }
    if (_iconFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen bir uygulama ikonu seçin')));
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    await ref.read(developerNotifierProvider.notifier).uploadApp(
      developerId: currentUser.uid,
      developerName: currentUser.displayName,
      name: _nameController.text.trim(),
      packageName: _packageController.text.trim(),
      shortDescription: _shortDescController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory ?? 'Araçlar',
      version: _versionController.text.trim(),
      changelog: _changelogController.text.trim(),
      apkFile: _apkFile!,
      appIcon: _iconFile!,
      screenshots: _screenshots,
    );

    if (mounted) {
      final state = ref.read(developerNotifierProvider);
      if (!state.hasError) {
        // Listeleri yenile ki yeni uygulama anında görünsün
        ref.invalidate(developerAppsProvider(currentUser.uid));
        ref.invalidate(pendingAppsProvider);
        
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uygulama başarıyla yüklendi!')));
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: ${state.error}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final state = ref.watch(developerNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: const Text('Uygulama Yükle'),
      ),
      body: state.status.isLoading 
        ? Center(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 32),
                  Text('Uygulama Sunucuya Yükleniyor...', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: state.uploadProgress,
                    backgroundColor: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    minHeight: 10,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '%${(state.uploadProgress * 100).toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  const Text('Kendi sunucunuzda (VDS) işlem yapılıyor.\nYükleme hızınız internetinizin "Upload" hızına bağlıdır.', style: TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  const Text('⚠️ Eğer "Yüklenmedi" hatası sık sık oluyorsa, PocketBase Admin panelinden "apps" tablosundaki "apk" alanı için "Max size" limitini kontrol edip artırın (örn: 500MB = 524288000 byte).', style: TextStyle(fontSize: 11, color: Colors.orangeAccent), textAlign: TextAlign.center),
                ],
              ),
          ))
        : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // APK dosyası seç
              GestureDetector(
                onTap: _pickApk,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _apkFile != null ? AppColors.primary.withValues(alpha: 0.1) : (isDark ? AppColors.darkCard : AppColors.lightBackground),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary, width: 1.5, style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      Icon(_apkFile != null ? Icons.check_circle : Icons.upload_file, size: 48, color: AppColors.primary),
                      const SizedBox(height: 12),
                      Text(_apkFile != null ? 'APK Seçildi: ${_apkFile!.path.split('/').last}' : 'APK Dosyası Seç', 
                          style: theme.textTheme.titleSmall?.copyWith(color: AppColors.primary),
                          textAlign: TextAlign.center),
                      if (_apkFile == null) Text('Maksimum 500MB', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // İkon
              Center(
                child: GestureDetector(
                  onTap: _pickIcon,
                  child: Container(
                    width: 80, height: 80,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: _iconFile != null 
                        ? Image.file(_iconFile!, fit: BoxFit.cover)
                        : const Icon(Icons.add_photo_alternate, color: AppColors.primary, size: 32),
                  ),
                ),
              ),
              Center(child: Padding(padding: const EdgeInsets.only(top: 8), child: Text('Uygulama İkonu', style: theme.textTheme.bodySmall))),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Uygulama Adı', 
                hint: 'Harika Uygulama', 
                prefixIcon: Icons.apps,
                controller: _nameController,
                validator: (v) => v?.isEmpty ?? true ? 'Zorunlu' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Paket Adı', 
                hint: 'com.example.app', 
                prefixIcon: Icons.extension,
                controller: _packageController,
                validator: (v) => v?.isEmpty ?? true ? 'Zorunlu' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Kısa Açıklama', 
                hint: 'Tek cümlelik açıklama', 
                prefixIcon: Icons.short_text,
                controller: _shortDescController,
                validator: (v) => v?.isEmpty ?? true ? 'Zorunlu' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Açıklama', 
                hint: 'Detaylı açıklama...', 
                maxLines: 5, 
                prefixIcon: Icons.description,
                controller: _descController,
                validator: (v) => v?.isEmpty ?? true ? 'Zorunlu' : null,
              ),
              const SizedBox(height: 14),
              // Kategori
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Versiyon', 
                hint: '1.0.0', 
                prefixIcon: Icons.numbers,
                controller: _versionController,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Değişiklik Günlüğü', 
                hint: 'Bu versiyonda neler var...', 
                maxLines: 3, 
                prefixIcon: Icons.history,
                controller: _changelogController,
              ),
              const SizedBox(height: 14),
              // Ekran görüntüleri
              Text('Ekran Görüntüleri', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _screenshots.length + 1,
                  itemBuilder: (_, index) {
                    if (index == _screenshots.length) {
                      return GestureDetector(
                        onTap: _pickScreenshot,
                        child: Container(
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary, width: 1.5),
                          ),
                          child: const Center(child: Icon(Icons.add, color: AppColors.primary)),
                        ),
                      );
                    }
                    return Container(
                      width: 80, margin: const EdgeInsets.only(right: 8),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.file(_screenshots[index], fit: BoxFit.cover),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              AppButton(
                text: 'Yükle ve Onaya Gönder', 
                icon: Icons.cloud_upload, 
                onPressed: _handleUpload,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
