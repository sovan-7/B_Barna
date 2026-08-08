import 'dart:convert';
import 'dart:typed_data';

import 'package:bbarna/core/widgets/loader_dialog.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/teacher/model/teacher_model.dart';
import 'package:bbarna/teacher/repo/teacher_repo.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class TeacherViewModel with ChangeNotifier {
  // Constructor-injectable, unlike every other ViewModel in this codebase
  // (which instantiate their repo directly) — the minimal seam needed to
  // unit-test the orchestration below (hash-before-write, upload-then-add
  // ordering) without touching real Firebase.
  final TeacherRepo _teacherRepo;
  TeacherViewModel({TeacherRepo? teacherRepo})
      : _teacherRepo = teacherRepo ?? TeacherRepo();

  List<TeacherModel> teacherList = [];
  List<TeacherModel> copyTeacherList = [];

  /// Returns true on success. On failure, shows a snackbar explaining why
  /// and returns false — the caller (AddTeacher screen) decides what to do
  /// next (e.g. stay on the form).
  Future<bool> addTeacher({
    required String name,
    required String username,
    required String password,
    required Uint8List image,
  }) async {
    final String normalizedUsername = username.toLowerCase();
    final String storageKey = _teacherRepo.generateStorageKey();

    late final String imageUrl;
    try {
      imageUrl = await _teacherRepo.uploadTeacherImage(image, storageKey);
    } catch (e) {
      Helper.showSnackBarMessage(
          msg: "Error while uploading photo", isSuccess: false);
      return false;
    }

    final String hashedPassword = sha256.convert(utf8.encode(password)).toString();

    final TeacherModel model = TeacherModel(
      docId: normalizedUsername,
      name: name,
      imageUrl: imageUrl,
      username: normalizedUsername,
      password: hashedPassword,
      timeStamp: DateTime.now().millisecondsSinceEpoch,
    );

    try {
      await _teacherRepo.addTeacher(model);
    } on UsernameTakenException {
      Helper.showSnackBarMessage(
          msg: "Username already taken", isSuccess: false);
      return false;
    } catch (e) {
      Helper.showSnackBarMessage(
          msg: "Error while creating teacher", isSuccess: false);
      return false;
    }

    return true;
  }

  Future getTeacherList() async {
    LoaderDialogs.showLoadingDialog();
    teacherList = await _teacherRepo
        .getTeacherList()
        .whenComplete(() => Navigator.pop(navigatorKey.currentContext!));
    copyTeacherList = teacherList;
    notifyListeners();
  }

  Future deleteTeacher(String username) async {
    await _teacherRepo.deleteTeacher(username).whenComplete(() {
      Helper.showSnackBarMessage(
          msg: "Teacher deleted successfully", isSuccess: false);
    });
  }

  void searchTeacher({required String searchText}) {
    if (searchText.isEmpty) {
      teacherList = copyTeacherList;
    } else {
      teacherList = copyTeacherList
          .where((teacher) =>
              teacher.name.toLowerCase().contains(searchText.toLowerCase()) ||
              teacher.username.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}
