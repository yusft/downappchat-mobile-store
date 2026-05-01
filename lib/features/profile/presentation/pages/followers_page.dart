import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:downapp/core/widgets/app_avatar.dart';
import 'package:downapp/core/widgets/loading_widget.dart';
import 'package:downapp/core/widgets/error_widget.dart';
import 'package:downapp/features/profile/presentation/providers/profile_provider.dart';
import 'package:downapp/features/auth/domain/entities/user_entity.dart';
import 'package:downapp/app/theme/app_colors.dart';

/// Takipçiler / Takip edilenler sayfası
class FollowersPage extends ConsumerWidget {
  final String userId;
  final bool isFollowers;

  const FollowersPage({super.key, required this.userId, required this.isFollowers});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Geçici provider: ilerde profile_provider.dart içine taşınabilir
    final usersAsync = ref.watch(FutureProvider<List<UserEntity>>((ref) async {
      final repo = ref.watch(profileRepositoryProvider);
      final result = isFollowers 
        ? await repo.getFollowers(userId) 
        : await repo.getFollowing(userId);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (users) => users,
      );
    }));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(isFollowers ? 'Takipçiler' : 'Takip Edilenler'),
      ),
      body: usersAsync.when(
        loading: () => const LoadingWidget(),
        error: (err, _) => AppErrorWidget(message: err.toString()),
        data: (users) {
          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline, size: 64, color: theme.disabledColor),
                  const SizedBox(height: 16),
                  Text(
                    isFollowers ? 'Henüz takipçiniz yok' : 'Henüz kimseyi takip etmiyorsunuz',
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.disabledColor),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: AppAvatar(
                  imageUrl: user.avatarUrl,
                  size: 44,
                ),
                title: Row(
                  children: [
                    Text(user.displayName, style: theme.textTheme.titleSmall),
                    if (user.badges.contains('verified')) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, size: 14, color: AppColors.verifiedBadge),
                    ],
                  ],
                ),
                subtitle: Text('@${user.username}', style: theme.textTheme.bodySmall),
                trailing: isFollowers 
                  ? null // Takipçiler listesinde buton genelde "Kaldır" olur, opsiyonel.
                  : OutlinedButton(
                      onPressed: () {
                        // Takibi bırak işlemi
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Takibi Bırak', style: TextStyle(fontSize: 11)),
                    ),
                onTap: () => context.push('/profile/${user.uid}'),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              );
            },
          );
        },
      ),
    );
  }
}

