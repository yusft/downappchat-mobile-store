import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:downapp/features/social/data/datasources/social_remote_datasource.dart';
import 'package:downapp/features/social/data/models/activity_model.dart';
import 'package:downapp/app/di/providers.dart';

final socialRemoteDataSourceProvider = Provider<SocialRemoteDataSource>((ref) {
  return SocialRemoteDataSourceImpl(ref.watch(pocketBaseProvider));
});

final activitiesProvider = FutureProvider<List<ActivityModel>>((ref) async {
  return ref.watch(socialRemoteDataSourceProvider).getActivities();
});
