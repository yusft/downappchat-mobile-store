import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:downapp/app/theme/app_colors.dart';
import 'package:downapp/core/widgets/app_button.dart';
import 'package:downapp/core/widgets/app_text_field.dart';
import 'package:downapp/app/di/providers.dart';
import 'package:downapp/features/auth/presentation/providers/auth_provider.dart';

class FeedbackPage extends ConsumerStatefulWidget {
  const FeedbackPage({super.key});

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendFeedback() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir mesaj girin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final pb = ref.read(pocketBaseProvider);
      final currentUser = ref.read(currentUserProvider);
      
      final body = {
        'message': message,
        if (currentUser != null) 'userId': currentUser.uid,
        if (currentUser != null) 'name': currentUser.displayName,
        if (currentUser != null) 'email': currentUser.email,
        if (currentUser == null) 'name': 'Anonim',
        'status': 'unread',
      };

      await pb.collection('feedbacks').create(body: body);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geri bildiriminiz başarıyla gönderildi. Teşekkür ederiz!'), backgroundColor: AppColors.accentGreen),
      );
      context.pop();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gönderilirken hata oluştu. Lütfen bağlantınızı kontrol edin veya yusuftek@yusuftek.com adresine mail atın.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Geri Bildirim'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.feedback_outlined, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Bize Ulaşın',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Uygulama ile ilgili fikirlerinizi, karşılaştığınız sorunları veya önerilerinizi sistemimiz üzerinden doğrudan bize iletebilirsiniz.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              AppTextField(
                label: 'Mesajınız',
                hint: 'Düşüncelerinizi buraya yazın...',
                maxLines: 8,
                controller: _messageController,
                prefixIcon: Icons.edit_note,
              ),
              const SizedBox(height: 32),
              _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : AppButton(
                    text: 'Geri Bildirimi Gönder',
                    icon: Icons.send,
                    onPressed: _sendFeedback,
                  ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Gönderilen mesajlar hesabınızla (isim ve e-posta) ilişkilendirilir.',
                  style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
      ),
    );
  }
}
