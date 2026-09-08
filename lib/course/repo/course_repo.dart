import 'dart:typed_data';

import 'package:bbarna/course/model/course_model.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CourseRepo {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final Reference storageReference = FirebaseStorage.instance.ref();

  /// Returns the new document's id — no caller wants the reference itself,
  /// and being a sealed Firestore type it cannot be faked in a test.
  Future<String> addCourse(CourseModel courseModel) async {
    final DocumentReference<Map<String, dynamic>> doc =
        await _fireStore.collection(course).add(courseModel.toMap());
    return doc.id;
  }

  Future<List<CourseModel>> getCourseList() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _fireStore.collection(course).get();
    return snapshot.docs
        .map((docSnapshot) => CourseModel.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  /// Uploads [image] and points the course document at it.
  ///
  /// Keyed by [courseId], not by course code. The old path was
  /// `img_$courseCode`, and course codes are not unique — two courses that
  /// shared a code silently overwrote each other's picture in storage.
  ///
  /// Throws on failure rather than swallowing it: the caller used to report
  /// "Course added successfully" straight over the top of the error.
  Future<void> uploadCourseImage(Uint8List image, String courseId) async {
    final Reference referenceDirImages = storageReference.child("images");
    final Reference referenceImageToUpload =
        referenceDirImages.child("img_$courseId");

    final metadata = SettableMetadata(contentType: "image/jpeg");
    await referenceImageToUpload.putData(image, metadata);
    final String imageUrl = await referenceImageToUpload.getDownloadURL();
    await _fireStore
        .collection(course)
        .doc(courseId)
        .update({"course_image": imageUrl});
  }

  Future<void> updateCourse(CourseModel courseModel, String docId) async {
    await _fireStore.collection(course).doc(docId).update(courseModel.toMap());
  }

  /// Flips just the lock flag. This used to be done with a raw
  /// `FirebaseFirestore.instance` call from inside the list widget.
  Future<void> setCourseLocked(String docId, bool isLocked) async {
    await _fireStore
        .collection(course)
        .doc(docId)
        .update({"isLocked": isLocked});
  }

  Future<void> deleteCourse(String docId) async {
    await _fireStore.collection(course).doc(docId).delete();
  }
}
