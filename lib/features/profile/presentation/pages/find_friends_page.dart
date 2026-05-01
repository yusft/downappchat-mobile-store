import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:downapp/app/theme/app_colors.dart';
import 'package:downapp/core/widgets/app_avatar.dart';
import 'package:downapp/app/di/providers.dart';
import 'package:downapp/core/utils/url_utils.dart';

final usersSearchProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, query) async {
  final pb = ref.read(pocketBaseProvider);
  final result = await pb.collection('users').getList(
    page: 1,
    perPage: 50,
    filter: query.isNotEmpty ? 'username ~ "$query" || displayName ~ "$query"' : '',
    sort: '-created',
  );
  
  return result.items.map((record) {
    return {
      'id': record.id,
      'username': record.getStringValue('username'),
      'displayName': record.getStringValue('displayName'),
      'avatarUrl': UrlUtils.getUserAvatarUrl(record.id, record.getStringValue('avatar')),
      'developerStatus': record.getStringValue('developerStatus'),
      'isDeveloper': record.getBoolValue('isDeveloper'),
    };
  }).toList();
});

class FindFriendsPage extends ConsumerStatefulWidget {
  const FindFriendsPage({super.key});

  @override
  ConsumerState<FindFriendsPage> createState() => _FindFriendsPageState();
}

class _FindFriendsPageState extends ConsumerState<FindFriendsPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final usersAsync = ref.watch(usersSearchProvider(_searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kişi Bul'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Kullanıcı adı veya isim ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
            ),
          ),
          Expanded(
            child: usersAsync.when(
              data: (users) {
                if (users.isEmpty) {
                  return Center(
                    child: Text('Kullanıcı bulunamadı.', style: theme.textTheme.bodyMedium),
                  );
                }
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isAdmin = user['developerStatus'] == 'admin';
                    
                    return ListTile(
                      leading: AppAvatar(
                        imageUrl: user['avatarUrl'],
                        size: 48,
                      ),
                      title: Row(
                        children: [
                          Text(user['displayName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (isAdmin) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, size: 16, color: AppColors.accentOrange),
                          ] else if (user['isDeveloper']) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.code, size: 16, color: AppColors.primary),
                          ]
                        ],
                      ),
                      subtitle: Text('@${user['username']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                           context.push('/profile/${user['id']}');
                        },
                      ),
                      onTap: () {
                         context.push('/profile/${user['id']}');
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Bir hata oluştu: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
