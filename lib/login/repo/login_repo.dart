import 'dart:convert';

import 'package:bbarna/login/model/login_result.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

class LoginRepo {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  /// Looks up the teacher whose username and password hash both match.
  /// Returns null when nothing matches; throws when the lookup itself
  /// fails, so the caller can tell "wrong password" from "no network".
  ///
  /// The old screen caught both in one `try` and reported them as the same
  /// thing.
  Future<LoginResult?> signIn(String username, String password) async {
    // Teacher docs store a SHA-256 hash (see TeacherViewModel.addTeacher),
    // never the raw password — hash the typed password the same way before
    // comparing, or this query never matches.
    final String hashedPassword =
        sha256.convert(utf8.encode(password)).toString();

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection(teacher)
        .where('username', isEqualTo: username)
        .where('password', isEqualTo: hashedPassword)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final QueryDocumentSnapshot<Map<String, dynamic>> doc = snapshot.docs.first;
    return LoginResult(
      adminId: doc.id,
      moduleAccess: List<String>.from(doc.data()['module_access'] ?? []),
    );
  }
}
