import 'package:bbarna/core/widgets/app_header.dart';
import 'package:bbarna/core/widgets/save_button.dart';
import 'package:bbarna/core/widgets/sidebar.dart';
import 'package:bbarna/resources/app_colors.dart';
import 'package:flutter/material.dart';

/// Shared page shell for the Add/Edit Teacher screens: header, responsive
/// sidebar/drawer, centered card, title/subtitle, and the Cancel/Save row.
///
/// [formContent] is everything between the subtitle and that row — each
/// screen still builds its own fields since those genuinely differ (e.g.
/// username is editable on Add, read-only on Edit).
class TeacherFormScaffold extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String title;
  final String subtitle;
  final Widget formContent;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const TeacherFormScaffold({
    required this.scaffoldKey,
    required this.title,
    required this.subtitle,
    required this.formContent,
    required this.isSaving,
    required this.onSave,
    required this.onCancel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: scaffoldKey,
      body: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
        },
        canPop: true,
        child: Column(
          children: [
            AppHeader(
              onTapIcon: () {
                scaffoldKey.currentState?.openDrawer();
              },
            ),
            Expanded(
              child: Row(
                children: [
                  if (width > 900)
                    const Expanded(child: ExtraSideBar(sidebarIndex: 11)),
                  Expanded(
                    flex: 5,
                    child: Container(
                      color: AppColorsInApp.colorGrey.withValues(alpha: .06),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: width < 900 ? 16 : 40,
                          vertical: 30,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 480),
                            child: Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: AppColorsInApp.colorWhite,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColorsInApp.colorGrey
                                        .withValues(alpha: .18),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColorsInApp.colorBlack1),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle,
                                    style: TextStyle(
                                        fontSize: 12.5,
                                        color: AppColorsInApp.colorGrey
                                            .withValues(alpha: .9)),
                                  ),
                                  const SizedBox(height: 24),
                                  formContent,
                                  const SizedBox(height: 32),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton(
                                        onPressed: isSaving ? null : onCancel,
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          side: BorderSide(
                                              color: AppColorsInApp.colorGrey
                                                  .withValues(alpha: .5)),
                                        ),
                                        child: const Text("Cancel",
                                            style: TextStyle(
                                                color: AppColorsInApp
                                                    .colorBlack1)),
                                      ),
                                      const SizedBox(width: 12),
                                      isSaving
                                          ? const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12),
                                              child: SizedBox(
                                                height: 24,
                                                width: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2.5),
                                              ),
                                            )
                                          : SaveButton(
                                              key: const Key(
                                                  'teacher_save_button'),
                                              onPRess: onSave,
                                              buttonColor: AppColorsInApp
                                                  .colorSecondary,
                                            ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: width < 900
          ? const Drawer(child: ExtraSideBar(sidebarIndex: 11))
          : null,
    );
  }
}

/// Bold, small-caps-styled label for a form section ("BASIC INFORMATION",
/// "ROLE", "MODULE ACCESS").
class TeacherSectionLabel extends StatelessWidget {
  final String text;
  const TeacherSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.4,
        color: AppColorsInApp.colorGrey,
      ),
    );
  }
}

/// Muted one-line hint shown under a [TeacherSectionLabel].
class TeacherSectionHint extends StatelessWidget {
  final String text;
  const TeacherSectionHint(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 12.5, color: AppColorsInApp.colorGrey.withValues(alpha: .9)),
    );
  }
}
