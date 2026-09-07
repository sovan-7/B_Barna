import 'package:bbarna/live_class/model/live_class_model.dart';
import 'package:bbarna/live_class/repo/live_class_repo.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class LiveClassViewModel with ChangeNotifier {
  // Constructor-injectable like TeacherViewModel (and unlike the older
  // ViewModels, which new their repo inline) so the list/status logic below
  // can be exercised without real Firebase.
  final LiveClassRepo _liveClassRepo;
  LiveClassViewModel({LiveClassRepo? liveClassRepo})
      : _liveClassRepo = liveClassRepo ?? LiveClassRepo();

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Safe to call from any point in the frame.
  ///
  /// [LiveClassList] is mounted from `Sidebar.screenList[selectedIndex]`
  /// *during* a build, and the refresh entry points below (a route's
  /// `whenComplete`, the search field, tab selection) can each land while
  /// the framework is mid-build — notifying then throws "setState() or
  /// markNeedsBuild() called during build" and the list is left showing a
  /// stale frame. Deferring to the end of the current frame keeps every
  /// caller free of scheduling concerns; outside a build it notifies
  /// synchronously as usual.
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

  List<LiveClassModel> liveClassList = [];
  List<LiveClassModel> copyLiveClassList = [];
  List<String> teacherNames = [];

  /// Drives the inline spinner/empty state on [LiveClassList]. This module
  /// deliberately uses an in-place loading flag rather than the global
  /// LoaderDialogs overlay: the list is embedded in the sidebar shell, so
  /// there is no pushed route for the dialog's `Navigator.pop` to unwind.
  ///
  /// Starts true so the first frame — rendered before the deferred
  /// [getLiveClassList] in LiveClassList.initState runs — shows the loader
  /// rather than flashing "No upcoming classes".
  bool isLoading = true;

  /// The tab currently selected on the list screen.
  LiveClassStatus selectedStatus = LiveClassStatus.upcoming;

  Future<void> getLiveClassList() async {
    isLoading = true;
    notifyListeners();
    try {
      liveClassList = await _liveClassRepo.getLiveClassList();
      copyLiveClassList = liveClassList;
    } catch (e) {
      Helper.showSnackBarMessage(
          msg: "Error while fetching classes", isSuccess: false);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getTeacherNames() async {
    try {
      teacherNames = await _liveClassRepo.getTeacherNames();
    } catch (e) {
      teacherNames = [];
    }
    notifyListeners();
  }

  void selectStatus(LiveClassStatus status) {
    selectedStatus = status;
    notifyListeners();
  }

  /// Classes in [status], soonest-first for Upcoming/Live and
  /// most-recent-first for Past — the order an admin scans each tab in.
  List<LiveClassModel> classesFor(LiveClassStatus status, {DateTime? now}) {
    final DateTime at = now ?? DateTime.now();
    final List<LiveClassModel> filtered = liveClassList
        .where((liveClass) => liveClass.statusAt(at) == status)
        .toList();
    filtered.sort((a, b) => status == LiveClassStatus.past
        ? b.startDateTime.compareTo(a.startDateTime)
        : a.startDateTime.compareTo(b.startDateTime));
    return filtered;
  }

  int countFor(LiveClassStatus status, {DateTime? now}) =>
      classesFor(status, now: now).length;

  /// Returns true on success; on failure shows a snackbar and returns false,
  /// leaving the caller on the form (same contract as TeacherViewModel).
  Future<bool> addLiveClass(LiveClassModel liveClassModel) async {
    try {
      await _liveClassRepo.addLiveClass(liveClassModel);
      return true;
    } catch (e) {
      Helper.showSnackBarMessage(
          msg: "Error while adding class", isSuccess: false);
      return false;
    }
  }

  Future<bool> updateLiveClass(LiveClassModel liveClassModel) async {
    try {
      await _liveClassRepo.updateLiveClass(liveClassModel);
      return true;
    } catch (e) {
      Helper.showSnackBarMessage(
          msg: "Error while updating class", isSuccess: false);
      return false;
    }
  }

  Future<bool> deleteLiveClass(String docId) async {
    try {
      await _liveClassRepo.deleteLiveClass(docId);
      return true;
    } catch (e) {
      Helper.showSnackBarMessage(
          msg: "Error while deleting class", isSuccess: false);
      return false;
    }
  }

  /// Local filter over the already-fetched list (matches title or teacher),
  /// mirroring TeacherViewModel.searchTeacher.
  void searchLiveClass({required String searchText}) {
    if (searchText.trim().isEmpty) {
      liveClassList = copyLiveClassList;
    } else {
      final String query = searchText.toLowerCase().trim();
      liveClassList = copyLiveClassList
          .where((liveClass) =>
              liveClass.title.toLowerCase().contains(query) ||
              liveClass.teacherName.toLowerCase().contains(query))
          .toList();
    }
    notifyListeners();
  }
}
