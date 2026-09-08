import 'package:bbarna/core/widgets/remove_alert.dart';
import 'package:bbarna/core/widgets/selectable_label.dart';
import 'package:bbarna/resources/app_tokens.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/subject/model/subject_model.dart';
import 'package:bbarna/subject/screen/edit_subject.dart';
import 'package:bbarna/subject/viewModel/subject_view_model.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// One subject row.
///
/// The old row was a fixed-height `Row` of two un-flexed `Row`s, so a long
/// subject name pushed the price and the buttons off the edge — and below
/// 900px the whole thing was wrapped in a `FittedBox`, which "fixed" that
/// by shrinking every row, text and all, until it fit. This row flexes and
/// reflows instead.
class SubjectCard extends StatefulWidget {
  final SubjectModel subjectData;

  /// Called after something changed, so the list can refresh.
  final VoidCallback onChanged;

  const SubjectCard(
      {required this.subjectData, required this.onChanged, super.key});

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard> {
  bool _hovered = false;

  SubjectModel get _data => widget.subjectData;

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
                  Row(
                    children: [
                      _price(),
                      const Spacer(),
                      _actions(showActions),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _chips(),
                ],
              )
            : Row(
                children: [
                  Expanded(flex: 5, child: _identity()),
                  const SizedBox(width: AppTokens.gapMd),
                  _price(),
                  const SizedBox(width: AppTokens.gapMd),
                  // Flexible, not bare: an unbounded Wrap here takes its
                  // whole intrinsic width and starves the name column.
                  // Bounded, it wraps onto a second line instead.
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
                    child: SelectableLabel(
                      _data.name,
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
              // Which course this sits under, and what kind it is — the
              // two things that tell one "Chapter 1" apart from another.
              Row(
                children: [
                  const Icon(Icons.menu_book_outlined,
                      size: 12, color: AppTokens.inkFaint),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      _data.courseName.isEmpty || _data.courseName == stringDefault
                          ? "No course"
                          : _data.courseName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppTokens.inkMuted),
                    ),
                  ),
                  if (_data.courseType.isNotEmpty &&
                      _data.courseType != stringDefault) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                          color: AppTokens.inkFaint, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(_data.courseType,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: AppTokens.inkMuted)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// A rounded square, cropped to fit. The old avatar was a 50px circle
  /// with `BoxFit.fill`, so every non-square subject image was squashed.
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
      child: SelectableLabel(
        _data.code,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: AppTokens.inkMuted),
      ),
    );
  }

