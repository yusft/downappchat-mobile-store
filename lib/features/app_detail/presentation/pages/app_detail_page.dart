import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:share_plus/share_plus.dart';
import 'package:downapp/app/theme/app_colors.dart';
import 'package:downapp/core/utils/formatters.dart';
import 'package:downapp/features/marketplace/presentation/providers/marketplace_provider.dart';
import 'package:downapp/features/marketplace/domain/entities/app_entity.dart';
import 'package:downapp/features/download/presentation/providers/download_provider.dart';
import 'package:downapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:downapp/features/profile/presentation/pages/profile_page.dart';
import 'package:downapp/core/utils/url_utils.dart';
import 'package:downapp/app/di/providers.dart';

/// Universal share link base URL
const String _shareBaseUrl = 'https://YOUR_DOMAIN';

/// Yorum modeli
class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar = '',
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}

/// Yorumları çeken provider
final appReviewsProvider = FutureProvider.family<List<ReviewModel>, String>((
  ref,
  appId,
) async {
  final pb = ref.read(pocketBaseProvider);
  try {
    final result = await pb
        .collection('reviews')
        .getList(
          page: 1,
          perPage: 50,
          filter: 'app = "${appId.trim()}"',
          sort: '-created',
          expand: 'user',
        );

    return result.items.map((record) {
      String userName = record.getStringValue('userName');
      String userAvatar = '';

      // expand.user'dan bilgi almayı dene (Yeni SDK yapısı)
      try {
        final userRecord = record.get<RecordModel>('expand.user');
        final dn = userRecord.getStringValue('displayName');
        final un = userRecord.getStringValue('username');
        if (dn.isNotEmpty) {
          userName = dn;
        } else if (un.isNotEmpty) {
          userName = un;
        }
        
        final avatar = userRecord.getStringValue('avatar');
        userAvatar = UrlUtils.getUserAvatarUrl(userRecord.id, avatar);
      } catch (_) {
        // Liste şeklinde expand edilmiş olabilir
        try {
          final users = record.get<List<RecordModel>>('expand.user');
          if (users.isNotEmpty) {
            final userRecord = users.first;
            userName = userRecord.getStringValue('displayName').isNotEmpty 
                ? userRecord.getStringValue('displayName') 
                : userRecord.getStringValue('username');
            
            final avatar = userRecord.getStringValue('avatar');
            userAvatar = UrlUtils.getUserAvatarUrl(userRecord.id, avatar);
          }
        } catch (_) {}
      }

      return ReviewModel(
        id: record.id,
        userId: record.getStringValue('user'),
        userName: userName.isNotEmpty ? userName : 'Kullanıcı',
        userAvatar: userAvatar,
        rating: record.getDoubleValue('rating'),
        comment: record.getStringValue('comment'),
        createdAt: DateTime.tryParse(record.getStringValue('created')) ?? DateTime.now(),
      );
    }).toList();
  } catch (e) {
    // reviews collection yoksa boş döndür
    return [];
  }
});

/// Favori durumu kontrolü
final isFavoritedProvider = FutureProvider.family<bool, String>((ref, appId) async {
  final user = ref.read(currentUserProvider);
  if (user == null) return false;
  final pb = ref.read(pocketBaseProvider);
  try {
    final result = await pb.collection('favorites').getList(
      filter: 'user = "${user.uid}" && app = "$appId"',
      perPage: 1,
    );
    return result.items.isNotEmpty;
  } catch (_) {
    return false;
  }
});

/// Uygulama detay sayfası
class AppDetailPage extends ConsumerStatefulWidget {
  final String appId;

  const AppDetailPage({super.key, required this.appId});

  @override
  ConsumerState<AppDetailPage> createState() => _AppDetailPageState();
}

