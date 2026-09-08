import 'dart:typed_data';

import 'package:bbarna/banners/model/banners_model.dart';
import 'package:bbarna/banners/repo/banners_repo.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class BannersViewModel extends ChangeNotifier {
  // Constructor-injectable so the list/upload logic can be exercised
  // without real Firebase, like TeacherViewModel and LiveClassViewModel.
  final BannersRepo _bannersRepo;
  BannersViewModel({BannersRepo? bannersRepo})
      : _bannersRepo = bannersRepo ?? BannersRepo();

  List<BannersModel> bannersList = [];

  /// Drives the grid's own skeletons. The module used to reach for the
  /// global [LoaderDialogs] overlay, which pushes a route — from
  /// `initState`, while the sidebar shell was still building.
  ///
  /// Starts true so the first frame shows placeholders rather than briefly
  /// claiming there are no banners.
  bool isLoading = true;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Safe to call from any point in the frame — [BannerList] is mounted
  /// from `Sidebar.screenList[selectedIndex]` *during* a build, so a
  /// synchronous notify from there would throw "setState() called during
  /// build".
  @override
  void notifyListeners() {
    if (_disposed) return;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (_disposed) return;
        super.notifyListeners();
      });
      return;
    }
    super.notifyListeners();
  }

  Future<void> getBannerList() async {
    isLoading = true;
    notifyListeners();
    try {
      bannersList = await _bannersRepo.getBannersList();
    } catch (e) {
      Helper.showSnackBarMessage(
          msg: "Error while fetching banners", isSuccess: false);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Creates the document and uploads its image as one operation.
  ///
  /// A banner is a row that only exists to point at a picture, so a
  /// document whose upload failed is not a partial banner — it is a broken
  /// tile in the grid. If the upload fails the empty document is removed
  /// again, and the caller is told the truth.
  Future<bool> createBanner(Uint8List image) async {
    String? docId;
    try {
      docId = await _bannersRepo.addBanner(BannersModel(bannerImage: ""));
      await _bannersRepo.uploadBannerImage(image, docId);
      return true;
    } catch (e) {
      if (docId != null) {
        // Best effort: if this fails too there is nothing further to try,
        // and the grid renders such a document as "image unavailable"
        // rather than as a broken picture.
        try {
          await _bannersRepo.deleteBanner(docId);
        } catch (_) {}
      }
      Helper.showSnackBarMessage(
          msg: "Error while uploading the banner", isSuccess: false);
      return false;
    }
  }

  Future<bool> deleteBanner(String docId) async {
    try {
      await _bannersRepo.deleteBanner(docId);
      return true;
    } catch (e) {
      Helper.showSnackBarMessage(
          msg: "Error while deleting the banner", isSuccess: false);
      return false;
    }
  }
}
