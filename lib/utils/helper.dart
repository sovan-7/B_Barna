import 'package:flutter/material.dart';
import 'package:bbarna/resources/app_colors.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Helper {
  static Future<void> showSnackBarMessage(
      {required String msg, required bool isSuccess}) async {
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(
      dismissDirection: DismissDirection.up,
      content: Text(
        msg,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic),
      ),
      backgroundColor: isSuccess
          ? AppColorsInApp.colorSecondary
          : AppColorsInApp.colorLightRed,
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(navigatorKey.currentContext!).size.height - 50,
          left: 50,
          right: 50),
      behavior: SnackBarBehavior.floating,
    ));
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
