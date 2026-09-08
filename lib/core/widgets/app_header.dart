// ignore_for_file: must_be_immutable

import 'package:bbarna/resources/app_colors.dart';
import 'package:bbarna/resources/app_tokens.dart';
import 'package:flutter/material.dart';

/// The top bar of every page.
///
/// It was a flat block of the app's light cyan with white text on it — the
/// lightest colour in the palette carrying the lightest text, which is the
/// one pairing guaranteed not to read. It is a white bar with a hairline
/// under it now; the cyan stays as the brand mark beside the title, where
/// it has something dark to sit against.
class AppHeader extends StatelessWidget {
  Function onTapIcon;

  /// Shown next to the app name — the page you are on.
  final String? title;

  AppHeader({required this.onTapIcon, this.title, super.key});

  @override
  Widget build(BuildContext context) {
    // The menu button opens the drawer, and above the breakpoint there is
    // no drawer to open — it used to sit there doing nothing on desktop.
    final bool showMenuButton =
        MediaQuery.of(context).size.width < AppTokens.compactBreakpoint;

    return Container(
      height: AppTokens.headerHeight,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: AppTokens.surface,
        border: Border(bottom: BorderSide(color: AppTokens.hairline)),
      ),
      child: Row(
        children: [
          if (showMenuButton) ...[
            _iconButton(
              icon: Icons.menu,
              tooltip: "Open navigation",
              color: AppTokens.inkMuted,
              onTap: () => onTapIcon(),
            ),
            const SizedBox(width: AppTokens.gapSm),
          ],
          // One Expanded for everything on the left, rather than a
          // Flexible title plus a Spacer: those are both flex:1, so they
          // split the free space evenly and the trailing icon ends up
          // floating in the middle of the bar instead of at its edge.
          Expanded(
            child: Row(
              children: [
                Container(
                  height: 26,
                  width: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColorsInApp.colorLightBlue,
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  ),
                  // Ink, not white: white on this cyan is about 1.7:1.
                  child: const Text(
                    "B",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTokens.ink),
                  ),
                ),
                const SizedBox(width: 10),
                // Flexible with an ellipsis as a backstop: the app name is
                // the one thing here with no length limit at all if it is
                // ever reworded.
                const Flexible(
                  child: Text(
                    "Admin Portal",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: AppTokens.ink),
                  ),
                ),
                // The breadcrumb is dropped on a phone, where it competes
                // with the app name for a bar that is already carrying two
                // buttons — and where the page's own title is right below
                // it anyway.
                if (title != null && !showMenuButton) ...[
                  const SizedBox(width: 10),
                  const Text("/",
                      style:
                          TextStyle(fontSize: 14, color: AppTokens.inkFaint)),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      title!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, color: AppTokens.inkMuted),
                    ),
                  ),
                ],
              ],
            ),
          ),
          _iconButton(
            icon: Icons.logout_rounded,
            tooltip: "Sign out",
            color: AppColorsInApp.colorPrimary,
            // Unchanged: this icon has never had a handler. Wiring it up is
            // a behaviour change, not a visual one, so it stays inert here.
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
