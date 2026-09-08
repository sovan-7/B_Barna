import 'package:bbarna/core/widgets/remove_alert.dart';
import 'package:bbarna/resources/app_tokens.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/units/model/unit_model.dart';
import 'package:bbarna/units/screen/edit_unit.dart';
import 'package:bbarna/units/viewModel/unit_view_model.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// One unit row.
///
/// The old row was a fixed 110px `Row` of two un-flexed `Row`s, so a long
/// unit name pushed the buttons off the edge — and below 900px the whole
/// thing was wrapped in a `FittedBox`, which "fixed" that by shrinking
/// every row, text and all, until it fit. This row flexes and reflows.
class UnitCard extends StatefulWidget {
  final UnitModel unitData;

  /// Called after something changed, so the list can refresh.
  final VoidCallback onChanged;

  const UnitCard({required this.unitData, required this.onChanged, super.key});

  @override
  State<UnitCard> createState() => _UnitCardState();
}

class _UnitCardState extends State<UnitCard> {
  bool _hovered = false;

  UnitModel get _data => widget.unitData;

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
                      child: _actions(showActions)),
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
              const SizedBox(height: 4),
              // Where the unit sits: course, then subject. Two labelled
              // blue boxes reading "Subject Name:" used to take a whole
              // line each for what is really one breadcrumb.
              Row(
                children: [
                  const Icon(Icons.account_tree_outlined,
                      size: 12, color: AppTokens.inkFaint),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      _breadcrumb(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppTokens.inkMuted),
                    ),
                  ),
                ],
              ),
              if (_data.subjectCodeList.length > 1) ...[
                const SizedBox(height: 4),
                Text(
                  // A unit can be shared across several subjects; nothing
                  // in the old row said so.
                  "Also in ${_data.subjectCodeList.length - 1} more subject"
                  "${_data.subjectCodeList.length - 1 == 1 ? '' : 's'}",
                  style: const TextStyle(
                      fontSize: 11.5, color: AppTokens.inkFaint),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _breadcrumb() {
    final String course =
        _data.courseName.isEmpty || _data.courseName == stringDefault
            ? "No course"
            : _data.courseName;
    final String subject =
        _data.subjectName.isEmpty || _data.subjectName == stringDefault
            ? "No subject"
            : _data.subjectName;
    return "$course  ›  $subject";
  }

  /// A rounded square, cropped to fit. The old thumbnail was 80px with
  /// `BoxFit.fill`, so every non-square unit image was squashed — and its
  /// fallback rendered at 60px, so a broken image also changed the row's
  /// layout.
  Widget _thumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      child: SizedBox(
        height: 46,
        width: 46,
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
        // The old row rendered `const ActiveButton()` with no argument, so
        // every unit showed a green "ACTIVE" badge whether it was visible
        // or not. This reads the flag.
        _statusChip(
          icon: _data.willShow
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          label: _data.willShow ? "Visible" : "Hidden",
          color: _data.willShow ? const Color(0xFF108460) : AppTokens.inkFaint,
          filled: _data.willShow,
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
    final bool locked = _data.lockStatus;
    final Color color = locked ? const Color(0xFFB54708) : AppTokens.inkFaint;

    return Tooltip(
      message: locked ? "Unlock this unit" : "Lock this unit",
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        child: InkWell(
          key: Key('unit_lock_${_data.id}'),
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          onTap: () => Provider.of<UnitViewModel>(context, listen: false)
              .toggleLocked(_data),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  locked ? color.withValues(alpha: .10) : AppTokens.surfaceMuted,
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
              key: Key('unit_edit_${_data.id}'),
              icon: Icons.edit_outlined,
              tooltip: "Edit unit",
              color: AppTokens.inkMuted,
              onTap: _openEdit,
            ),
            const SizedBox(width: 2),
            _iconButton(
              key: Key('unit_delete_${_data.id}'),
              icon: Icons.delete_outline,
              tooltip: "Delete unit",
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

  void _openEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditUnit(unitData: _data)),
    ).whenComplete(widget.onChanged);
  }

  void _confirmDelete() {
    final UnitViewModel unitViewModel =
        Provider.of<UnitViewModel>(context, listen: false);
    final String docId = _data.id;

    RemoveAlert.showRemoveAlert(
      title: _data.name,
      description: "Are you sure want to delete ?",
      onPressYes: () async {
        // RemoveAlert never closes itself, and it is dismissed before the
        // delete so there is no second route in flight for the refresh to
        // race with.
        Navigator.pop(navigatorKey.currentContext!);
        final bool success = await unitViewModel.deleteUnit(docId);
        if (success) {
          Helper.showInfoMessage(msg: "Unit deleted successfully");
          widget.onChanged();
        }
      },
    );
  }
}
