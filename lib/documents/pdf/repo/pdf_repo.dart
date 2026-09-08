import 'dart:typed_data';
import 'package:bbarna/documents/pdf/model/pdf_model.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PdfRepo {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final Reference storageReference = FirebaseStorage.instance.ref();

  /// Returns the new document's id — no caller wants the reference itself,
  /// and being a sealed Firestore type it cannot be faked in a test.
  Future<String> addPdf(PdfModel pdfModel) async {
    final DocumentReference<Map<String, dynamic>> doc =
        await _fireStore.collection(pdf).add(pdfModel.toMap());
    return doc.id;
  }

  /// The paging cursor lives here rather than in the view model.
  ///
  /// It is a Firestore [DocumentSnapshot] — a sealed type — so a view model
  /// that held it could not be exercised without real Firebase.
  DocumentSnapshot<Map<String, dynamic>>? _cursor;

  /// First page, newest first. Resets the cursor.
  Future<List<PdfModel>> getFirstPdfList(int limit) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(pdf)
        .orderBy("timeStamp", descending: true)
        .limit(limit)
        .get();
    _cursor = snapshot.docs.isEmpty ? null : snapshot.docs.last;
    return snapshot.docs
        .map((doc) => PdfModel.fromDocumentSnapshot(doc))
        .toList();
  }

  /// The page after the last one returned. Empty when there is no cursor
  /// yet or nothing further to read.
  Future<List<PdfModel>> getNextPdfList(int limit) async {
    final DocumentSnapshot<Map<String, dynamic>>? cursor = _cursor;
    if (cursor == null) return const [];

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(pdf)
        .orderBy("timeStamp", descending: true)
        .startAfterDocument(cursor)
        .limit(limit)
        .get();
    if (snapshot.docs.isNotEmpty) _cursor = snapshot.docs.last;
    return snapshot.docs
        .map((doc) => PdfModel.fromDocumentSnapshot(doc))
        .toList();
  }

  Future<void> updatePdf(PdfModel pdfModel, String docId) async {
    await _fireStore.collection(pdf).doc(docId).update(pdfModel.toMap());
  }

  Future<void> deletePdf(String docId) async {
    await _fireStore.collection(pdf).doc(docId).delete();
  }

  /// Uploads [pdfData] and points the document at it.
  ///
  /// Keyed by [pdfId], not by PDF code. The old path was `pdf_$pdfCode`,
  /// and codes are not unique — two documents sharing one silently
  /// overwrote each other's file in storage.
  ///
  /// Throws on failure rather than swallowing it: the caller used to report
  /// "Pdf added successfully" straight over the top of the error, leaving a
  /// row with no file behind it.
  Future<void> uploadPdf(Uint8List pdfData, String pdfId) async {
    final Reference pdfDirReference = storageReference.child("pdf");
    final Reference pdfReference = pdfDirReference.child("pdf_$pdfId");
    final metadata = SettableMetadata(contentType: 'application/pdf');
    await pdfReference.putData(pdfData, metadata);
    final String pdfUrl = await pdfReference.getDownloadURL();
    // Was `FirebaseFirestore.instance.collection('pdf')` — a second client
    // and a hardcoded collection name beside the one this class already
    // holds.
    await _fireStore.collection(pdf).doc(pdfId).update({"pdf_link": pdfUrl});
  }

  /// Flips one flag. The lock used to be a raw `FirebaseFirestore.instance`
  /// call made from inside the list widget — with no refresh at all after
  /// it, so the icon did not change until you left the screen.
  Future<void> setPdfFlag(String pdfId, String field, bool value) async {
    await _fireStore.collection(pdf).doc(pdfId).update({field: value});
  }

  Future<int> getPdfListLength() async {
    AggregateQuerySnapshot countSnapshot =
        await _fireStore.collection(pdf).count().get();
    return countSnapshot.count ?? 0;
  }

  /// Prefix match on `pdf_code`, server-side — the collection is paged
  /// precisely because it is too big to filter in memory.
  Future<List<PdfModel>> searchPdf(String searchText) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(pdf)
        .where("pdf_code", isGreaterThanOrEqualTo: searchText)
        .where("pdf_code", isLessThan: '${searchText}z')
        .get();
    return snapshot.docs
        .map((docSnapshot) => PdfModel.fromDocumentSnapshot(docSnapshot))
        .toList();
  }
}
