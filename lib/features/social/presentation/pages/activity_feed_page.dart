import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:downapp/app/theme/app_colors.dart';
import 'package:downapp/features/social/presentation/providers/social_provider.dart';
import 'package:downapp/features/social/data/models/activity_model.dart';

class ActivityFeedPage extends ConsumerWidget {
  const ActivityFeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activitiesAsync = ref.watch(activitiesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Aktivite Akışı'),
      ),
      body: activitiesAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
            return Center(
              child: Text(
                'Henüz bir aktivite yok.',
                style: theme.textTheme.bodyMedium,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              final iconData = _getIcon(activity.type);
              final color = _getColor(activity.type);

              return ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: activity.userAvatar != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.network(activity.userAvatar!, fit: BoxFit.cover),
                        )
                      : Icon(iconData, color: color, size: 20),
                ),
                title: Text(
                  _getText(activity),
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${activity.createdAt.day}.${activity.createdAt.month}.${activity.createdAt.year}',
                  style: theme.textTheme.bodySmall,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
    );
  }

  IconData _getIcon(ActivityType type) {
    switch (type) {
      case ActivityType.follow: return Icons.person_add;
      case ActivityType.upload: return Icons.cloud_upload;
      case ActivityType.favorite: return Icons.favorite;
      case ActivityType.download: return Icons.download;
      default: return Icons.notifications;
    }
  }

  Color _getColor(ActivityType type) {
    switch (type) {
      case ActivityType.follow: return AppColors.primary;
      case ActivityType.upload: return AppColors.accentGreen;
      case ActivityType.favorite: return AppColors.secondary;
      case ActivityType.download: return AppColors.accent;
      default: return Colors.grey;
    }
  }

  String _getText(ActivityModel activity) {
    final userName = activity.userName ?? 'Bir kullanıcı';
    switch (activity.type) {
      case ActivityType.follow: return '$userName seni takip etti!';
      case ActivityType.upload: return '$userName yeni bir uygulama yüklendi: ${activity.targetName}';
      case ActivityType.favorite: return '$userName ${activity.targetName} uygulamasını favorilerine ekledi!';
      case ActivityType.download: return '$userName bir uygulama indirdi.';
      default: return 'Yeni bir aktivite var.';
    }
  }
}
