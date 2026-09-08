import 'dart:async';

import 'package:bbarna/documents/video/model/video_model.dart';
import 'package:bbarna/documents/video/repo/video_repo.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class VideoViewModel with ChangeNotifier {
  // Constructor-injectable so the paging, search and save logic can be
  // exercised without real Firebase.
  final VideoRepo _videoRepo;
  VideoViewModel({VideoRepo? videoRepo}) : _videoRepo = videoRepo ?? VideoRepo();

  List<VideoModel> videoList = [];

  /// How many the collection holds in total, so the list can say
  /// "showing 50 of 320" rather than just "50".
  int videoListLength = 0;
  final int limit = 50;

  /// Drives the skeletons. The module used to reach for the global
  /// [LoaderDialogs] overlay, which pushes a route, from `initState` while
  /// the sidebar shell was still building.
  bool isLoading = true;
  bool isLoadingMore = false;

  /// Set while a search is showing, because searching queries the server
  /// separately and paging does not apply to the result.
  bool isSearching = false;

  Timer? _debounce;
  bool _disposed = false;

  bool get hasMore => !isSearching && videoList.length < videoListLength;

  @override
  void dispose() {
    _debounce?.cancel();
    _disposed = true;
    super.dispose();
  }

  /// Safe to call from any point in the frame — [VideoList] is mounted from
  /// `Sidebar.screenList[selectedIndex]` *during* a build.
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

  Future<void> getFirstVideoList() async {
    isLoading = true;
    isSearching = false;
    notifyListeners();
    try {
      videoList = await _videoRepo.getFirstVideoList(limit);
      videoListLength = await _videoRepo.getVideoListLength();
    } catch (e) {
      Helper.showSnackBarMessage(
          msg: "Error while fetching videos", isSuccess: false);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getNextVideoList() async {
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    notifyListeners();
    try {
      videoList.addAll(await _videoRepo.getNextVideoList(limit));
    } catch (e) {
      Helper.showSnackBarMessage(
          msg: "Error while fetching more videos", isSuccess: false);
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<bool> addVideo(VideoModel videoModel) async {
    try {
      await _videoRepo.addVideo(videoModel);
      return true;
    } catch (e) {
      Helper.showSnackBarMessage(
          msg: "Error while adding the video", isSuccess: false);
      return false;
    }
  }

  Future<bool> updateVideo(VideoModel videoModel, String docId) async {
    try {
      await _videoRepo.updateVideo(videoModel, docId);
      return true;
    } catch (e) {
      Helper.showSnackBarMessage(
          msg: "Error while updating the video", isSuccess: false);
      return false;
    }
  }

  Future<bool> deleteVideo(String docId) async {
    try {
      await _videoRepo.deleteVideo(docId);
      return true;
    } catch (e) {
      Helper.showSnackBarMessage(
          msg: "Error while deleting the video", isSuccess: false);
      return false;
    }
  }

  /// Debounced prefix search on the video code, run server-side because
  /// the collection is paged and most of it is not in memory.
  Future<void> searchVideo({required String searchText}) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (searchText.trim().isEmpty) {
        await getFirstVideoList();
        return;
      }

      isSearching = true;
      isLoading = true;
      notifyListeners();
      try {
        videoList =
            await _videoRepo.searchVideo(searchText.trim().toUpperCase());
      } catch (e) {
        videoList = [];
        // The old catch popped the current route before showing this —
        // a failed search took the whole page off the navigator.
        Helper.showSnackBarMessage(
            msg: "Error while searching videos", isSuccess: false);
      } finally {
        isLoading = false;
        notifyListeners();
      }
    });
  }
}
