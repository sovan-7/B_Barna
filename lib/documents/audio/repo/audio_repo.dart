import 'dart:typed_data';
import 'package:bbarna/documents/audio/model/audio_model.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AudioRepo {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final Reference storageReference = FirebaseStorage.instance.ref();

  /// Returns the new document's id — no caller wants the reference itself,
  /// and being a sealed Firestore type it cannot be faked in a test.
  Future<String> addAudio(AudioModel audioModel) async {
    final DocumentReference<Map<String, dynamic>> doc =
        await _fireStore.collection(audio).add(audioModel.toMap());
    return doc.id;
  }

  /// The paging cursor lives here rather than in the view model.
  ///
  /// It is a Firestore [DocumentSnapshot] — a sealed type — so a view model
  /// that held it could not be exercised without real Firebase.
  DocumentSnapshot<Map<String, dynamic>>? _cursor;

  /// First page, newest first. Resets the cursor.
  Future<List<AudioModel>> getFirstAudioList(int limit) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(audio)
        .orderBy("timeStamp", descending: true)
        .limit(limit)
        .get();
    _cursor = snapshot.docs.isEmpty ? null : snapshot.docs.last;
    return snapshot.docs
        .map((doc) => AudioModel.fromDocumentSnapshot(doc))
        .toList();
  }

  /// The page after the last one returned. Empty when there is no cursor
  /// yet or nothing further to read.
  Future<List<AudioModel>> getNextAudioList(int limit) async {
    final DocumentSnapshot<Map<String, dynamic>>? cursor = _cursor;
    if (cursor == null) return const [];

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(audio)
        .orderBy("timeStamp", descending: true)
        .startAfterDocument(cursor)
        .limit(limit)
        .get();
    if (snapshot.docs.isNotEmpty) _cursor = snapshot.docs.last;
    return snapshot.docs
        .map((doc) => AudioModel.fromDocumentSnapshot(doc))
        .toList();
  }

  Future<void> updateAudio(AudioModel audioModel, String docId) async {
    await _fireStore.collection(audio).doc(docId).update(audioModel.toMap());
  }

  Future<void> deleteAudio(String docId) async {
    await _fireStore.collection(audio).doc(docId).delete();
  }

  /// Uploads [audioData] and points the document at it.
  ///
  /// Keyed by [audioId], not by audio code. The old path was `pdf_$pdfCode`,
  /// and codes are not unique — two documents sharing one silently
  /// overwrote each other's file in storage.
  ///
  /// Throws on failure rather than swallowing it: the caller used to report
  /// "Pdf added successfully" straight over the top of the error, leaving a
  /// row with no file behind it.
  Future<void> uploadAudio(Uint8List audioData, String audioId) async {
    final Reference pdfDirReference = storageReference.child("pdf");
    final Reference pdfReference = pdfDirReference.child("pdf_$audioId");
    final metadata = SettableMetadata(contentType: 'application/pdf');
    await pdfReference.putData(audioData, metadata);
    final String pdfUrl = await pdfReference.getDownloadURL();
    // Was `FirebaseFirestore.instance.collection('pdf')` — a second client
    // and a hardcoded collection name beside the one this class already
    // holds.
    await _fireStore.collection(audio).doc(audioId).update({"pdf_link": pdfUrl});
  }

  Future<int> getAudioListLength() async {
    AggregateQuerySnapshot countSnapshot =
        await _fireStore.collection(audio).count().get();
    return countSnapshot.count ?? 0;
  }

  /// Prefix match on `pdf_code`, server-side — the collection is paged
  /// precisely because it is too big to filter in memory.
  Future<List<AudioModel>> searchAudio(String searchText) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(audio)
        .where("audio_code", isGreaterThanOrEqualTo: searchText)
        .where("audio_code", isLessThan: '${searchText}z')
        .get();
    return snapshot.docs
        .map((docSnapshot) => AudioModel.fromDocumentSnapshot(docSnapshot))
        .toList();
  }
}