  /// What a student actually pays, with the list price struck through and
  /// the saving named when there is one. The card used to show only
  /// `subject_price` — so a discounted subject displayed the number nobody
  /// is charged, and `selling_price` appeared nowhere in the module at all.
  Widget _price() {
    final double list = _data.price;
    final double selling = _data.sellingPrice;
    final bool discounted = selling > 0 && list > selling;
    final double headline = selling > 0 ? selling : list;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _money(headline),
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTokens.ink),
        ),
        if (discounted) ...[
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _money(list),
                style: const TextStyle(
                    fontSize: 11.5,
                    color: AppTokens.inkFaint,
                    decoration: TextDecoration.lineThrough),
              ),
              const SizedBox(width: 5),
              // Was "-25%", which reads as a negative discount. The value
              // is always positive here (the discounted guard above needs
              // list > selling > 0), so the minus was pure presentation.
              Text(
                "${(((list - selling) / list) * 100).round()}% OFF",
                style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF108460)),
              ),
            ],
          ),
        ],
      ],
    );
  }

  static String _money(double value) => "₹${value.toStringAsFixed(2)}";

  Widget _chips() {
    final Widget? coupon = _couponChip();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (coupon != null) coupon,
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
          color:
              _data.willDisplay ? const Color(0xFF108460) : AppTokens.inkFaint,
          filled: _data.willDisplay,
        ),
        _toggleChip(
          key: Key('subject_popular_${_data.docId}'),
          icon: _data.isPopular ? Icons.star : Icons.star_border,
          label: "Popular",
          on: _data.isPopular,
          onColor: const Color(0xFFB54708),
          tooltip: _data.isPopular
              ? "Remove from popular"
              : "Mark as popular",
          onTap: () => Provider.of<SubjectViewModel>(context, listen: false)
              .togglePopular(_data),
        ),
        _toggleChip(
          key: Key('subject_lock_${_data.docId}'),
          icon: _data.isLocked
              ? Icons.lock_outline_rounded
              : Icons.lock_open_outlined,
          label: _data.isLocked ? "Locked" : "Unlocked",
          on: _data.isLocked,
          onColor: const Color(0xFFB54708),
          tooltip: _data.isLocked ? "Unlock this subject" : "Lock this subject",
          onTap: () => Provider.of<SubjectViewModel>(context, listen: false)
              .toggleLocked(_data),
        ),
      ],
    );
  }

  /// The coupon live on this subject, or null when there isn't one.
  ///
  /// Coupons are written outside this panel and were invisible here, so an
  /// admin had no way to tell which subjects were discounted or whether a
  /// code had already expired. The code itself is selectable, because
  /// copying it into a message or a test checkout is the whole reason to
  /// look at it.
  Widget? _couponChip() {
    final String code = _data.couponCode.trim();
    if (code.isEmpty || code == stringDefault) return null;

    final bool expired = _data.couponValidTill > 0 &&
        _data.couponValidTill < DateTime.now().millisecondsSinceEpoch;
    final Color color =
        expired ? AppTokens.inkFaint : const Color(0xFFB54708);
    // A flat rupee amount off the selling price, not a percentage — that is
    // how the student app applies it at checkout.
    final double off = _data.couponDiscount;

    return Tooltip(
      message: expired
          ? "Coupon expired on ${_date(_data.couponValidTill)}"
          : _data.couponValidTill > 0
              ? "Valid until ${_date(_data.couponValidTill)}"
              : "No expiry set",
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: expired
              ? AppTokens.surfaceMuted
              : color.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          border: Border.all(
              color: expired
                  ? AppTokens.hairline
                  : color.withValues(alpha: .28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_offer_outlined, size: 12, color: color),
            const SizedBox(width: 5),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: SelectableLabel(
                code,
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: color),
              ),
            ),
            if (off > 0)
              Text(" · ₹${off.toStringAsFixed(0)} off",
                  style: TextStyle(fontSize: 11.5, color: color)),
            if (expired)
              Text(" · expired",
                  style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: color)),
          ],
        ),
      ),
    );
  }

  static String _date(int millis) {
    final DateTime d = DateTime.fromMillisecondsSinceEpoch(millis);
    const List<String> months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
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

  /// A chip that is also a control. Popular used to be a bare heart icon
  /// and lock a bare padlock — neither said what it meant or what tapping
  /// it would do.
  Widget _toggleChip({
    required Key key,
    required IconData icon,
    required String label,
    required bool on,
    required Color onColor,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    final Color color = on ? onColor : AppTokens.inkFaint;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        child: InkWell(
          key: key,
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  on ? color.withValues(alpha: .10) : AppTokens.surfaceMuted,
              borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              border: Border.all(
                  color: on
                      ? color.withValues(alpha: .28)
                      : AppTokens.hairline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 5),
                Text(label,
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
              key: Key('subject_edit_${_data.docId}'),
              icon: Icons.edit_outlined,
              tooltip: "Edit subject",
              color: AppTokens.inkMuted,
              onTap: _openEdit,
            ),
            const SizedBox(width: 2),
            _iconButton(
              key: Key('subject_delete_${_data.docId}'),
              icon: Icons.delete_outline,
              tooltip: "Delete subject",
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
      MaterialPageRoute(builder: (context) => EditSubject(subjectData: _data)),
    ).whenComplete(widget.onChanged);
  }

  void _confirmDelete() {
    final SubjectViewModel subjectViewModel =
        Provider.of<SubjectViewModel>(context, listen: false);
    final String docId = _data.docId;

    RemoveAlert.showRemoveAlert(
      title: _data.name,
      description: "Are you sure want to delete ?",
      onPressYes: () async {
        // RemoveAlert never closes itself, and it is dismissed before the
        // delete so there is no second route in flight for the refresh to
        // race with.
        Navigator.pop(navigatorKey.currentContext!);
        final bool success = await subjectViewModel.deleteSubject(docId);
        if (success) {
          Helper.showInfoMessage(msg: "Subject deleted successfully");
          await subjectViewModel.getSubjectList();
        }
      },
    );
  }
}