class _AppDetailPageState extends ConsumerState<AppDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appAsync = ref.watch(appDetailProvider(widget.appId));

    return Scaffold(
      body: appAsync.when(
        data: (app) => _buildContent(context, app, theme, isDark),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, __) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text('Hata: $err')),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppEntity app,
    ThemeData theme,
    bool isDark,
  ) {
    final fileSizeMb = (app.fileSize / 1048576).toStringAsFixed(1);

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          pinned: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 16,
              ),
            ),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.share_rounded, size: 18),
              ),
              onPressed: () {
                final shareUrl = '$_shareBaseUrl/app/${app.appId}';
                SharePlus.instance.share(
                  ShareParams(
                    title: '${app.name} - DownApp',
                    text: '${app.name} uygulamasına göz at! $shareUrl',
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),

        // App Info
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                    image: app.iconUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(app.iconUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: app.iconUrl.isEmpty
                      ? Image.asset(
                          'assets/images/logo.png',
                          width: 40,
                          height: 40,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () =>
                            context.push('/profile/${app.developerId}'),
                        child: Text(
                          app.developerName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            app.ratingAverage.toStringAsFixed(1),
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${Formatters.formatCount(app.ratingCount)})',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.download,
                            size: 16,
                            color: theme.hintColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            Formatters.formatCount(app.downloadCount),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // İndir butonu + Favori
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final downloadState = ref.watch(downloadNotifierProvider);
                      final info = downloadState[app.appId];
                      final isDownloading =
                          info?.status == DownloadStatus.downloading;
                      final isCompleted =
                          info?.status == DownloadStatus.completed;
                      final progress = info?.progress ?? 0.0;

                      if (isCompleted && info?.filePath != null) {
                        return ElevatedButton.icon(
                          onPressed: () => ref
                              .read(downloadNotifierProvider.notifier)
                              .openApk(info!.filePath!),
                          icon: const Icon(Icons.install_mobile, size: 20),
                          label: const Text('Yükle'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: AppColors.accentGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }

                      return ElevatedButton.icon(
                        onPressed: isDownloading
                            ? null
                            : () => _startDownload(context, ref, app),
                        icon: isDownloading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                  value: progress > 0 ? progress : null,
                                ),
                              )
                            : const Icon(Icons.download_rounded, size: 20),
                        label: Text(
                          isDownloading
                              ? 'İndiriliyor %${(progress * 100).toInt()}'
                              : 'İndir ($fileSizeMb MB)',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Favori butonu — Gerçek veri
                Consumer(
                  builder: (context, ref, child) {
                    final isFavAsync = ref.watch(isFavoritedProvider(widget.appId));
                    final isFav = isFavAsync.value ?? false;

                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isFav ? Colors.red : AppColors.primary,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : AppColors.primary,
                        ),
                        onPressed: () => _toggleFavorite(ref, app, isFav),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // İstatistikler
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _StatItem(
                  label: 'Puan',
                  value: app.ratingAverage.toStringAsFixed(1),
                  icon: Icons.star_rounded,
                ),
                _StatItem(
                  label: 'İndirme',
                  value: Formatters.formatCount(app.downloadCount),
                  icon: Icons.download_rounded,
                ),
                _StatItem(
                  label: 'Boyut',
                  value: '$fileSizeMb MB',
                  icon: Icons.storage_rounded,
                ),
                _StatItem(
                  label: 'Versiyon',
                  value: 'v${app.currentVersion}',
                  icon: Icons.update_rounded,
                ),
              ],
            ),
          ),
        ),

        // Screenshot'lar
        if (app.screenshots.isNotEmpty)
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Ekran Görüntüleri',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 240,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: app.screenshots.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            app.screenshots[index],
                            fit: BoxFit.cover,
                            width: 135,
                            errorBuilder: (_, __, ___) => Container(
                              width: 135,
                              color: AppColors.primary.withValues(alpha: 0.1),
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

        // Açıklama — Her zaman göster (tab dışında)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Açıklama',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  app.description.isEmpty
                      ? 'Açıklama belirtilmemiş.'
                      : app.description,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
                if (app.changelog.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Değişiklik Günlüğü',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    app.changelog,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Yorumlar bölümü
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'Yorumlar',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(
            height: 500,
            child: _ReviewsTab(appId: widget.appId),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Future<void> _toggleFavorite(WidgetRef ref, AppEntity app, bool isFav) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Favorilere eklemek için giriş yapmalısınız.')),
      );
      return;
    }

    final pb = ref.read(pocketBaseProvider);
    try {
      if (isFav) {
        // Favoriyi kaldır
        final result = await pb.collection('favorites').getList(
          filter: 'user = "${user.uid}" && app = "${app.appId}"',
          perPage: 1,
        );
        if (result.items.isNotEmpty) {
          await pb.collection('favorites').delete(result.items.first.id);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Favorilerden kaldırıldı.'), backgroundColor: Colors.grey),
          );
        }
      } else {
        // Favoriye ekle
        await pb.collection('favorites').create(body: {
          'user': user.uid,
          'app': app.appId,
          'appName': app.name,
          'appIcon': app.iconUrl,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Favorilere eklendi! ❤️'), backgroundColor: AppColors.accentGreen),
          );
        }
      }
      // Favori durumunu yenile
      ref.invalidate(isFavoritedProvider(app.appId));
      ref.invalidate(userFavoritesProvider);
      ref.invalidate(userFavoritesByIdProvider(user.uid));
    } catch (e) {
      if (mounted) {
        final errorStr = e.toString();
        String msg;
        if (errorStr.contains('404') || errorStr.contains('not found')) {
          msg = 'Lütfen PocketBase\'de "favorites" collection\'ı oluşturun: user (relation→users), app (relation→apps), appName (text), appIcon (text)';
        } else {
          msg = 'Favori işlemi başarısız. Lütfen tekrar deneyin.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), duration: const Duration(seconds: 5)),
        );
      }
    }
  }

  void _startDownload(BuildContext context, WidgetRef ref, AppEntity app) {
    if (app.apkUrl.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('APK dosyası bulunamadı.')));
      return;
    }

    final scaffold = ScaffoldMessenger.of(context);

    ref
        .read(downloadNotifierProvider.notifier)
        .startDownload(
          appId: app.appId,
          appName: app.name,
          apkUrl: app.apkUrl,
          onProgressUpdate: (status, {path}) {
            scaffold.showSnackBar(
              SnackBar(
                content: Text(status),
                duration: path != null
                    ? const Duration(seconds: 10)
                    : const Duration(seconds: 3),
                action: path != null
                    ? SnackBarAction(
                        label: 'YÜKLE',
                        textColor: AppColors.accentGreen,
                        onPressed: () => ref
                            .read(downloadNotifierProvider.notifier)
                            .openApk(path),
                      )
                    : null,
              ),
            );
          },
        );
  }
}

