import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:downapp/core/utils/url_utils.dart';
import 'package:downapp/app/theme/app_colors.dart';
import 'package:downapp/features/stories/presentation/providers/story_provider.dart';
import 'package:downapp/features/auth/presentation/providers/auth_provider.dart';

class StoryViewPage extends ConsumerStatefulWidget {
  final String userId;
  const StoryViewPage({super.key, required this.userId});

  @override
  ConsumerState<StoryViewPage> createState() => _StoryViewPageState();
}

class _StoryViewPageState extends ConsumerState<StoryViewPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _startProgress(int storyCount) {
    _progressController.reset();
    _progressController.forward();
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_currentIndex < storyCount - 1) {
          setState(() => _currentIndex++);
          _progressController.reset();
          _progressController.forward();
        } else {
          if (mounted) context.pop();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final storiesAsync = ref.watch(activeStoriesProvider(widget.userId));

    return Scaffold(
      backgroundColor: Colors.black,
      body: storiesAsync.when(
        data: (allStories) {
          // Bu kullanıcının hikayelerini filtrele
          final stories = allStories.where((s) => s.userId == widget.userId).toList();
          if (stories.isEmpty) {
            // Kullanıcıya ait story yoksa tümünü göster
            if (allStories.isEmpty) {
              return const Center(
                child: Text('Hikaye bulunamadı.', style: TextStyle(color: Colors.white)),
              );
            }
            // Hepsini kullan
            return _buildStoryContent(context, allStories);
          }
          return _buildStoryContent(context, stories);
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (_, __) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Hikaye yüklenemedi.', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Geri Dön', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryContent(BuildContext context, List stories) {
    if (!_progressController.isAnimating && _currentIndex < stories.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _startProgress(stories.length);
      });
    }

    // Geçerli story'yi güvenli al
    final safeIndex = _currentIndex.clamp(0, stories.length - 1);
    final story = stories[safeIndex];
    
    // Görüntülendi olarak işaretle
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      ref.read(storyNotifierProvider.notifier).markViewed(
        storyId: story.storyId,
        viewerUserId: currentUser.uid,
      );
    }

    // Medya URL'sini oluştur
    String mediaUrl = story.mediaUrl;
    if (mediaUrl.isNotEmpty && !mediaUrl.startsWith('http')) {
      // PocketBase dosya URL yapısı
      // UrlUtils kullan
      mediaUrl = UrlUtils.getStoryMediaUrl(story.storyId, mediaUrl);
    }

    // Ne kadar zaman önce
    final timeDiff = DateTime.now().difference(story.createdAt);
    String timeAgo;
    if (timeDiff.inMinutes < 60) {
      timeAgo = '${timeDiff.inMinutes}dk';
    } else {
      timeAgo = '${timeDiff.inHours}sa';
    }

    return GestureDetector(
      onTapDown: (details) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        if (details.globalPosition.dx < screenWidth / 3) {
          // Önceki
          if (_currentIndex > 0) {
            setState(() => _currentIndex--);
            _progressController.reset();
            _progressController.forward();
          }
        } else {
          // Sonraki
          if (_currentIndex < stories.length - 1) {
            setState(() => _currentIndex++);
            _progressController.reset();
            _progressController.forward();
          } else {
            context.pop();
          }
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Story içeriği — Gerçek medya
          if (mediaUrl.isNotEmpty)
            Image.network(
              mediaUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accentPurple.withValues(alpha: 0.5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.broken_image, size: 48, color: Colors.white54),
                      if (story.caption.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            story.caption,
                            style: const TextStyle(color: Colors.white, fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary.withValues(alpha: 0.6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    story.caption.isNotEmpty ? story.caption : 'Hikaye',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

          // Alttaki gradient overlay (caption için)
          if (story.caption.isNotEmpty && mediaUrl.isNotEmpty)
            Positioned(
              bottom: 0, left: 0, right: 0,
              height: 160,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

          // Caption metni
          if (story.caption.isNotEmpty && mediaUrl.isNotEmpty)
            Positioned(
              bottom: 60, left: 16, right: 16,
              child: Text(
                story.caption,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),

          // Progress göstergeleri
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 8,
            right: 8,
            child: Row(
              children: List.generate(stories.length, (index) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 3,
                    child: index == safeIndex
                        ? AnimatedBuilder(
                            animation: _progressController,
                            builder: (_, __) => LinearProgressIndicator(
                              value: _progressController.value,
                              backgroundColor: Colors.white30,
                              color: Colors.white,
                              minHeight: 3,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: index < safeIndex ? Colors.white : Colors.white30,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                  ),
                );
              }),
            ),
          ),

          // Kullanıcı bilgisi
          Positioned(
            top: MediaQuery.paddingOf(context).top + 20,
            left: 16,
            right: 16,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  backgroundImage: story.userAvatar.isNotEmpty
                      ? NetworkImage(story.userAvatar)
                      : null,
                  child: story.userAvatar.isEmpty
                      ? Text(
                          story.userName.isNotEmpty ? story.userName[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Text(
                  story.userName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Text(timeAgo, style: const TextStyle(color: Colors.white60, fontSize: 13)),
                const Spacer(),
                if (story.viewCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.visibility, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text('${story.viewCount}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
