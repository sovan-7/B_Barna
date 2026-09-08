import 'package:bbarna/question/model/question.dart';
import 'package:bbarna/quiz/model/quiz_model.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizRepo {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  /// Returns the new document's id — no caller wants the reference itself,
  /// and being a sealed Firestore type it cannot be faked in a test.
  Future<String> addQuiz(QuizModel quizModel) async {
    final DocumentReference<Map<String, dynamic>> doc =
        await _fireStore.collection(quiz).add(quizModel.toMap());
    return doc.id;
  }

  /// The paging cursor lives here rather than in the view model.
  ///
  /// It is a Firestore [DocumentSnapshot] — a sealed type — so a view model
  /// that held it could not be exercised without real Firebase.
  DocumentSnapshot<Map<String, dynamic>>? _cursor;

  /// First page, newest first. Resets the cursor.
  Future<List<QuizModel>> getFirstQuizList(int limit) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(quiz)
        .orderBy("timeStamp", descending: true)
        .limit(limit)
        .get();
    _cursor = snapshot.docs.isEmpty ? null : snapshot.docs.last;
    return snapshot.docs
        .map((doc) => QuizModel.fromDocumentSnapshot(doc))
        .toList();
  }

  /// The page after the last one returned. Empty when there is no cursor
  /// yet or nothing further to read.
  Future<List<QuizModel>> getNextQuizList(int limit) async {
    final DocumentSnapshot<Map<String, dynamic>>? cursor = _cursor;
    if (cursor == null) return const [];

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(quiz)
        .orderBy("timeStamp", descending: true)
        .startAfterDocument(cursor)
        .limit(limit)
        .get();
    if (snapshot.docs.isNotEmpty) _cursor = snapshot.docs.last;
    return snapshot.docs
        .map((doc) => QuizModel.fromDocumentSnapshot(doc))
        .toList();
  }

  Future<void> updateQuiz(QuizModel quizModel, String docId) async {
    await _fireStore.collection(quiz).doc(docId).update(quizModel.toMap());
  }

  Future<void> deleteQuiz(String docId) async {
    await _fireStore.collection(quiz).doc(docId).delete();
  }

  Future<int> getQuizListLength() async {
    AggregateQuerySnapshot countSnapshot =
        await _fireStore.collection(quiz).count().get();
    return countSnapshot.count ?? 0;
  }

  /// Prefix match on `quiz_code`, server-side — the collection is paged
  /// precisely because it is too big to filter in memory.
  Future<List<QuizModel>> searchQuiz(String searchText) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(quiz)
        .where("quiz_code", isGreaterThanOrEqualTo: searchText)
        .where("quiz_code", isLessThan: '${searchText}z')
        .get();
    return snapshot.docs
        .map((docSnapshot) => QuizModel.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  /// Questions whose code starts with [questionCode].
  ///
  /// This and [getQuestionsByCodes] were inline `FirebaseFirestore.instance`
  /// queries in the view model; they belong here with the rest of the data
  /// access.
  Future<List<Question>> searchQuestions(String questionCode) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(question)
        .where("question_code", isGreaterThanOrEqualTo: questionCode)
        .where("question_code", isLessThan: '${questionCode}z')
        .get();
    return snapshot.docs
        .map((doc) => Question.fromDocumentSnapshot(doc))
        .toList();
  }

  /// The questions named by [codes], fetched in chunks — Firestore's
  /// `whereIn` takes at most 30 values.
  Future<List<Question>> getQuestionsByCodes(List<String> codes) async {
    const int chunkSize = 25;
    final List<Question> questions = [];

    for (int i = 0; i < codes.length; i += chunkSize) {
      final List<String> chunk = codes.sublist(
          i, i + chunkSize > codes.length ? codes.length : i + chunkSize);
      if (chunk.isEmpty) continue;

      final QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
          .collection(question)
          .where("question_code", whereIn: chunk)
          .get();
      questions.addAll(
          snapshot.docs.map((doc) => Question.fromDocumentSnapshot(doc)));
    }
    return questions;
  }
}
