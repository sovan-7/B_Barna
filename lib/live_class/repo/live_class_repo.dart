import 'package:bbarna/live_class/model/live_class_model.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LiveClassRepo {
  final FirebaseFirestore _fireStore;

  LiveClassRepo({FirebaseFirestore? firestore})
      : _fireStore = firestore ?? FirebaseFirestore.instance;

  /// Adds the doc with server-stamped `createdAt`/`updatedAt` so ordering
  /// can't be skewed by a wrong clock on the admin's machine.
  Future<DocumentReference<Map<String, dynamic>>> addLiveClass(
      LiveClassModel liveClassModel) async {
    return await _fireStore.collection(liveClasses).add({
      ...liveClassModel.toMap(),
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  /// Leaves `createdAt` untouched — only `updatedAt` is re-stamped.
  Future<void> updateLiveClass(LiveClassModel liveClassModel) async {
    await _fireStore.collection(liveClasses).doc(liveClassModel.docId).update({
      ...liveClassModel.toMap(),
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteLiveClass(String docId) async {
    await _fireStore.collection(liveClasses).doc(docId).delete();
  }

  /// Newest-scheduled first. The whole collection is fetched in one go (no
  /// paging) — same shape as the Teacher module, and appropriate while a
  /// class list stays in the tens/low hundreds.
  Future<List<LiveClassModel>> getLiveClassList() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(liveClasses)
        .orderBy("startDateTime", descending: true)
        .get();
    return snapshot.docs
        .map((docSnapshot) => LiveClassModel.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  /// Names for the Teacher dropdown on the add/edit form, read straight from
  /// the `teacher` collection (same cross-collection read VideoRepo does for
  /// subjects). Sorted case-insensitively; blanks dropped.
  Future<List<String>> getTeacherNames() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _fireStore.collection(teacher).get();
    final List<String> names = snapshot.docs
        .map((doc) => (doc.data()["name"] ?? "").toString().trim())
        .where((name) => name.isNotEmpty && name != stringDefault)
        .toSet()
        .toList();
    names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return names;
  }
}
