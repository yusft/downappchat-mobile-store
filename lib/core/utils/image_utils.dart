import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:downapp/core/constants/app_constants.dart';

/// Resim işleme yardımcı sınıfı
class ImageUtils {
  ImageUtils._();

  static final ImagePicker _picker = ImagePicker();

  /// Galeriden resim seç
  static Future<File?> pickImageFromGallery({
    int maxSizeMB = AppConstants.maxImageSizeMB,
    int? imageQuality,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality ?? 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (image == null) return null;

      final file = File(image.path);
      final sizeInMB = await file.length() / (1024 * 1024);
      if (sizeInMB > maxSizeMB) {
        throw Exception('Dosya boyutu ${maxSizeMB}MB\'dan büyük olamaz');
      }
      return file;
    } catch (e) {
      debugPrint('Resim seçme hatası: $e');
      rethrow;
    }
  }

  /// Kameradan resim çek
  static Future<File?> pickImageFromCamera({
    int? imageQuality,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality ?? 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      debugPrint('Kamera hatası: $e');
      rethrow;
    }
  }

  /// Birden fazla resim seç
  static Future<List<File>> pickMultipleImages({
    int maxCount = 5,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (images.length > maxCount) {
        throw Exception('En fazla $maxCount resim seçebilirsiniz');
      }
      return images.map((x) => File(x.path)).toList();
    } catch (e) {
      debugPrint('Çoklu resim seçme hatası: $e');
      rethrow;
    }
  }

  /// Resim seçim diyalogu göster
  static Future<File?> showImagePickerDialog(BuildContext context) async {
    File? selectedFile;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Galeriden Seç'),
                onTap: () async {
                  Navigator.pop(ctx);
                  selectedFile = await pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Fotoğraf Çek'),
                onTap: () async {
                  Navigator.pop(ctx);
                  selectedFile = await pickImageFromCamera();
                },
              ),
            ],
          ),
        ),
      ),
    );

    return selectedFile;
  }
}
