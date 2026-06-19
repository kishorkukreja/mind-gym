import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/user_progress_snapshot.dart';
import 'progress_repository.dart';

class FirestoreProgressRepository implements ProgressRepository {
  final FirebaseFirestore _firestore;

  FirestoreProgressRepository(this._firestore);

  static FirestoreProgressRepository? createIfAvailable() {
    try {
      if (Firebase.apps.isEmpty) return null;
      return FirestoreProgressRepository(FirebaseFirestore.instance);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> saveProgress(UserProgressSnapshot snapshot) async {
    await _progressDocument(snapshot.user.id).set(snapshot.toJson());
  }

  @override
  Future<UserProgressSnapshot?> loadProgress(String userId) async {
    final document = await _progressDocument(userId).get();
    final data = document.data();
    if (data == null) return null;
    return UserProgressSnapshot.fromJson(data);
  }

  DocumentReference<Map<String, dynamic>> _progressDocument(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc('current');
  }
}
