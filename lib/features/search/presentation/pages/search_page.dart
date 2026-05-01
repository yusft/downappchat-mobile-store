import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:downapp/app/theme/app_colors.dart';
import 'package:downapp/features/marketplace/presentation/providers/marketplace_provider.dart';
import 'package:downapp/core/widgets/app_logo.dart';

/// Arama sayfası — Marketplace provider ile entegre
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';

  final List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: (v) => setState(() => _query = v.trim()),
          decoration: InputDecoration(
            hintText: 'Uygulama ara...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
            hintStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
          ),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: _query.isNotEmpty ? _buildResults(theme, isDark) : _buildSuggestions(theme, isDark),
    );
  }

  Widget _buildSuggestions(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Son Aramalar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Son Aramalar', style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              )),
              TextButton(onPressed: () {}, child: const Text('Temizle')),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((search) => ActionChip(
              label: Text(search),
              avatar: Icon(Icons.history, size: 16, color: theme.textTheme.bodySmall?.color),
              onPressed: () {
                _searchController.text = search;
                setState(() => _query = search);
              },
            )).toList(),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 24),

          // Trend Aramalar
          Text('Trend Uygulamalar', style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          )),
          const SizedBox(height: 12),
          Consumer(
            builder: (context, ref, child) {
              final trendingAsync = ref.watch(trendingAppsProvider);
              return trendingAsync.when(
                data: (apps) => Column(
                  children: List.generate(apps.length, (index) {
                    final app = apps[index];
                    return ListTile(
                      leading: Text('#${index + 1}', style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: index < 3 ? AppColors.primary : theme.textTheme.bodySmall?.color,
                      )),
                      title: Text(app.name),
                      onTap: () => context.push('/app/${app.appId}'),
                      contentPadding: EdgeInsets.zero,
                    );
                  }),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResults(ThemeData theme, bool isDark) {
    final resultsAsync = ref.watch(searchResultsProvider(_query));

    return resultsAsync.when(
      data: (apps) {
        if (apps.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off_rounded, size: 64, color: theme.dividerColor),
                const SizedBox(height: 16),
                Text('Sonuç Bulunamadı', style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor)),
                const SizedBox(height: 8),
                Text('Farklı bir anahtar kelime denemeyi unutma.', style: theme.textTheme.bodySmall),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: apps.length,
          itemBuilder: (context, index) {
            final app = apps[index];
            final color = AppColors.getCategoryColor(index);
            return ListTile(
              leading: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const AppLogo(size: 26),
              ),
              title: Text(app.name),
              subtitle: Text('${app.developerName} • ★ ${app.ratingAverage.toStringAsFixed(1)}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('İndir', style: TextStyle(
                  color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600,
                )),
              ),
              onTap: () => context.push('/app/${app.appId}'),
              contentPadding: EdgeInsets.zero,
            ).animate().fadeIn(duration: 200.ms, delay: Duration(milliseconds: 50 * index));
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, __) => Center(child: Text('Hata: $err')),
    );
  }

}

