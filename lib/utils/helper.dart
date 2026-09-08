import 'package:bbarna/core/widgets/app_toast.dart';
import 'package:bbarna/resources/app_colors.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Helper {
  /// Shows [msg] as a toast in the corner of the window.
  ///
  /// Kept its name and its `isSuccess` flag because 130-odd call sites use
  /// them. [level] overrides the flag where a message is neither a success
  /// nor a failure — a completed delete, say, which used to be reported
  /// red as though it had gone wrong.
  static Future<void> showSnackBarMessage({
    required String msg,
    required bool isSuccess,
    ToastLevel? level,
  }) async {
    AppToast.show(
      message: msg,
      level: level ?? (isSuccess ? ToastLevel.success : ToastLevel.error),
    );
  }

  /// A message that reports something that happened without calling it a
  /// win or a failure.
  static Future<void> showInfoMessage({required String msg}) async {
    AppToast.show(message: msg, level: ToastLevel.info);
  }

   Widget showLoader({Color? color = const Color(0xFF8ADDE1)}) {
    return Center(
        child: LoadingAnimationWidget.hexagonDots(
      color: color ?? AppColorsInApp.colorLightBlue,
      size: 80,
    ));
  }

  /// Positions within [moduleList] the logged-in teacher may see, read from
  /// the module list stashed in SharedPreferences at login. Falls back to
  /// every index (unrestricted) when nothing was stored — covers legacy
  /// sessions/docs predating module access, and any context where
  /// [sharedPreferences] hasn't been initialized yet (e.g. widget tests).
  /// Whether the navigation rail was last left collapsed.
  ///
  /// Guarded like [allowedModuleIndices]: `sharedPreferences` is late-init
  /// and throws anywhere it hasn't been set up (widget tests included), and
  /// a remembered rail width is never worth taking a screen down for.
  static bool isSidebarCollapsed() {
    try {
      return sharedPreferences.getBool(sidebarCollapsedPrefsKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  static void setSidebarCollapsed(bool collapsed) {
    try {
      sharedPreferences.setBool(sidebarCollapsedPrefsKey, collapsed);
    } catch (_) {
      // Not worth surfacing — the rail still works, it just won't remember.
    }
  }

  static List<int> allowedModuleIndices() {
    List<String>? access;
    try {
      access = sharedPreferences.getStringList(moduleAccessPrefsKey);
    } catch (_) {
      access = null;
    }
    if (access == null || access.isEmpty) {
      return List<int>.generate(moduleList.length, (i) => i);
    }
    return [
      for (int i = 0; i < moduleList.length; i++)
        if (access.contains(moduleList[i])) i,
    ];
  }
}
