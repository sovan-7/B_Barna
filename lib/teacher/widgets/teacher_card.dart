import 'package:bbarna/core/widgets/loader_dialog.dart';
import 'package:bbarna/core/widgets/remove_alert.dart';
import 'package:bbarna/resources/app_colors.dart';
import 'package:bbarna/teacher/model/teacher_model.dart';
import 'package:bbarna/teacher/viewModel/teacher_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeacherCard extends StatelessWidget {
  final TeacherModel teacherData;
  const TeacherCard({required this.teacherData, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColorsInApp.colorWhite,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.network(
                    teacherData.imageUrl,
                    height: 50,
                    width: 50,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        "assets/images/logo.png",
                        height: 50,
                        width: 50,
                        fit: BoxFit.fill,
                      );
                    },
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SelectableText(
                    teacherData.name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        letterSpacing: 0.5,
                        color: AppColorsInApp.colorBlack1),
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
            ],
          ),
          InkWell(
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
            child: const Icon(
              Icons.delete,
              color: AppColorsInApp.colorPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
