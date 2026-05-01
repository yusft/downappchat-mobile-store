import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:downapp/app/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:downapp/app/router.dart';
import 'package:downapp/features/marketplace/presentation/providers/marketplace_provider.dart';

class AdminPanelPage extends ConsumerWidget {
  const AdminPanelPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingAppsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        title: const Text('Admin Yönetim Paneli'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(pendingAppsProvider),
          ),
        ],
      ),
      body: pendingAsync.when(
        data: (apps) {
          if (apps.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: AppColors.accentGreen.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('Bekleyen uygulama bulunmuyor kanka! 😎', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Tüm pazar yeri tertemiz.', style: theme.textTheme.bodySmall),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            app.iconUrl,
                            width: 56,
                            height: 56,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              child: const Icon(Icons.apps, color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(app.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                              Text(app.packageName, style: theme.textTheme.bodySmall),
                              Text('Geliştirici: ${app.developerName}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.primary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(app.shortDescription, style: theme.textTheme.bodyMedium),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _handleReview(context, ref, app.appId, 'rejected'),
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Reddet'),
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleReview(context, ref, app.appId, 'approved'),
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Onayla'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentGreen,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
    );
  }

  Future<void> _handleReview(BuildContext context, WidgetRef ref, String appId, String status) async {
    final scaffold = ScaffoldMessenger.of(context);
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      final result = await repo.updateAppStatus(appId, status);
      
      result.fold(
        (failure) => scaffold.showSnackBar(SnackBar(content: Text('Hata: ${failure.message}'))),
        (_) {
          scaffold.showSnackBar(SnackBar(
            content: Text(status == 'approved' ? 'Uygulama onaylandı ve pazara salındı! 🚀' : 'Uygulama reddedildi! 🚫'),
            backgroundColor: status == 'approved' ? AppColors.accentGreen : Colors.red,
          ));
          ref.invalidate(pendingAppsProvider);
          // Tüm listeleri yenile ki pazarda görünsün
          ref.invalidate(newAppsProvider);
          ref.invalidate(trendingAppsProvider);
        },
      );
    } catch (e) {
      scaffold.showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }
}

