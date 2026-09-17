import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/task_model.dart';
import 'task_remote_data_source.dart';

/// Tasks are stored per-user at `users/{uid}/tasks/{taskId}` so Firestore's
/// realtime listeners and built-in offline cache give us cross-device sync
/// for free — no manual polling or local persistence layer needed.
class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  TaskRemoteDataSourceImpl(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _tasksCollection {
    final uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).collection('tasks');
  }

  @override
  Stream<List<TaskModel>> watchTasks() {
    return _tasksCollection.snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => TaskModel.fromJson(doc.data())).toList(),
        );
  }

  @override
  Future<void> addTask(TaskModel task) => _tasksCollection.doc(task.id).set(task.toJson());

  @override
  Future<void> updateTask(TaskModel task) => _tasksCollection.doc(task.id).set(task.toJson());

  @override
  Future<void> deleteTask(String id) => _tasksCollection.doc(id).delete();

  /// Writes every position in one batch so another device never observes a
  /// half-applied order. Uses `update` so only `sortOrder` is touched.
  @override
  Future<void> reorderTasks(List<String> orderedIds) {
    if (orderedIds.isEmpty) return Future.value();
    final batch = _firestore.batch();
    for (var i = 0; i < orderedIds.length; i++) {
      batch.update(_tasksCollection.doc(orderedIds[i]), {'sortOrder': i});
    }
    return batch.commit();
  }
}
