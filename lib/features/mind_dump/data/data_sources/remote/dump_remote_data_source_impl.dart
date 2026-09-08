import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/dump_entry_model.dart';
import 'dump_remote_data_source.dart';

/// Unsorted entries live at `users/{uid}/inbox/{entryId}`, mirroring how tasks
/// are stored, so a dump survives a refresh and syncs across devices before
/// anything has been triaged into a quadrant.
class DumpRemoteDataSourceImpl implements DumpRemoteDataSource {
  DumpRemoteDataSourceImpl(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _inboxCollection {
    final uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).collection('inbox');
  }

  @override
  Stream<List<DumpEntryModel>> watchEntries() {
    return _inboxCollection.snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => DumpEntryModel.fromJson(doc.data())).toList(),
        );
  }

  @override
  Future<void> addEntry(DumpEntryModel entry) =>
      _inboxCollection.doc(entry.id).set(entry.toJson());

  /// Deleted in one batch so a multi-item save clears the dump atomically
  /// rather than leaving it half-emptied if a write fails partway through.
  @override
  Future<void> deleteEntries(List<String> ids) {
    if (ids.isEmpty) return Future.value();
    final batch = _firestore.batch();
    for (final id in ids) {
      batch.delete(_inboxCollection.doc(id));
    }
    return batch.commit();
  }
}
