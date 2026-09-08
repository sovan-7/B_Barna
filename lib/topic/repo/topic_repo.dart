import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/subject/model/subject_model.dart';
import 'package:bbarna/topic/model/topic_model.dart';
import 'package:bbarna/units/model/unit_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TopicRepo {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  /// Returns the new document's id — no caller wants the reference itself,
  /// and being a sealed Firestore type it cannot be faked in a test.
  Future<String> addTopic(TopicModel topicModel) async {
    final DocumentReference<Map<String, dynamic>> doc =
        await _fireStore.collection(topic).add(topicModel.toMap());
    return doc.id;
  }

  /// The paging cursor lives here rather than in the view model.
  ///
  /// It is a Firestore [DocumentSnapshot] — a sealed type — so a view model
  /// that held it could not be exercised without real Firebase. Keeping it
  /// behind the repo means the pages come back as plain models.
  DocumentSnapshot<Map<String, dynamic>>? _cursor;

  /// First page, newest first. Resets the cursor.
  Future<List<TopicModel>> getFirstTopicList(int limit) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(topic)
        .orderBy("timeStamp", descending: true)
        .limit(limit)
        .get();
    _cursor = snapshot.docs.isEmpty ? null : snapshot.docs.last;
    return snapshot.docs
        .map((doc) => TopicModel.fromDocumentSnapshot(doc))
        .toList();
  }

  /// The page after the last one returned. Empty when there is no cursor
  /// yet or nothing further to read.
  Future<List<TopicModel>> getNextTopicList(int limit) async {
    final DocumentSnapshot<Map<String, dynamic>>? cursor = _cursor;
    if (cursor == null) return const [];

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(topic)
        .orderBy("timeStamp", descending: true)
        .startAfterDocument(cursor)
        .limit(limit)
        .get();
    if (snapshot.docs.isNotEmpty) _cursor = snapshot.docs.last;
    return snapshot.docs
        .map((doc) => TopicModel.fromDocumentSnapshot(doc))
        .toList();
  }

  Future<void> updateTopic(TopicModel topicModel, String docId) async {
    await _fireStore.collection(topic).doc(docId).update(topicModel.toMap());
  }

  Future<void> deleteTopic(String docId) async {
    await _fireStore.collection(topic).doc(docId).delete();
  }

  /// Replaces one content array on a topic.
  ///
  /// The details screen used to build this write itself, straight from the
  /// widget, four times over.
  Future<void> setContentCodes(
      String docId, ContentKind kind, List<String> codes) async {
    await _fireStore.collection(topic).doc(docId).update({kind.field: codes});
  }

  /// Looks the codes up in their own collection and returns
  /// `code -> title`. A code with no document simply does not come back, so
  /// the caller can tell attached-and-real from attached-and-a-typo.
  ///
  /// `whereIn` takes at most 30 values per query, so this goes in chunks.
  Future<Map<String, String>> resolveContentTitles(
      ContentKind kind, List<String> codes) async {
    final List<String> unique =
        codes.map((c) => c.trim()).where((c) => c.isNotEmpty).toSet().toList();
    if (unique.isEmpty) return <String, String>{};

    final Map<String, String> titles = <String, String>{};
    for (int i = 0; i < unique.length; i += 30) {
      final List<String> chunk =
          unique.sublist(i, i + 30 > unique.length ? unique.length : i + 30);
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
          .collection(kind.collection)
          .where(kind.codeField, whereIn: chunk)
          .get();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in snapshot.docs) {
        final Object? code = doc.data()[kind.codeField];
        final Object? title = doc.data()[kind.titleField];
        if (code is String) titles[code] = title is String ? title : "";
      }
    }
    return titles;
  }

  Future<List<SubjectModel>> getSubjectList(
      {required String courseCode}) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(subject)
        .where("course_code", isEqualTo: courseCode)
        .get();
    return snapshot.docs
        .map((docSnapshot) => SubjectModel.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  Future<List<UnitModel>> getUnitList({required String subjectCode}) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(unit)
        .where("subject_code", isEqualTo: subjectCode)
        .get();
    return snapshot.docs
        .map((docSnapshot) => UnitModel.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  Future<int> getTopicListLength() async {
    final AggregateQuerySnapshot countSnapshot =
        await _fireStore.collection(topic).count().get();
    return countSnapshot.count ?? 0;
  }

  /// Prefix match on `topic_code`, server-side — the collection is paged
  /// precisely because it is too big to filter in memory.
  Future<List<TopicModel>> searchTopic(String searchText) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(topic)
        .where("topic_code", isGreaterThanOrEqualTo: searchText)
        .where("topic_code", isLessThan: '${searchText}z')
        .get();
    return snapshot.docs
        .map((docSnapshot) => TopicModel.fromDocumentSnapshot(docSnapshot))
        .toList();
  }
}
