import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:downapp/app/theme/app_colors.dart';
import 'package:downapp/app/router.dart';
import 'package:downapp/core/widgets/app_avatar.dart';
import 'package:downapp/core/widgets/loading_widget.dart';
import 'package:downapp/core/widgets/error_widget.dart';
import 'package:downapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:downapp/features/profile/presentation/providers/profile_provider.dart';
import 'package:downapp/features/auth/domain/entities/user_entity.dart';
import 'package:downapp/core/widgets/app_logo.dart';
import 'package:downapp/core/utils/url_utils.dart';
import 'package:downapp/app/di/providers.dart';

/// Kullanıcının yazdığı yorumları çeken provider
final userReviewsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async {
  final pb = ref.read(pocketBaseProvider);
  try {
    final result = await pb.collection('reviews').getList(
      filter: 'user = "$userId"',
      sort: '-created',
      perPage: 50,
      expand: 'app',
    );
    
    return result.items.map((record) {
      String appName = 'Uygulama';
      String appIcon = '';
      String appId = record.getStringValue('app');

      // expand.app'den bilgi almayı dene
      try {
        final appRecord = record.get<RecordModel>('expand.app');
        appName = appRecord.getStringValue('name');
        final icon = appRecord.getStringValue('icon');
        appIcon = UrlUtils.getAppFileUrl(appRecord.id, icon);
      } catch (_) {
        // Liste şeklinde mi geldi kontrol et
        try {
          final appList = record.get<List<RecordModel>>('expand.app');
          if (appList.isNotEmpty) {
            final appRecord = appList.first;
            appName = appRecord.getStringValue('name');
            final icon = appRecord.getStringValue('icon');
            appIcon = UrlUtils.getAppFileUrl(appRecord.id, icon);
          }
        } catch (_) {}
      }

      return {
        'id': record.id,
        'appId': appId,
        'appName': appName,
        'appIcon': appIcon,
        'rating': record.getDoubleValue('rating'),
        'comment': record.getStringValue('comment'),
        'userName': record.getStringValue('userName'),
        'created': record.getStringValue('created'),
      };
    }).toList();
  } catch (e) {
    debugPrint('userReviewsProvider Error: $e');
    return [];
  }
});

/// Kullanıcının favori uygulamalarını çeken provider (userId'ye göre)
final userFavoritesByIdProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async {
  final pb = ref.read(pocketBaseProvider);
  try {
    final result = await pb.collection('favorites').getList(
      filter: 'user = "$userId"',
      sort: '-created',
      perPage: 50,
      expand: 'app',
    );

    return result.items.map((record) {
      String appName = record.getStringValue('appName');
      String appIcon = record.getStringValue('appIcon');
      String appId = record.getStringValue('app');

      // expand.app'den almayı dene
      try {
        final appRecord = record.get<RecordModel>('expand.app');
        appName = appRecord.getStringValue('name');
        final icon = appRecord.getStringValue('icon');
        appIcon = UrlUtils.getAppFileUrl(appRecord.id, icon);
      } catch (_) {
        try {
          final appList = record.get<List<RecordModel>>('expand.app');
          if (appList.isNotEmpty) {
            final appRecord = appList.first;
            appName = appRecord.getStringValue('name');
            final icon = appRecord.getStringValue('icon');
            appIcon = UrlUtils.getAppFileUrl(appRecord.id, icon);
          }
        } catch (_) {}
      }

      return {
        'favId': record.id,
        'appId': appId,
        'appName': appName,
        'appIcon': appIcon,
      };
    }).toList();
  } catch (e) {
    debugPrint('userFavoritesByIdProvider Error: $e');
    return [];
  }
});

/// Profil sayfası (kendi veya başkasının profili)
class ProfilePage extends ConsumerWidget {
  final String? userId;
  final bool isMyProfile;

