import 'package:bbarna/resources/app_colors.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:flutter/material.dart';

/// Module-access chip picker shared by Add/Edit Teacher.
class TeacherModuleAccessSelector extends StatelessWidget {
  final Set<String> selectedModules;
  final void Function(String module, bool checked) onToggle;

  const TeacherModuleAccessSelector({
    required this.selectedModules,
    required this.onToggle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (int i = 0; i < moduleList.length; i++)
          FilterChip(
            key: Key('module_checkbox_${moduleList[i]}'),
            avatar: Icon(
              moduleIconList[i],
              size: 17,
              color: selectedModules.contains(moduleList[i])
                  ? AppColorsInApp.colorWhite
                  : AppColorsInApp.colorGrey,
            ),
            label: Text(
              moduleList[i],
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: selectedModules.contains(moduleList[i])
                    ? AppColorsInApp.colorWhite
                    : AppColorsInApp.colorBlack1,
              ),
            ),
            showCheckmark: false,
            selected: selectedModules.contains(moduleList[i]),
            selectedColor: AppColorsInApp.colorSecondary,
            backgroundColor: AppColorsInApp.colorGrey.withValues(alpha: .08),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            onSelected: (checked) => onToggle(moduleList[i], checked),
          ),
      ],
    );
  }
}
