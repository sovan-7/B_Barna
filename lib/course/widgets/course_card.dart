import 'package:bbarna/core/widgets/remove_alert.dart';
import 'package:bbarna/course/model/course_model.dart';
import 'package:bbarna/course/screen/edit_course.dart';
import 'package:bbarna/course/viewModel/course_view_model.dart';
import 'package:bbarna/resources/app_tokens.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// One course row.
///
/// The old row was a `Row` of two un-flexed `Row`s, so a long course name
/// pushed the buttons straight off the edge — and below 900px the whole
/// thing was wrapped in a `FittedBox`, which "fixed" the overflow by
/// shrinking every row, text and all, until it fit. This row flexes
/// properly and reflows instead.
class CourseCard extends StatefulWidget {
  final CourseModel courseData;

  /// Called after something changed, so the list can refresh.
  final VoidCallback onChanged;

  const CourseCard(
      {required this.courseData, required this.onChanged, super.key});

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool _hovered = false;

  CourseModel get _data => widget.courseData;

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
                  _chips(),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _actions(showActions),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(flex: 5, child: _identity()),
                  const SizedBox(width: AppTokens.gapMd),
                  // Flexible, not bare: an unbounded Wrap here takes its
                  // whole intrinsic width and starves the name column.
                  Flexible(flex: 4, child: _chips()),
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
        _thumbnail(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      _data.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: AppTokens.ink),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _codeChip(),
                ],
              ),
              if (_data.description.trim().isNotEmpty &&
                  _data.description != stringDefault) ...[
                const SizedBox(height: 4),
                Text(
                  _data.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTokens.body,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// A rounded square, cropped to fit. The old avatar was a 40px circle
  /// with `BoxFit.fill`, so every non-square course image was squashed.
  Widget _thumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      child: SizedBox(
        height: 42,
        width: 42,
        child: _data.image.trim().isEmpty
            ? _fallback()
            : Image.network(
                _data.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => _fallback(),
              ),
      ),
    );
  }

  Widget _fallback() => Container(
        color: AppTokens.surfaceMuted,
        alignment: Alignment.center,
        child: Text(
          _data.code.isEmpty ? "?" : _data.code.characters.first.toUpperCase(),
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTokens.inkFaint),
        ),
      );

  Widget _codeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppTokens.surfaceMuted,
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        border: Border.all(color: AppTokens.hairline),
      ),
      child: Text(
        _data.code,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: AppTokens.inkMuted),
      ),
    );
  }

  /// Priority, visibility and lock as one consistent set of status chips,
  /// rather than a yellow box, a coloured pill and a bare red padlock.
  Widget _chips() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _statusChip(
          icon: Icons.low_priority,
          label: "Priority ${_data.displayPriority}",
          color: AppTokens.inkMuted,
        ),
        _statusChip(
          icon: _data.willDisplay
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          label: _data.willDisplay ? "Visible" : "Hidden",
          color: _data.willDisplay
              ? const Color(0xFF108460)
              : AppTokens.inkFaint,
          filled: true,
        ),
        _lockChip(),
      ],
    );
  }

  Widget _statusChip({
    required IconData icon,
    required String label,
    required Color color,
    bool filled = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: .10) : AppTokens.surfaceMuted,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        border: Border.all(
            color: filled ? color.withValues(alpha: .28) : AppTokens.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 11.5, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  /// The lock is a control, not a label — it stays a chip so it lines up
  /// with the other two, but it is tappable and says what it will do.
  Widget _lockChip() {
    final bool locked = _data.isLocked;
    final Color color =
        locked ? const Color(0xFFB54708) : AppTokens.inkFaint;

    return Tooltip(
      message: locked ? "Unlock this course" : "Lock this course",
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        child: InkWell(
          key: Key('course_lock_${_data.docId}'),
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          onTap: () => Provider.of<CourseViewModel>(context, listen: false)
              .toggleLocked(_data),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: locked
                  ? color.withValues(alpha: .10)
                  : AppTokens.surfaceMuted,
              borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              border: Border.all(
                  color: locked
                      ? color.withValues(alpha: .28)
                      : AppTokens.hairline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                    locked
                        ? Icons.lock_outline_rounded
                        : Icons.lock_open_outlined,
                    size: 12,
                    color: color),
                const SizedBox(width: 5),
                Text(locked ? "Locked" : "Unlocked",
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
              key: Key('course_edit_${_data.docId}'),
              icon: Icons.edit_outlined,
              tooltip: "Edit course",
              color: AppTokens.inkMuted,
              onTap: _openEdit,
            ),
            const SizedBox(width: 2),
            _iconButton(
              key: Key('course_delete_${_data.docId}'),
              icon: Icons.delete_outline,
              tooltip: "Delete course",
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

  /// Refreshes when the edit page comes *back*. It used to refresh on the
  /// way out — before anything could have changed.
  void _openEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditCourse(courseData: _data)),
    ).whenComplete(widget.onChanged);
  }

  void _confirmDelete() {
    final CourseViewModel courseViewModel =
        Provider.of<CourseViewModel>(context, listen: false);
    final String docId = _data.docId;

    RemoveAlert.showRemoveAlert(
      title: _data.name,
      description: "Are you sure want to delete ?",
      onPressYes: () async {
        // RemoveAlert never closes itself, and it is dismissed before the
        // delete so there is no second route in flight for the refresh to
        // race with.
        Navigator.pop(navigatorKey.currentContext!);
        final bool success = await courseViewModel.deleteCourse(docId);
        if (success) {
          Helper.showSnackBarMessage(
              msg: "Course deleted successfully", isSuccess: false);
          await courseViewModel.getCourseList();
        }
      },
    );
  }
}
