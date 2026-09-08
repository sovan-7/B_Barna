import 'package:bbarna/core/widgets/remove_alert.dart';
import 'package:bbarna/core/widgets/selectable_label.dart';
import 'package:bbarna/resources/app_tokens.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/student/model/student_model.dart';
import 'package:bbarna/student/screen/settings_student.dart';
import 'package:bbarna/student/viewModel/student_viewmodel.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// One student row.
///
/// The old row was a fixed-height `Row` of un-flexed `Row`s wrapped in a
/// `FittedBox` below 900px, which "fixed" overflow by shrinking every row,
/// text and all, until it fit. This row flexes and reflows.
class StudentCard extends StatefulWidget {
  final Student student;
  final VoidCallback onChanged;

  const StudentCard({required this.student, required this.onChanged, super.key});

  @override
  State<StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCard> {
  bool _hovered = false;

  Student get _data => widget.student;

  int get _deviceCount {
    final dynamic count = _data.deviceCount;
    if (count is int) return count;
    return int.tryParse("$count") ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompact = MediaQuery.of(context).size.width < 900;
    final bool showActions = _hovered || isCompact;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        margin: const EdgeInsets.only(bottom: AppTokens.gapSm),
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: BoxDecoration(
          color: AppTokens.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          border: Border.all(
              color: _hovered
                  ? AppTokens.inkFaint.withValues(alpha: .5)
                  : AppTokens.hairline),
          boxShadow: AppTokens.cardShadow,
        ),
        child: isCompact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _identity(),
                  const SizedBox(height: 10),
                  _deviceChip(),
                  const SizedBox(height: 6),
                  Align(
                      alignment: Alignment.centerRight,
                      child: _actions(showActions)),
                ],
              )
            : Row(
                children: [
                  Expanded(child: _identity()),
                  const SizedBox(width: AppTokens.gapMd),
                  _deviceChip(),
                  const SizedBox(width: AppTokens.gapSm),
                  _actions(showActions),
                ],
              ),
      ),
    );
  }

  Widget _identity() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _avatar(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableLabel(
                _value(_data.studentName, "Unnamed student"),
                style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppTokens.ink),
              ),
              const SizedBox(height: 4),
              // Phone and email on one line. These were two labelled boxes
              // taking a row each.
              Wrap(
                spacing: 14,
                runSpacing: 3,
                children: [
                  _fact(Icons.phone_outlined,
                      _value(_data.studentPhoneNumber, "No phone")),
                  _fact(Icons.mail_outline,
                      _value(_data.studentEmail, "No email")),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _value(String value, String fallback) =>
      value.trim().isEmpty || value == stringDefault ? fallback : value;

  Widget _fact(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppTokens.inkFaint),
        const SizedBox(width: 5),
        // Capped: a Wrap only wraps *between* children, so one over-wide
        // child still overflows the row it lands on.
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: SelectableLabel(label,
              style:
                  const TextStyle(fontSize: 11.5, color: AppTokens.inkMuted)),
        ),
      ],
    );
  }

  Widget _avatar() {
    final String url = _data.studentProfileImage;
    final String initial = _value(_data.studentName, "?").characters.first;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      child: SizedBox(
        height: 40,
        width: 40,
        child: url.trim().isEmpty || url == stringDefault
            ? _initialAvatar(initial)
            : Image.network(url,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => _initialAvatar(initial)),
      ),
    );
  }

  Widget _initialAvatar(String initial) => Container(
        color: AppTokens.surfaceMuted,
        alignment: Alignment.center,
        child: Text(initial.toUpperCase(),
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTokens.inkFaint)),
      );

  /// How many devices the student is signed in on, and a way to sign them
  /// out. It used to be a bare logout icon with " - 3" beside it.
  Widget _deviceChip() {
    final int count = _deviceCount;
    final bool signedIn = count > 0;
    final Color color =
        signedIn ? const Color(0xFF2563EB) : AppTokens.inkFaint;

    return Tooltip(
      message: signedIn
          ? "Sign out of all $count device${count == 1 ? '' : 's'}"
          : "Not signed in on any device",
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        child: InkWell(
          key: Key('student_devices_${_data.studentId}'),
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          onTap: signedIn ? _confirmSignOut : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: signedIn
                  ? color.withValues(alpha: .10)
                  : AppTokens.surfaceMuted,
              borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              border: Border.all(
                  color: signedIn
                      ? color.withValues(alpha: .28)
                      : AppTokens.hairline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                    signedIn
                        ? Icons.devices_outlined
                        : Icons.phonelink_erase_outlined,
                    size: 12,
                    color: color),
                const SizedBox(width: 5),
                Text(
                    signedIn
                        ? "$count device${count == 1 ? '' : 's'}"
                        : "No devices",
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actions(bool visible) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 140),
      opacity: visible ? 1 : 0,
      child: IgnorePointer(
        ignoring: !visible,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _iconButton(
              key: Key('student_courses_${_data.studentId}'),
              icon: Icons.school_outlined,
              tooltip: "Enrolled courses",
              color: AppTokens.inkMuted,
              onTap: _openSettings,
            ),
            const SizedBox(width: 2),
            _iconButton(
              key: Key('student_delete_${_data.studentId}'),
              icon: Icons.delete_outline,
              tooltip: "Delete student",
              color: AppTokens.danger,
              onTap: _confirmDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconButton({
    required Key key,
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 17, color: color),
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingStudent(
          studentId: _data.studentId,
          studentName: _data.studentName,
        ),
      ),
    ).whenComplete(widget.onChanged);
  }

  void _confirmSignOut() {
    final StudentViewModel studentViewModel =
        Provider.of<StudentViewModel>(context, listen: false);
    final String studentId = _data.studentId;

    RemoveAlert.showRemoveAlert(
      title: _value(_data.studentName, "This student"),
      description: "Sign this student out of all devices ?",
      onPressYes: () async {
        Navigator.pop(navigatorKey.currentContext!);
        final bool success = await studentViewModel.clearDeviceCount(studentId);
        if (success) {
          Helper.showSnackBarMessage(
              msg: "Signed out of all devices", isSuccess: true);
        }
      },
    );
  }

  void _confirmDelete() {
    final StudentViewModel studentViewModel =
        Provider.of<StudentViewModel>(context, listen: false);
    // Captured up front: the delete used to run through
    // `FirebaseFirestore.instance` in this widget and then drop a row by
    // *list index*, so confirming after a search removed the wrong student.
    final String studentId = _data.studentId;

    RemoveAlert.showRemoveAlert(
      title: _value(_data.studentName, "This student"),
      description: "Are you sure want to delete ?",
      onPressYes: () async {
        Navigator.pop(navigatorKey.currentContext!);
        final bool success = await studentViewModel.deleteStudent(studentId);
        if (success) {
          Helper.showInfoMessage(msg: "Student deleted successfully");
        }
      },
    );
  }
}
