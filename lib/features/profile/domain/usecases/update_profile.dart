import 'package:dartz/dartz.dart';
import 'package:downapp/core/errors/failures.dart';
import 'package:downapp/features/auth/domain/entities/user_entity.dart';
import 'package:downapp/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfile {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String userId,
    String? displayName,
    String? bio,
    String? website,
    Map<String, String>? socialLinks,
    bool? isPrivate,
    bool? showLastSeen,
    String? allowMessages,
    NotificationSettingsEntity? notificationSettings,
    UserPreferencesEntity? preferences,
  }) {
    return repository.updateProfile(
      userId: userId,
      displayName: displayName,
      bio: bio,
      website: website,
      socialLinks: socialLinks,
      isPrivate: isPrivate,
      showLastSeen: showLastSeen,
      allowMessages: allowMessages,
      notificationSettings: notificationSettings,
      preferences: preferences,
    );
  }
}

