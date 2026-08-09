import 'dart:typed_data';

import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/teacher/model/teacher_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UsernameTakenException implements Exception {
  final String username;
  UsernameTakenException(this.username);

  @override
  String toString() => 'Username "$username" is already taken';
}

class TeacherRepo {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  TeacherRepo({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  /// A fresh, random ID unrelated to any username — used to key the photo's
  /// Storage path so two "add teacher" attempts can never collide there,
  /// even if their usernames do. Pure client-side generation, no network call.
  String generateStorageKey() => _firestore.collection(teacher).doc().id;

  Future<String> uploadTeacherImage(Uint8List image, String storageKey) async {
    final Reference reference =
        _storage.ref().child("images").child("teacher_$storageKey");
    final metadata = SettableMetadata(contentType: "image/jpeg");
    await reference.putData(image, metadata);
    return reference.getDownloadURL();
  }

  /// [teacherModel.username] must already be normalized (lowercased) by the
  /// caller — it is used verbatim as the Firestore document ID.
  ///
  /// Runs inside a transaction so the existence check and the write are
  /// atomic: throws [UsernameTakenException] without ever calling `set` if
  /// the username is already taken, closing the check-then-write race a
  /// plain "query then add" would have.
  Future<void> addTeacher(TeacherModel teacherModel) async {
    final docRef = _firestore.collection(teacher).doc(teacherModel.username);
    await _firestore.runTransaction<void>((transaction) async {
      final existing = await transaction.get(docRef);
      if (existing.exists) {
        throw UsernameTakenException(teacherModel.username);
      }
      transaction.set(docRef, teacherModel.toMap());
    });
  }

  /// Username (and therefore the doc ID) is immutable once created — this
  /// only ever updates the doc at [teacherModel.docId], never moves it.
  Future<void> updateTeacher(TeacherModel teacherModel) async {
    await _firestore
        .collection(teacher)
        .doc(teacherModel.docId)
        .update(teacherModel.toMap());
  }

  Future<List<TeacherModel>> getTeacherList() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection(teacher).get();
    return snapshot.docs
        .map((docSnapshot) => TeacherModel.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  Future<void> deleteTeacher(String username) async {
    await _firestore.collection(teacher).doc(username).delete();
  }
}
