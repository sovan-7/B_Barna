import 'package:bbarna/login/model/login_result.dart';
import 'package:bbarna/resources/constant.dart';

/// The signed-in admin's session.
///
/// A session here is just the teacher document id `LoginScreen` stashes in
/// SharedPreferences, plus the module list that came with it. Both were
/// read and written as bare string literals from three different files;
/// they go through here now, so signing out cannot miss one.
class Session {
  const Session._();

  /// The signed-in teacher's document id, or null when nobody is signed in.
  ///
  /// Guarded like [Helper.allowedModuleIndices]: `sharedPreferences` is
  /// late-initialized and throws anywhere it has not been set up, widget
  /// tests included.
  static String? get adminId {
    try {
      return sharedPreferences.getString(adminIdPrefsKey);
    } catch (_) {
      return null;
    }
  }

  static bool get isSignedIn => adminId != null;

  /// Starts a session for the user [result] identifies.
  ///
  /// The counterpart to [signOut] — both keys are written here, so neither
  /// can be forgotten on the way in or left behind on the way out. The
  /// login screen used to write them itself, inline in a button callback.
  static Future<void> signIn(LoginResult result) async {
    try {
      await sharedPreferences.setString(adminIdPrefsKey, result.adminId);
      await sharedPreferences.setStringList(
          moduleAccessPrefsKey, result.moduleAccess);
    } catch (_) {
      // No store to write to. The sign-in still stands for this session;
      // it just will not survive a reload.
    }
  }

  /// Clears the session.
  ///
  /// Only the session keys go: `sidebar_collapsed` is a preference about
  /// this browser, not about who is using it, so the rail stays how it was
  /// left for whoever signs in next. Module access, on the other hand, is
  /// the previous user's — leaving it behind would let the next sign-in
  /// briefly render their sidebar.
  static Future<void> signOut() async {
    try {
      await sharedPreferences.remove(adminIdPrefsKey);
      await sharedPreferences.remove(moduleAccessPrefsKey);
    } catch (_) {
      // Nothing to clear — there was no store to clear it from.
    }
  }
}
