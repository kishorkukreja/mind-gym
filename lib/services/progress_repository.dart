import '../models/user_progress_snapshot.dart';

abstract class ProgressRepository {
  Future<void> saveProgress(UserProgressSnapshot snapshot);
  Future<UserProgressSnapshot?> loadProgress(String userId);
}
