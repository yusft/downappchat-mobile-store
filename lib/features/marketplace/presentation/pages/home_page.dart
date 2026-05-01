import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:downapp/app/theme/app_colors.dart';
import 'package:downapp/app/router.dart';
import 'package:downapp/core/utils/formatters.dart';
import 'package:downapp/features/marketplace/presentation/providers/marketplace_provider.dart';
import 'package:downapp/features/stories/presentation/providers/story_provider.dart';
import 'package:downapp/features/stories/domain/entities/story_entity.dart';
import 'package:downapp/features/marketplace/domain/entities/app_entity.dart';
import 'package:downapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:downapp/features/notifications/presentation/providers/notification_provider.dart';

/// Ana sayfa — Marketplace kullanıcı arayüzü
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // Kategoriler henüz Firestore'da yoksa fallback olarak kullanılır
  static const List<Map<String, dynamic>> _fallbackCategories = [
    {'name': 'Oyunlar', 'icon': Icons.sports_esports_rounded, 'color': AppColors.primary},
    {'name': 'Araçlar', 'icon': Icons.build_rounded, 'color': AppColors.accentOrange},
    {'name': 'Sosyal', 'icon': Icons.people_rounded, 'color': AppColors.secondary},
    {'name': 'Eğitim', 'icon': Icons.school_rounded, 'color': AppColors.accentGreen},
    {'name': 'Müzik', 'icon': Icons.music_note_rounded, 'color': AppColors.accentPurple},
    {'name': 'Fotoğraf', 'icon': Icons.camera_alt_rounded, 'color': AppColors.accent},
    {'name': 'Sağlık', 'icon': Icons.favorite_rounded, 'color': Color(0xFFEF4444)},
    {'name': 'Finans', 'icon': Icons.account_balance_rounded, 'color': Color(0xFF14B8A6)},
  ];



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final trendingAsync = ref.watch(trendingAppsProvider);
    final newAppsAsync = ref.watch(newAppsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            toolbarHeight: 64,
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'DownApp',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () => context.push(AppRoutes.search),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final user = ref.watch(currentUserProvider);
                  final hasUnread = user != null ? ref.watch(hasUnreadNotificationsProvider(user.uid)) : false;
                  return IconButton(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.notifications_outlined),
                        if (hasUnread)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: () => context.push(AppRoutes.notifications),
                  );
                },
              ),
              const SizedBox(width: 4),
            ],
          ),

          // ── Story bar ────────────────────────────
          SliverToBoxAdapter(
            child: Consumer(
              builder: (context, ref, child) {
                final storiesAsync = ref.watch(activeStoriesProvider('all'));
                final user = ref.watch(currentUserProvider);
                final isDeveloper = user?.isDeveloper ?? false;
                
                return storiesAsync.when(
                  data: (stories) {
                    // Benzersiz kullanıcıları filtrele (Her kullanıcı için sadece ilk hikayesini göster)
                    final groupedStories = <StoryEntity>[];
                    final seenUsers = <String>{};
                    for (var s in stories) {
                      if (!seenUsers.contains(s.userId)) {
                        seenUsers.add(s.userId);
                        groupedStories.add(s);
                      }
                    }

                    // Story yoksa ve developer değilse hiç gösterme
                    if (groupedStories.isEmpty && !isDeveloper) {
                      return const SizedBox.shrink();
                    }
                    
                    final totalCount = groupedStories.length + (isDeveloper ? 1 : 0);
                    
                    return SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: totalCount,
                        itemBuilder: (context, index) {
                          if (isDeveloper && index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () => context.push(AppRoutes.developerPanel),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 64,
                                          height: 64,
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                              width: 1,
                                            ),
                                          ),
                                          child: CircleAvatar(
                                            backgroundImage: user?.avatarUrl.isNotEmpty == true ? NetworkImage(user!.avatarUrl) : null,
                                            child: user?.avatarUrl.isEmpty == true ? const Icon(Icons.person, color: Colors.grey) : null,
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: isDark ? const Color(0xFF0F0F13) : Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF0095F6),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.add, color: Colors.white, size: 12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text('Sen', style: theme.textTheme.labelSmall),
                                ],
                              ),
                            );
                          }
                          
                          final storyIndex = isDeveloper ? index - 1 : index;
                          if (storyIndex < 0 || storyIndex >= groupedStories.length) return const SizedBox.shrink();
                          final story = groupedStories[storyIndex];
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () => context.push('/story/${story.userId}'),
                              child: Column(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: AppColors.primaryGradient,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: theme.scaffoldBackgroundColor,
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: CircleAvatar(
                                        backgroundImage: story.userAvatar.isNotEmpty ? NetworkImage(story.userAvatar) : null,
                                        child: story.userAvatar.isEmpty 
                                            ? Text(story.userName.isNotEmpty ? story.userName.substring(0, 1).toUpperCase() : '?') 
                                            : null,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    width: 64,
                                    child: Text(
                                      story.userName,
                                      style: theme.textTheme.labelSmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => isDeveloper 
                      ? const SizedBox(height: 16) 
                      : const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),
          ),


          // ── Kategoriler ──────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kategoriler',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Tümü')),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _fallbackCategories.length,
                itemBuilder: (context, index) {
                  final cat = _fallbackCategories[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => context.push('/category/${cat['name']}'),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: (cat['color'] as Color).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              cat['icon'] as IconData,
                              color: cat['color'] as Color,
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cat['name'] as String,
                            style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(
                    duration: 300.ms,
                    delay: Duration(milliseconds: 50 * index),
                  );
                },
              ),
            ),
          ),

          // ── Trend Uygulamalar ─────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🔥 Trend Uygulamalar',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Tümü')),
                ],
              ),
            ),
          ),

          // Trend uygulamalar — Provider veya fallback
          trendingAsync.when(
            data: (apps) => apps.isEmpty
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('Henüz uygulama bulunamadı.')),
                    ),
                  )
                : _buildEntityTrendingList(apps),
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (err, __) => SliverToBoxAdapter(child: Center(child: Text('Hata: $err'))),
          ),

          // ── Yeni Eklenenler ───────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                '✨ Yeni Eklenenler',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),

          // Yeni uygulamalar — Provider veya fallback
          SliverToBoxAdapter(
            child: newAppsAsync.when(
              data: (apps) => apps.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('Henüz yeni uygulama yok.')),
                    )
                  : _buildEntityNewAppsList(apps, isDark),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, __) => Center(child: Text('Hata: $err')),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ── Trend uygulamalar — Entity verileri ile ────────

  Widget _buildEntityTrendingList(List<AppEntity> apps) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final app = apps[index];
          return _AppListItem(
            name: app.name,
            developer: app.developerName,
            rating: app.ratingAverage,
            downloads: app.downloadCount,
            iconUrl: app.iconUrl,
            color: AppColors.getCategoryColor(index),
            index: index,
            onTap: () => context.push('/app/${app.appId}'),
          );
        },
        childCount: apps.length,
      ),
    );
  }


  // ── Yeni uygulamalar — Entity verileri ile ─────────

  Widget _buildEntityNewAppsList(List<AppEntity> apps, bool isDark) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: apps.length,
        itemBuilder: (context, index) {
          final app = apps[index];
          final color = AppColors.getCategoryColor(index);
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => context.push('/app/${app.appId}'),
              child: Container(
                width: 140,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 0.5,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52, height: 52,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: app.iconUrl.isNotEmpty
                          ? Image.network(app.iconUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Image.asset('assets/images/logo.png', width: 26, height: 26))
                          : Image.asset('assets/images/logo.png', width: 26, height: 26),
                    ),
                    const SizedBox(height: 12),
                    Text(app.name, style: theme.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(app.developerName, style: theme.textTheme.bodySmall),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(app.ratingAverage.toStringAsFixed(1), style: theme.textTheme.labelSmall),
                        const Spacer(),
                        Text(
                          'Ücretsiz',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.accentGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 80 * index));
        },
      ),
    );
  }

}

/// Uygulama liste öğesi widget'ı
class _AppListItem extends StatelessWidget {
  final String name;
  final String developer;
  final double rating;
  final int downloads;
  final String iconUrl;
  final Color color;
  final int index;
  final VoidCallback onTap;

  const _AppListItem({
    required this.name,
    required this.developer,
    required this.rating,
    required this.downloads,
    required this.iconUrl,
    required this.color,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Text(
                '${index + 1}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: index < 3 ? AppColors.primary : theme.textTheme.bodySmall?.color,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 56, height: 56,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: iconUrl.isNotEmpty
                  ? Image.network(iconUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Image.asset('assets/images/logo.png', width: 28, height: 28))
                  : Image.asset('assets/images/logo.png', width: 28, height: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(developer, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(rating.toString(), style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      Icon(Icons.download_rounded, size: 14, color: theme.textTheme.bodySmall?.color),
                      const SizedBox(width: 4),
                      Text(Formatters.formatCount(downloads), style: theme.textTheme.labelSmall),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'İndir',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 60 * index)).slideX(begin: 0.05);
  }
}

