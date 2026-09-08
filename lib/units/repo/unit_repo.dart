import 'dart:typed_data';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/subject/model/subject_model.dart';
import 'package:bbarna/units/model/unit_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UnitRepo {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final Reference storageReference = FirebaseStorage.instance.ref();

  /// Returns the new document's id — no caller wants the reference itself,
  /// and being a sealed Firestore type it cannot be faked in a test.
  Future<String> addUnit(UnitModel unitModel) async {
    final DocumentReference<Map<String, dynamic>> doc =
        await _fireStore.collection(unit).add(unitModel.toMap());
    return doc.id;
  }

  /// The paging cursor lives here rather than in the view model.
  ///
  /// It is a Firestore [DocumentSnapshot] — a sealed type — so a view model
  /// that held it could not be exercised without real Firebase. Keeping it
  /// behind the repo means the pages come back as plain models.
  DocumentSnapshot<Map<String, dynamic>>? _cursor;

  /// First page, newest first. Resets the cursor.
  Future<List<UnitModel>> getFirstUnitList(int limit) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(unit)
        .orderBy("timeStamp", descending: true)
        .limit(limit)
        .get();
    _cursor = snapshot.docs.isEmpty ? null : snapshot.docs.last;
    return snapshot.docs
        .map((doc) => UnitModel.fromDocumentSnapshot(doc))
        .toList();
  }

  /// The page after the last one returned. Empty when there is no cursor
  /// yet or nothing further to read.
  Future<List<UnitModel>> getNextUnitList(int limit) async {
    final DocumentSnapshot<Map<String, dynamic>>? cursor = _cursor;
    if (cursor == null) return const [];

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(unit)
        .orderBy("timeStamp", descending: true)
        .startAfterDocument(cursor)
        .limit(limit)
        .get();
    if (snapshot.docs.isNotEmpty) _cursor = snapshot.docs.last;
    return snapshot.docs
        .map((doc) => UnitModel.fromDocumentSnapshot(doc))
        .toList();
  }

  /// Uploads [image] and points the unit document at it.
  ///
  /// Keyed by [unitId], not by unit code. The old path was
  /// `img_unit_$unitCode`, and unit codes are not unique across subjects —
  /// two units sharing a code silently overwrote each other's picture.
  ///
  /// Throws on failure rather than swallowing it: the caller used to report
  /// "Unit added successfully" straight over the top of the error.
  Future<void> uploadUnitImage(Uint8List image, String unitId) async {
    final Reference referenceDirImages = storageReference.child("images");
    final Reference referenceImageToUpload =
        referenceDirImages.child("img_unit_$unitId");

    final metadata = SettableMetadata(contentType: "image/jpeg");
    await referenceImageToUpload.putData(image, metadata);
    final String imageUrl = await referenceImageToUpload.getDownloadURL();
    await _fireStore
        .collection(unit)
        .doc(unitId)
        .update({"unit_image": imageUrl});
  }

  Future<void> updateUnit(UnitModel unitModel, String unitId) async {
    await _fireStore.collection(unit).doc(unitId).update(unitModel.toMap());
  }

  /// Flips one flag. The lock used to be a raw `FirebaseFirestore.instance`
  /// call made from inside the list widget.
  Future<void> setUnitFlag(String unitId, String field, bool value) async {
    await _fireStore.collection(unit).doc(unitId).update({field: value});
  }

  Future<void> deleteUnit(String unitId) async {
    await _fireStore.collection(unit).doc(unitId).delete();
  }

  Future<List<SubjectModel>> getSubjectListByCourseCode(
      String courseCode) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(subject)
        .where("course_code", isEqualTo: courseCode)
        .get();
    return snapshot.docs
        .map((docSnapshot) => SubjectModel.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  Future<int> getUnitListLength() async {
    AggregateQuerySnapshot countSnapshot =
        await _fireStore.collection(unit).count().get();
    return countSnapshot.count ?? 0;
  }

  /// Prefix match on `unit_code`, server-side — the collection is paged
  /// precisely because it is too big to filter in memory.
  Future<List<UnitModel>> searchUnit(String searchText) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(unit)
        .where("unit_code", isGreaterThanOrEqualTo: searchText)
        .where("unit_code", isLessThan: '${searchText}z')
        .get();
    return snapshot.docs
        .map((docSnapshot) => UnitModel.fromDocumentSnapshot(docSnapshot))
        .toList();
  }
}
