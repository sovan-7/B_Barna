import 'package:bbarna/resources/app_colors.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:flutter/material.dart';

/// Role chip picker shared by Add/Edit Teacher and [TeacherCard]'s badge.
class TeacherRoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onChanged;

  const TeacherRoleSelector({
    required this.selectedRole,
    required this.onChanged,
    super.key,
  });

  static String labelFor(String role) =>
      role.isEmpty ? role : role[0].toUpperCase() + role.substring(1);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final role in roleList)
          ChoiceChip(
            key: Key('role_option_$role'),
            label: Text(
              labelFor(role),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: selectedRole == role
                    ? AppColorsInApp.colorWhite
                    : AppColorsInApp.colorBlack1,
              ),
            ),
            showCheckmark: false,
            selected: selectedRole == role,
            selectedColor: AppColorsInApp.colorSecondary,
            backgroundColor: AppColorsInApp.colorGrey.withValues(alpha: .08),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            onSelected: (checked) {
              if (checked) onChanged(role);
            },
          ),
      ],
    );
  }
}
