import 'package:bbarna/core/widgets/loader_dialog.dart';
import 'package:bbarna/core/widgets/remove_alert.dart';
import 'package:bbarna/resources/app_colors.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/teacher/model/teacher_model.dart';
import 'package:bbarna/teacher/screen/edit_teacher.dart';
import 'package:bbarna/teacher/viewModel/teacher_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeacherCard extends StatelessWidget {
  final TeacherModel teacherData;
  const TeacherCard({required this.teacherData, super.key});

  String _roleLabel(String role) =>
      role.isEmpty ? role : role[0].toUpperCase() + role.substring(1);

  Color _roleColor(String role) =>
      role == roleAdmin ? AppColorsInApp.colorOrange : AppColorsInApp.colorSecondary!;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColorsInApp.colorWhite,
        boxShadow: [
          BoxShadow(
            color: AppColorsInApp.colorGrey.withValues(alpha: .15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.network(
                  teacherData.imageUrl,
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "assets/images/logo.png",
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            teacherData.name,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: AppColorsInApp.colorBlack1),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _roleColor(teacherData.role)
                                .withValues(alpha: .15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _roleLabel(teacherData.role),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                              color: _roleColor(teacherData.role),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: SelectableText(
                        teacherData.username,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 0.5,
                            color: AppColorsInApp.colorGrey),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                key: Key('teacher_edit_${teacherData.username}'),
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  final TeacherViewModel teacherViewModel =
                      Provider.of<TeacherViewModel>(context, listen: false);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              EditTeacher(teacherData: teacherData)))
                      .whenComplete(() => teacherViewModel.getTeacherList());
                },
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.edit_outlined,
                    color: AppColorsInApp.colorGrey,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  final TeacherViewModel teacherViewModel =
                      Provider.of<TeacherViewModel>(context, listen: false);
                  RemoveAlert.showRemoveAlert(
                      title: teacherData.name,
                      description: "Are you sure want to delete ?",
                      onPressYes: () async {
                        LoaderDialogs.showLoadingDialog();
                        await teacherViewModel
                            .deleteTeacher(teacherData.username)
                            .whenComplete(() async {
                          Navigator.pop(context);
                          await teacherViewModel.getTeacherList();
                          Navigator.pop(context);
                        });
                      });
                },
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.delete_outline,
                    color: AppColorsInApp.colorPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            "MODULE ACCESS",
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
              color: AppColorsInApp.colorGrey,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < moduleList.length; i++)
                if (teacherData.moduleAccess.contains(moduleList[i]))
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColorsInApp.colorGrey.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(moduleIconList[i],
                            size: 13, color: AppColorsInApp.colorGrey),
                        const SizedBox(width: 5),
                        Text(
                          moduleList[i],
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColorsInApp.colorBlack1,
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}
