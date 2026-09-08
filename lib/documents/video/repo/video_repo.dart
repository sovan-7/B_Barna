import 'package:bbarna/documents/video/model/video_model.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoRepo {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  /// Returns the new document's id — no caller wants the reference itself,
  /// and being a sealed Firestore type it cannot be faked in a test.
  Future<String> addVideo(VideoModel videoModel) async {
    final DocumentReference<Map<String, dynamic>> doc =
        await _fireStore.collection(video).add(videoModel.toMap());
    return doc.id;
  }

  /// The paging cursor lives here rather than in the view model.
  ///
  /// It is a Firestore [DocumentSnapshot] — a sealed type — so a view model
  /// that held it could not be exercised without real Firebase.
  DocumentSnapshot<Map<String, dynamic>>? _cursor;

  /// First page, newest first. Resets the cursor.
  Future<List<VideoModel>> getFirstVideoList(int limit) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(video)
        .orderBy("timeStamp", descending: true)
        .limit(limit)
        .get();
    _cursor = snapshot.docs.isEmpty ? null : snapshot.docs.last;
    return snapshot.docs
        .map((doc) => VideoModel.fromDocumentSnapshot(doc))
        .toList();
  }

  /// The page after the last one returned. Empty when there is no cursor
  /// yet or nothing further to read.
  Future<List<VideoModel>> getNextVideoList(int limit) async {
    final DocumentSnapshot<Map<String, dynamic>>? cursor = _cursor;
    if (cursor == null) return const [];

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(video)
        .orderBy("timeStamp", descending: true)
        .startAfterDocument(cursor)
        .limit(limit)
        .get();
    if (snapshot.docs.isNotEmpty) _cursor = snapshot.docs.last;
    return snapshot.docs
        .map((doc) => VideoModel.fromDocumentSnapshot(doc))
        .toList();
  }

  Future<void> updateVideo(VideoModel videoModel, String docId) async {
    await _fireStore.collection(video).doc(docId).update(videoModel.toMap());
  }

  Future<void> deleteVideo(String docId) async {
    await _fireStore.collection(video).doc(docId).delete();
  }

  Future<int> getVideoListLength() async {
    AggregateQuerySnapshot countSnapshot =
        await _fireStore.collection(video).count().get();
    return countSnapshot.count ?? 0;
  }

  /// Prefix match on `video_code`, server-side — the collection is paged
  /// precisely because it is too big to filter in memory.
  Future<List<VideoModel>> searchVideo(String searchText) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(video)
        .where("video_code", isGreaterThanOrEqualTo: searchText)
        .where("video_code", isLessThan: '${searchText}z')
        .get();
    return snapshot.docs
        .map((docSnapshot) => VideoModel.fromDocumentSnapshot(docSnapshot))
        .toList();
  }
}
