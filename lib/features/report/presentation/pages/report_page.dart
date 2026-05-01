import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:downapp/core/widgets/app_button.dart';
import 'package:downapp/core/widgets/app_text_field.dart';

class ReportPage extends StatefulWidget {
  final String type; // user, app, comment, chat
  final String targetId;
  const ReportPage({super.key, required this.type, required this.targetId});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String? _selectedReason;
  final _descController = TextEditingController();
  final reasons = [
    'Spam veya yanıltıcı içerik',
    'Uygunsuz içerik',
    'Taciz veya zorbalık',
    'Zararlı yazılım',
    'Telif hakkı ihlali',
    'Diğer',
  ];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
        title: const Text('Raporla'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Neden raporluyorsunuz?', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...reasons.map((r) => RadioListTile<String>(
              title: Text(r),
              value: r,
              // ignore: deprecated_member_use
              groupValue: _selectedReason,
              // ignore: deprecated_member_use
              onChanged: (v) => setState(() => _selectedReason = v),
              contentPadding: EdgeInsets.zero,
            )),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Açıklama (İsteğe bağlı)',
              hint: 'Detaylı açıklama...',
              controller: _descController,
              maxLines: 4,
              prefixIcon: Icons.description,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Raporu Gönder',
              type: AppButtonType.danger,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Raporunuz incelenmek üzere gönderildi')),
                );
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
