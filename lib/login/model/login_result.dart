/// What a successful sign-in learns about the person signing in.
///
/// The screen used to read these straight off the `QueryDocumentSnapshot`
/// and write them into SharedPreferences from inside its button callback,
/// which meant the whole sign-in path could only be exercised against real
/// Firebase.
class LoginResult {
  /// The teacher document's id. This is what becomes the session.
  final String adminId;

  /// Which modules this user may see. Empty means unrestricted — see
  /// `Helper.allowedModuleIndices`.
  final List<String> moduleAccess;

  const LoginResult({required this.adminId, required this.moduleAccess});
}
