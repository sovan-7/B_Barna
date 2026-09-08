import 'dart:typed_data';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/subject/model/subject_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SubjectRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Reference storageReference = FirebaseStorage.instance.ref();

  /// Returns the new document's id — no caller wants the reference itself,
  /// and being a sealed Firestore type it cannot be faked in a test.
  Future<String> addSubject(SubjectModel subjectModel) async {
    final DocumentReference<Map<String, dynamic>> doc =
        await _firestore.collection(subject).add(subjectModel.toMap());
    return doc.id;
  }

  Future<List<SubjectModel>> getSubjectList() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection(subject).get();
    return snapshot.docs
        .map((docSnapshot) => SubjectModel.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  /// Uploads [image] and points the subject document at it.
  ///
  /// Keyed by [subjectId], not by subject code. The old path was
  /// `img_$subjectCode`, and subject codes are not unique across courses —
  /// two subjects sharing a code silently overwrote each other's picture.
  ///
  /// Throws on failure rather than swallowing it: the caller used to report
  /// "Subject added successfully" straight over the top of the error.
  Future<void> uploadSubjectImage(Uint8List image, String subjectId) async {
    final Reference referenceDirImages = storageReference.child("images");
    final Reference referenceImageToUpload =
        referenceDirImages.child("img_$subjectId");

    final metadata = SettableMetadata(contentType: "image/jpeg");
    await referenceImageToUpload.putData(image, metadata);
    final String imageUrl = await referenceImageToUpload.getDownloadURL();
    await _firestore
        .collection(subject)
        .doc(subjectId)
        .update({"subject_image": imageUrl});
  }

  Future<void> updateSubject(
      SubjectModel subjectModel, String subjectId) async {
    await _firestore
        .collection(subject)
        .doc(subjectId)
        .update(subjectModel.toMap());
  }

  /// Flips one flag. Both the lock and the "popular" heart used to be raw
  /// `FirebaseFirestore.instance` calls made from inside the list widget.
  Future<void> setSubjectFlag(
      String subjectId, String field, bool value) async {
    await _firestore.collection(subject).doc(subjectId).update({field: value});
  }

  Future<void> deleteSubject(String subjectId) async {
    await _firestore.collection(subject).doc(subjectId).delete();
  }
}