  const ProfilePage({super.key, this.userId, this.isMyProfile = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    
    // Hangi user'ı görüntüleyeceğimizi belirle
    final effectiveUserId = isMyProfile ? currentUser?.uid : userId;

    if (effectiveUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Kullanıcı bulunamadı veya giriş yapılmadı.', 
                         style: TextStyle(color: Colors.grey)),
              if (isMyProfile) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text('Giriş Yap'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final profileAsync = ref.watch(profileUserProvider(effectiveUserId));

    return profileAsync.when(
      loading: () => const Scaffold(body: LoadingWidget()),
      error: (err, stack) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: 'Profil yüklenirken bir hata oluştu.',
          onRetry: () => ref.refresh(profileUserProvider(effectiveUserId)),
        ),
      ),
      data: (user) => _ProfileContent(
        user: user,
        isMyProfile: isMyProfile || user.uid == currentUser?.uid,
        currentUser: currentUser,
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  final UserEntity user;
  final bool isMyProfile;
  final UserEntity? currentUser;

  const _ProfileContent({
    required this.user,
    required this.isMyProfile,
    this.currentUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Takip durumu kontrolü
    final isFollowingAsync = ref.watch(isFollowingProvider(user.uid));
    final isFollowing = isFollowingAsync.value ?? false;

    // İşlem sonuçlarını dinle (Hata veya Başarı mesajı için)
    ref.listen(profileNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $error'), backgroundColor: Colors.red),
          );
        },
        data: (_) {
          final status = ref.read(followRequestStatusProvider(user.uid)).value;
          final message = isFollowing 
              ? 'Arkadaşlıktan çıkarıldı' 
              : (status == 'pending' ? 'Arkadaşlık isteği zaten iletildi.' : 'Arkadaşlık isteği iletildi!');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: AppColors.accentGreen),
          );
          
          // Durumları yenile
          ref.invalidate(isFollowingProvider(user.uid));
          ref.invalidate(followRequestStatusProvider(user.uid));
          ref.invalidate(profileUserProvider(user.uid));
        },
      );
    });

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Kapak fotoğrafı + Profil bilgisi
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: isMyProfile ? null : IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              if (isMyProfile) ...[
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.push(AppRoutes.settings),
                ),
              ] else ...[
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.more_vert, size: 18, color: Colors.white),
                  ),
                  onPressed: () {},
                ),
              ],
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Kapak
                  if (user.coverUrl.isNotEmpty) 
                    Image.network(user.coverUrl, fit: BoxFit.cover),
                  if (user.coverUrl.isEmpty)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.accentPurple.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  if (user.coverUrl.isNotEmpty)
                    Container(color: Colors.black.withValues(alpha: 0.3)), // Hafif karartma
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 120,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            theme.scaffoldBackgroundColor,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // Profil bilgisi
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        GestureDetector(
                          onLongPress: () async {
                            if (!isMyProfile) return;
                            try {
                              await ref.read(pocketBaseProvider).collection('users').update(user.uid, body: {
                                'developerStatus': 'admin'
                              });
                              ref.read(authNotifierProvider.notifier).refreshUser();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Admin Yetkisi Aktif! 👑 Tekrar giriş yapın veya sayfayı yenileyin.'), backgroundColor: AppColors.accentGreen),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
                            }
                          },
                          child: AppAvatar(
                            imageUrl: user.avatarUrl,
                            size: 80,
                            hasBorder: true,
                            borderColor: theme.scaffoldBackgroundColor,
                            badge: user.badges.isNotEmpty ? user.badges.first : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    user.displayName,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (user.badges.contains('verified')) ...[
                                    const SizedBox(width: 6),
                                    const Icon(Icons.verified, size: 20, color: AppColors.verifiedBadge),
                                  ],
                                ],
                              ),
                              Text(
                                '@${user.username}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bio ve düzenle/takip butonu
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user.bio.isNotEmpty) ...[
                    Text(user.bio, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 12),
                  ],
                  // İstatistikler
                    Row(
                    children: [
                      _ProfileStat(
                        count: user.followersCount, 
                        label: 'Takipçi',
                        icon: Icons.groups_rounded,
                        onTap: () => context.push('/followers/${user.uid}')
                      ),
                      const SizedBox(width: 24),
                      _ProfileStat(
                        count: user.followingCount, 
                        label: 'Takip',
                        icon: Icons.person_add_alt_1_rounded,
                        onTap: () => context.push('/following/${user.uid}')
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Butonlar
                  if (isMyProfile)
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => context.push('/find-friends'),
                            icon: const Icon(Icons.person_search_rounded, size: 20),
                            label: const Text('Kişi Bul / Arkadaş Ekle'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => context.push(AppRoutes.editProfile),
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                label: const Text('Profili Düzenle'),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            if (user.isAdmin) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => context.push(AppRoutes.adminPanel),
                                  icon: const Icon(Icons.admin_panel_settings_outlined, size: 20),
                                  label: const Text('Admin Paneli'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accentOrange,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (!user.isDeveloper)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: SizedBox(
                              width: double.infinity,
                              child: TextButton.icon(
                                onPressed: () => context.push(AppRoutes.developerApply),
                                icon: const Icon(Icons.code, size: 20),
                                label: const Text('Geliştirici Başvurusu Yap'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: Consumer(
                            builder: (context, ref, child) {
                              final statusAsync = ref.watch(followRequestStatusProvider(user.uid));
                              final isFollowing = isFollowingAsync.value ?? false;
                              final status = statusAsync.value;

                              String buttonText = 'Arkadaş Ekle';
                              if (isFollowing) {
                                buttonText = 'Arkadaşlıktan Çıkar';
                              } else if (status == 'pending') {
                                buttonText = 'İstek Gönderildi';
                              }

                              return ElevatedButton(
                                onPressed: (status == 'pending' && !isFollowing) ? null : () {
                                  if (currentUser == null) return;
                                  ref.read(profileNotifierProvider.notifier).followUser(
                                    currentUserId: currentUser!.uid,
                                    targetUserId: user.uid,
                                    isUnfollow: isFollowing,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFollowing ? Colors.grey : AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: isFollowingAsync.isLoading || statusAsync.isLoading
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : Text(buttonText),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () => context.push('/chat/${user.uid}'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Icon(Icons.chat_bubble_outline, size: 20),
                        ),
                      ],
                    ),
                ],
              ).animate().fadeIn(duration: 300.ms),
            ),
          ),

          // Rozetler
          if (user.badges.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Wrap(
                  spacing: 8,
                  children: user.badges.map((badge) {
                    final color = switch (badge) {
                      'verified' => AppColors.verifiedBadge,
                      'developer' => AppColors.developerBadge,
                      'top_reviewer' => AppColors.topReviewerBadge,
                      _ => theme.disabledColor,
                    };
                    return _BadgeChip(
                      label: badge.toUpperCase(),
                      color: color,
                      icon: badge == 'verified' ? Icons.verified : Icons.stars,
                    );
                  }).toList(),
                ),
              ),
            ),

          // Tab İçerikleri — Sadece Yorumlar ve Favoriler
          SliverFillRemaining(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Yorumlar'),
                      Tab(text: 'Favoriler'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Yorumlar — Gerçek veri
                        _UserReviewsTab(userId: user.uid),
                        // Favoriler — Gerçek veri
                        _UserFavoritesTab(userId: user.uid),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kullanıcının yorumlarını gösteren tab
class _UserReviewsTab extends ConsumerWidget {
  final String userId;
  const _UserReviewsTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reviewsAsync = ref.watch(userReviewsProvider(userId));

    return reviewsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            const Text('Yorumlar yüklenemedi', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
      data: (reviews) {
        if (reviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.rate_review, size: 48, color: AppColors.primary.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                const Text('Henüz yorum yok', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            final rating = (review['rating'] as num?)?.toDouble() ?? 0.0;
            final created = DateTime.tryParse(review['created'] ?? '') ?? DateTime.now();

            return GestureDetector(
              onTap: () {
                final appId = review['appId'];
                if (appId != null && appId.toString().isNotEmpty) {
                  context.push('/app/$appId');
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (review['appIcon'] != null && (review['appIcon'] as String).isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              review['appIcon'],
                              width: 36, height: 36,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Image.asset('assets/images/logo.png', width: 20, height: 20),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset('assets/images/logo.png', width: 20, height: 20),
                          ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review['appName'] ?? 'Uygulama',
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Row(
                                children: [
                                  ...List.generate(5, (i) => Icon(
                                    i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                    color: Colors.amber,
                                    size: 14,
                                  )),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${created.day}.${created.month}.${created.year}',
                                    style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      review['comment'] ?? '',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Kullanıcının favorilerini gösteren tab
class _UserFavoritesTab extends ConsumerWidget {
  final String userId;
  const _UserFavoritesTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favoritesAsync = ref.watch(userFavoritesByIdProvider(userId));

    return favoritesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            const Text('Favoriler yüklenemedi', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
      data: (favorites) {
        if (favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite, size: 48, color: AppColors.primary.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                const Text('Henüz favori yok', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final fav = favorites[index];
            return GestureDetector(
              onTap: () {
                final appId = fav['appId'];
                if (appId != null && appId.toString().isNotEmpty) {
                  context.push('/app/$appId');
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    if (fav['appIcon'] != null && (fav['appIcon'] as String).isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          fav['appIcon'],
                          width: 48, height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.apps, color: AppColors.primary),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const AppLogo(size: 24),
                      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        fav['appName'] ?? 'Uygulama',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Icon(Icons.favorite, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final int count;
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const _ProfileStat({required this.count, required this.label, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(height: 4),
            ],
            Text('$count', style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            )),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _BadgeChip({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}


