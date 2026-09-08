import 'package:bbarna/question/model/question.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Data access for questions.
///
/// The module had no repo at all — every query was written inline in the
/// view model, which is also why the view model could not be exercised
/// without real Firebase.
class QuestionRepo {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  /// The paging cursor. It is a Firestore [DocumentSnapshot] — a sealed
  /// type — so a view model that held it could not be faked in a test.
  DocumentSnapshot<Map<String, dynamic>>? _cursor;

  /// First page, newest first. Resets the cursor.
  Future<List<Question>> getFirstQuestionList(int limit) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(question)
        .orderBy("timeStamp", descending: true)
        .limit(limit)
        .get();
    _cursor = snapshot.docs.isEmpty ? null : snapshot.docs.last;
    return snapshot.docs
        .map((doc) => Question.fromDocumentSnapshot(doc))
        .toList();
  }

  /// The page after the last one returned. Empty when there is no cursor
  /// yet or nothing further to read.
  Future<List<Question>> getNextQuestionList(int limit) async {
    final DocumentSnapshot<Map<String, dynamic>>? cursor = _cursor;
    if (cursor == null) return const [];

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(question)
        .orderBy("timeStamp", descending: true)
        .startAfterDocument(cursor)
        .limit(limit)
        .get();
    if (snapshot.docs.isNotEmpty) _cursor = snapshot.docs.last;
    return snapshot.docs
        .map((doc) => Question.fromDocumentSnapshot(doc))
        .toList();
  }

  Future<String> addQuestion(Map<String, dynamic> data) async {
    final DocumentReference<Map<String, dynamic>> doc =
        await _fireStore.collection(question).add(data);
    return doc.id;
  }

  Future<void> updateQuestion(String docId, Map<String, dynamic> data) async {
    await _fireStore.collection(question).doc(docId).update(data);
  }

  Future<void> deleteQuestion(String docId) async {
    await _fireStore.collection(question).doc(docId).delete();
  }

  Future<int> getQuestionListLength() async {
    AggregateQuerySnapshot countSnapshot =
        await _fireStore.collection(question).count().get();
    return countSnapshot.count ?? 0;
  }

  /// Prefix match on `question_code`, server-side — the collection is paged
  /// precisely because it is too big to filter in memory.
  Future<List<Question>> searchQuestion(String searchText) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(question)
        .where("question_code", isGreaterThanOrEqualTo: searchText)
        .where("question_code", isLessThan: '${searchText}z')
        .get();
    return snapshot.docs
        .map((doc) => Question.fromDocumentSnapshot(doc))
        .toList();
  }
}
