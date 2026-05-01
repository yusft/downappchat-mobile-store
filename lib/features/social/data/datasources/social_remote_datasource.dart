import 'package:pocketbase/pocketbase.dart';
import 'package:downapp/features/social/data/models/activity_model.dart';
import 'package:downapp/core/errors/exceptions.dart';

abstract class SocialRemoteDataSource {
  Future<List<ActivityModel>> getActivities();
}

class SocialRemoteDataSourceImpl implements SocialRemoteDataSource {
  final PocketBase _pb;

  SocialRemoteDataSourceImpl(this._pb);

  @override
  Future<List<ActivityModel>> getActivities() async {
    try {
      final result = await _pb.collection('activities').getList(
        sort: '-created',
        expand: 'userId',
      );
      return result.items.map((e) => ActivityModel.fromPocketBase(e)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