/// Yorumlar sekmesi — PocketBase'den gerçek veri çeker
class _ReviewsTab extends ConsumerStatefulWidget {
  final String appId;
  const _ReviewsTab({required this.appId});

  @override
  ConsumerState<_ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends ConsumerState<_ReviewsTab> {
  final _commentController = TextEditingController();
  double _userRating = 5.0;
  bool _isSending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yorum yapmak için giriş yapmalısınız.')),
      );
      return;
    }
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen bir yorum yazın.')));
      return;
    }

    setState(() => _isSending = true);

    try {
      final pb = ref.read(pocketBaseProvider);
      
      // Önce bu kullanıcının bu uygulama için yorumu var mı bak
      final existingReviews = await pb.collection('reviews').getList(
        filter: 'user = "${user.uid}" && app = "${widget.appId}"',
        perPage: 1,
      );

      final reviewData = {
        'app': widget.appId,
        'user': user.uid,
        'userName': user.displayName.isNotEmpty ? user.displayName : user.username,
        'rating': _userRating,
        'comment': _commentController.text.trim(),
      };

      if (existingReviews.items.isNotEmpty) {
        // Güncelle
        await pb.collection('reviews').update(
          existingReviews.items.first.id,
          body: reviewData,
        );
      } else {
        // Yeni oluştur
        await pb.collection('reviews').create(body: reviewData);
      }

      // Puan ortalamasını hesapla ve uygulamayı güncelle
      try {
        final reviewsResult = await pb.collection('reviews').getList(
          filter: 'app = "${widget.appId}"',
          perPage: 500, // En fazla 500 yorumu baz alalım
        );
        
        double totalRating = 0.0;
        int count = reviewsResult.items.length;
        
        for (var item in reviewsResult.items) {
          totalRating += item.getDoubleValue('rating');
        }
        
        double newAverage = count > 0 ? (totalRating / count) : 0.0;
        
        // Sadece 1 ondalık basamak tut (örn: 4.5)
        newAverage = double.parse(newAverage.toStringAsFixed(1));

        await pb.collection('apps').update(widget.appId, body: {
          'ratingAverage': newAverage,
          'ratingCount': count,
        });
      } catch (_) {
        // Arka plan güncelleme hatası sessizce geçilebilir
      }

      _commentController.clear();
      // Yorumları yenile
      ref.invalidate(appReviewsProvider(widget.appId));
      // Kullanıcının kendi yorum listesini de yenile (profili için)
      ref.invalidate(userReviewsProvider(user.uid));
      // Uygulama detayını da yenile (puan güncellenmiş olabilir)
      ref.invalidate(appDetailProvider(widget.appId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yorumunuz gönderildi! ✅'),
            backgroundColor: AppColors.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Yorum gönderilemedi: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reviewsAsync = ref.watch(appReviewsProvider(widget.appId));

    return Column(
      children: [
        // Yorum yazma alanı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: theme.dividerColor)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Yorum Yaz',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              // Yıldız seçimi
              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => setState(() => _userRating = index + 1.0),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        index < _userRating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 28,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Bu uygulama hakkında ne düşünüyorsunuz?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        isDense: true,
                      ),
                      maxLines: 2,
                      minLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isSending
                      ? const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          onPressed: _submitReview,
                          icon: const Icon(
                            Icons.send_rounded,
                            color: AppColors.primary,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
        // Yorum listesi
        Expanded(
          child: reviewsAsync.when(
            data: (reviews) {
              if (reviews.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 48,
                        color: theme.hintColor,
                      ),
                      const SizedBox(height: 16),
                      const Text('İlk yorumu sen yap! 🎉'),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: review.userAvatar.isNotEmpty
                                  ? NetworkImage(review.userAvatar)
                                  : null,
                              child: review.userAvatar.isEmpty
                                  ? Text(
                                      review.userName.isNotEmpty
                                          ? review.userName[0].toUpperCase()
                                          : '?',
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review.userName,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (i) => Icon(
                                        i < review.rating
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        color: Colors.amber,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${review.createdAt.day}.${review.createdAt.month}.${review.createdAt.year}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(review.comment, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) =>
                Center(child: Text('Yorumlar yüklenemedi: $err')),
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Kullanıcının favori uygulamaları provider
final userFavoritesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.read(currentUserProvider);
  if (user == null) return [];
  final pb = ref.read(pocketBaseProvider);
  try {
    final result = await pb.collection('favorites').getList(
      filter: 'user = "${user.uid}"',
      sort: '-created',
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
        final collectionName = appRecord.collectionName.isNotEmpty ? appRecord.collectionName : 'apps';
        final baseUrl = 'http://YOUR_POCKETBASE_SERVER_IP/api/files/$collectionName/${appRecord.id}';
        final icon = appRecord.getStringValue('icon');
        if (icon.isNotEmpty) appIcon = '$baseUrl/$icon';
      } catch (_) {}

      return {
        'id': record.id,
        'appId': appId,
        'appName': appName,
        'appIcon': appIcon,
      };
    }).toList();
  } catch (_) {
    return [];
  }
});
