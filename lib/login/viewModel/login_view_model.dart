import 'package:bbarna/login/model/login_result.dart';
import 'package:bbarna/login/repo/login_repo.dart';
import 'package:bbarna/utils/session.dart';
import 'package:flutter/material.dart';

class LoginViewModel with ChangeNotifier {
  // Constructor-injectable so the sign-in path can be exercised without
  // real Firebase.
  final LoginRepo _loginRepo;
  LoginViewModel({LoginRepo? loginRepo}) : _loginRepo = loginRepo ?? LoginRepo();

  /// True while the lookup is in flight. The old screen removed its login
  /// button outright while this was true, so the form showed nothing at
  /// all where the button had been.
  bool isSubmitting = false;

  /// Why the last attempt failed, or null. Shown on the form rather than
  /// in a snackbar floating at the top of the window.
  String? errorMessage;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  void clearError() {
    if (errorMessage == null) return;
    errorMessage = null;
    notifyListeners();
  }

  /// Attempts a sign-in and, on success, starts the session.
  ///
  /// Returns true only when there is a session to route on.
  Future<bool> signIn(
      {required String username, required String password}) async {
    if (isSubmitting) return false;

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final LoginResult? result = await _loginRepo.signIn(username, password);
      if (result == null) {
        // Deliberately does not say which of the two was wrong.
        errorMessage = "That username and password do not match.";
        return false;
      }
      await Session.signIn(result);
      return true;
    } catch (e) {
      // Separate from a wrong password: the old screen reported both the
      // same way, so an outage looked like bad credentials.
      errorMessage = "Could not reach the server. Check your connection "
          "and try again.";
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
