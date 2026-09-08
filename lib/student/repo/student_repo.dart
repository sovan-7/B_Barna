import 'package:bbarna/course/model/course_model.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/student/model/enrolled_course_model.dart';
import 'package:bbarna/student/model/student_model.dart';
import 'package:bbarna/subject/model/subject_model.dart';
import 'package:bbarna/units/model/unit_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// The paging cursor. It is a Firestore [DocumentSnapshot] — a sealed
  /// type — so a view model that held it could not be faked in a test.
  DocumentSnapshot<Map<String, dynamic>>? _cursor;

  /// First page, by name. Resets the cursor.
  ///
  /// The paging queries were written inline in the view model against a
  /// second `FirebaseFirestore.instance`; they belong here.
  Future<List<Student>> getFirstStudentList(int limit) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection(student)
        .orderBy("name", descending: false)
        .limit(limit)
        .get();
    _cursor = snapshot.docs.isEmpty ? null : snapshot.docs.last;
    return snapshot.docs
        .map((doc) => Student.fromDocumentSnapshot(doc))
        .toList();
  }

  /// The page after the last one returned. Empty when there is no cursor
  /// yet or nothing further to read.
  Future<List<Student>> getNextStudentList(int limit) async {
    final DocumentSnapshot<Map<String, dynamic>>? cursor = _cursor;
    if (cursor == null) return const [];

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection(student)
        .orderBy("name", descending: false)
        .startAfterDocument(cursor)
        .limit(limit)
        .get();
    if (snapshot.docs.isNotEmpty) _cursor = snapshot.docs.last;
    return snapshot.docs
        .map((doc) => Student.fromDocumentSnapshot(doc))
        .toList();
  }

  Future<int> getStudentListLength() async {
    AggregateQuerySnapshot countSnapshot =
        await _firestore.collection(student).count().get();
    return countSnapshot.count ?? 0;
  }

  Future<void> deleteStudent(String studentId) async {
    await _firestore.collection(student).doc(studentId).delete();
  }

  /// Resets how many devices a student is signed in on.
  Future<void> clearDeviceCount(String studentId) async {
    await _firestore
        .collection(student)
        .doc(studentId)
        .update({"device_count": 0});
  }

  Future<List<CourseModel>> getCourseList() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection(course).get();
    return snapshot.docs
        .map((docSnapshot) => CourseModel.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  Future<List<SubjectModel>> getSubjectList(String courseId) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection(subject)
        .where("course_code", isEqualTo: courseId)
        .get();
    return snapshot.docs
        .map((docSnapshot) => SubjectModel.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  Future<List<UnitModel>> getUnitList({required String subjectCode}) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection(unit)
        .where("subject_code", isEqualTo: subjectCode)
        .get();
    return snapshot.docs
        .map((docSnapshot) => UnitModel.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  /// The student's enrolment document, or null when they have none.
  ///
  /// It used to return `snapshot.docs.first` unguarded, which throws a
  /// StateError for any student who has never been enrolled in anything —
  /// that is, every student, the first time you open their settings.
  Future<EnrolledCourseBaseModel?> getEnrolledCourseList(
      String studentId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection(enrolledCourse)
        .where("student_id", isEqualTo: studentId)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return EnrolledCourseBaseModel.fromDocumentSnapshot(snapshot.docs.first);
  }

  /// Appends [newCourse] to the student's enrolment document, creating a
  /// properly shaped one if they have none yet.
  ///
  /// The old fallback did `studentsRef.add(newCourse)` — it wrote the bare
  /// *course* map as a top-level document, with no `student_id` and no
  /// `course_list`, so a student's very first enrolment produced a document
  /// nothing could read back. It also swallowed the failure and did not
  /// await the write.
  Future<void> addCourse(
      Map<String, dynamic> newCourse, String studentId, String studentName) async {
    final CollectionReference<Map<String, dynamic>> enrolments =
        _firestore.collection(enrolledCourse);
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await enrolments.where('student_id', isEqualTo: studentId).get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'course_list': FieldValue.arrayUnion([newCourse]),
      });
      return;
    }

    await enrolments.add({
      "student_id": studentId,
      "student_name": studentName,
      "course_list": [newCourse],
    });
  }

  Future<void> updateEnrolment(
      String docId, Map<String, dynamic> data) async {
    await _firestore.collection(enrolledCourse).doc(docId).update(data);
  }

  Future<void> deleteEnrolment(String docId) async {
    await _firestore.collection(enrolledCourse).doc(docId).delete();
  }
}
