import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:downapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:downapp/app/di/providers.dart';
import 'package:downapp/features/auth/domain/entities/user_entity.dart';
import 'package:downapp/features/profile/domain/repositories/profile_repository.dart';
import 'package:downapp/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:downapp/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:downapp/features/profile/domain/usecases/get_profile.dart';
import 'package:downapp/features/profile/domain/usecases/update_profile.dart';
import 'package:downapp/features/profile/domain/usecases/send_follow_request.dart';
import 'package:downapp/features/profile/domain/usecases/unfollow_user.dart';
import 'package:downapp/features/profile/domain/usecases/respond_to_follow_request.dart';

// ── Data & Repository Providers ───────────────────

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSourceImpl(
    ref.watch(pocketBaseProvider),
  );
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    ref.watch(profileRemoteDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});

// ── Use Case Providers ───────────────────────────

final getProfileProvider = Provider((ref) => GetProfile(ref.watch(profileRepositoryProvider)));
final updateProfileProvider = Provider((ref) => UpdateProfile(ref.watch(profileRepositoryProvider)));
final sendFollowRequestProvider = Provider((ref) => SendFollowRequest(ref.watch(profileRepositoryProvider)));
final unfollowUserProvider = Provider((ref) => UnfollowUser(ref.watch(profileRepositoryProvider)));
final respondToFollowRequestProvider = Provider((ref) => RespondToFollowRequest(ref.watch(profileRepositoryProvider)));

// ── UI Providers ────────────────────────────────

/// Belirli bir kullanıcının profilini getiren provider
final profileUserProvider = FutureProvider.family<UserEntity, String>((ref, userId) async {
  final getProfile = ref.watch(getProfileProvider);
  final result = await getProfile(userId);
    return result.fold(
    (failure) => throw Exception(failure.message),
    (user) => user,
  );
});

/// Kullanıcıyı takip edip etmediğimizi kontrol eden provider
final isFollowingProvider = FutureProvider.family<bool, String>((ref, targetUserId) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return false;
  if (currentUser.uid == targetUserId) return false;
  
  final pb = ref.watch(pocketBaseProvider);
  try {
    // İki yönden biri kabul edildiyse arkadaş sayılırlar (Mutual friendship)
    final result = await pb.collection('follows').getList(
      filter: '(user = "${currentUser.uid}" && target = "$targetUserId" && status = "accepted") || (user = "$targetUserId" && target = "${currentUser.uid}" && status = "accepted")',
      perPage: 1,
    );
    return result.items.isNotEmpty;
      } catch (e) {
        // debugPrint(e.toString());
        return false;
      }
});

/// Arkadaşlık isteği durumunu (pending) kontrol eden provider
final followRequestStatusProvider = FutureProvider.family<String?, String>((ref, targetUserId) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return null;
  
  final pb = ref.watch(pocketBaseProvider);
  try {
    final result = await pb.collection('follows').getList(
      filter: 'user = "${currentUser.uid}" && target = "$targetUserId"',
      perPage: 1,
    );
    if (result.items.isEmpty) return null;
    return result.items.first.getStringValue('status'); // 'pending' or 'accepted'
  } catch (_) {
    return null;
  }
});

/// Profil durumunu (yükleme, hata vb.) yöneten notifier (Opsiyonel, işlemler için kullanılır)
class ProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final SendFollowRequest _sendFollowRequest;
  final UnfollowUser _unfollowUser;
  final RespondToFollowRequest _respondToFollowRequest;
  final UpdateProfile _updateProfile;
  final Ref ref;

  ProfileNotifier({
    required SendFollowRequest sendFollowRequest,
    required UnfollowUser unfollowUser,
    required RespondToFollowRequest respondToFollowRequest,
    required UpdateProfile updateProfile,
    required this.ref,
  })  : _sendFollowRequest = sendFollowRequest,
        _unfollowUser = unfollowUser,
        _respondToFollowRequest = respondToFollowRequest,
        _updateProfile = updateProfile,
        super(const AsyncValue.data(null));

  Future<void> followUser({
    required String currentUserId,
    required String targetUserId,
    required bool isUnfollow,
  }) async {
    state = const AsyncValue.loading();
    final result = isUnfollow
        ? await _unfollowUser(currentUserId: currentUserId, targetUserId: targetUserId)
        : await _sendFollowRequest(currentUserId: currentUserId, targetUserId: targetUserId);
    
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (_) {
        // İlgili provider'ları yenile
        ref.invalidate(isFollowingProvider(targetUserId));
        ref.invalidate(followRequestStatusProvider(targetUserId));
        ref.invalidate(profileUserProvider(targetUserId));
        return const AsyncValue.data(null);
      },
    );
  }

  Future<void> respondToFollowRequest({
    required String followId,
    required String currentUserId,
    required String targetUserId,
    required bool accept,
  }) async {
    state = const AsyncValue.loading();
    final result = await _respondToFollowRequest(
      followId: followId,
      currentUserId: currentUserId,
      targetUserId: targetUserId,
      accept: accept,
    );
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (_) {
        // İlgili provider'ları yenile
        ref.invalidate(isFollowingProvider(targetUserId));
        ref.invalidate(followRequestStatusProvider(targetUserId));
        ref.invalidate(profileUserProvider(targetUserId));
        return const AsyncValue.data(null);
      },
    );
  }

  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? bio,
    String? website,
  }) async {
    state = const AsyncValue.loading();
    final result = await _updateProfile(
      userId: userId,
      displayName: displayName,
      bio: bio,
      website: website,
    );
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }

  Future<void> updateUserSettings({
    required String userId,
    bool? isPrivate,
    bool? showLastSeen,
    String? allowMessages,
    NotificationSettingsEntity? notificationSettings,
    UserPreferencesEntity? preferences,
  }) async {
    state = const AsyncValue.loading();
    final result = await _updateProfile(
      userId: userId,
      isPrivate: isPrivate,
      showLastSeen: showLastSeen,
      allowMessages: allowMessages,
      notificationSettings: notificationSettings,
      preferences: preferences,
    );
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }

  Future<String?> uploadAvatar({required String userId, required File file}) async {
    state = const AsyncValue.loading();
    final repo = _updateProfile.repository; // UpdateProfile has access to repository
    final result = await repo.uploadAvatar(userId: userId, file: file);
    
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return null;
      },
      (url) {
        state = const AsyncValue.data(null);
        // Refresh profile data to show the new avatar
        ref.invalidate(profileUserProvider(userId));
        return url;
      },
    );
  }

  Future<String?> uploadCover({required String userId, required File file}) async {
    state = const AsyncValue.loading();
    final repo = _updateProfile.repository;
    final result = await repo.uploadCover(userId: userId, file: file);
    
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return null;
      },
      (url) {
        state = const AsyncValue.data(null);
        // Refresh profile data to show the new cover
        ref.invalidate(profileUserProvider(userId));
        return url;
      },
    );
  }
}


final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<void>>((ref) {
  return ProfileNotifier(
    sendFollowRequest: ref.watch(sendFollowRequestProvider),
    unfollowUser: ref.watch(unfollowUserProvider),
    respondToFollowRequest: ref.watch(respondToFollowRequestProvider),
    updateProfile: ref.watch(updateProfileProvider),
    ref: ref,
  );
});
