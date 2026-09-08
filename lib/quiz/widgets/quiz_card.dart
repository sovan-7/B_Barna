import 'package:bbarna/core/widgets/remove_alert.dart';
import 'package:bbarna/core/widgets/selectable_label.dart';
import 'package:bbarna/quiz/model/quiz_model.dart';
import 'package:bbarna/quiz/screen/edit_quiz.dart';
import 'package:bbarna/quiz/viewModel/quiz_view_model.dart';
import 'package:bbarna/resources/app_tokens.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// One quiz row.
///
/// The old row was a fixed 60px `Row` wrapped in a `FittedBox` below 900px,
/// which "fixed" overflow by shrinking every row, text and all, until it
/// fit. This row flexes and reflows, and it shows the numbers that actually
/// define a quiz — length, marks, question count — which the old row left
/// only in the edit form.
class QuizCard extends StatefulWidget {
  final QuizModel quizData;
  final VoidCallback onChanged;

  const QuizCard({required this.quizData, required this.onChanged, super.key});

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  bool _hovered = false;

  QuizModel get _data => widget.quizData;

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
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: AppTokens.surfaceMuted,
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            border: Border.all(color: AppTokens.hairline),
          ),
          child: const Icon(Icons.quiz_outlined,
              size: 19, color: AppTokens.inkMuted),
        ),
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
              const SizedBox(height: 5),
              // The shape of the quiz in one line. None of this was on the
              // old row.
              Wrap(
                spacing: 12,
                runSpacing: 3,
                children: [
                  _fact(Icons.timer_outlined, formatDuration(_data.totalTime)),
                  _fact(Icons.help_outline, _questionsLabel()),
                  _fact(Icons.star_outline, _marksLabel()),
                  if (_data.numberDeduction > 0)
                    _fact(Icons.remove_circle_outline,
                        "-${_data.numberDeduction} per wrong answer"),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// The stored count and the questions actually attached can disagree —
  /// the old form saved `total_question` as a number you typed by hand,
  /// with nothing tying it to the list. Say so when they differ.
  String _questionsLabel() {
    final int attached = _data.questionCodeList.length;
    final int stated = _data.totalQuestion;
    if (stated > 0 && stated != attached) {
      return "$attached attached (set to $stated)";
    }
    return "$attached question${attached == 1 ? '' : 's'}";
  }

  String _marksLabel() =>
      _data.totalMarks > 0 ? "${_data.totalMarks} marks" : "No marks set";

  Widget _fact(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppTokens.inkFaint),
        const SizedBox(width: 5),
        // Capped: a Wrap only wraps *between* children, so one over-wide
        // child still overflows the row it lands on.
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 190),
          child: Text(label,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 11.5, color: AppTokens.inkMuted)),
        ),
      ],
    );
  }

  Widget _codeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppTokens.surfaceMuted,
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        border: Border.all(color: AppTokens.hairline),
      ),
      child: SelectableLabel(_data.code,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: AppTokens.inkMuted)),
    );
  }

  Widget _chips() {
    final bool isFree = _data.type.toUpperCase() == "FREE";
    final Color typeColor =
        isFree ? const Color(0xFF108460) : const Color(0xFFB54708);

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _chip(
          icon: statusIcon(_data.status),
          label: _data.status.isEmpty || _data.status == stringDefault
              ? "No status"
              : _data.status.toUpperCase(),
          color: statusColor(_data.status),
        ),
        _chip(
          icon: isFree ? Icons.lock_open_outlined : Icons.paid_outlined,
          label: _data.type.isEmpty || _data.type == stringDefault
              ? "No type"
              : _data.type.toUpperCase(),
          color: typeColor,
        ),
      ],
    );
  }

  Widget _chip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        border: Border.all(color: color.withValues(alpha: .28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: color)),
        ],
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
              key: Key('quiz_edit_${_data.docId}'),
              icon: Icons.edit_outlined,
              tooltip: "Edit quiz",
              color: AppTokens.inkMuted,
              onTap: _openEdit,
            ),
            const SizedBox(width: 2),
            _iconButton(
              key: Key('quiz_delete_${_data.docId}'),
              icon: Icons.delete_outline,
              tooltip: "Delete quiz",
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
      MaterialPageRoute(builder: (context) => EditQuiz(quizData: _data)),
    ).whenComplete(widget.onChanged);
  }

  void _confirmDelete() {
    final QuizViewModel quizViewModel =
        Provider.of<QuizViewModel>(context, listen: false);
    final String docId = _data.docId;

    RemoveAlert.showRemoveAlert(
      title: _data.name,
      description: "Are you sure want to delete ?",
      onPressYes: () async {
        Navigator.pop(navigatorKey.currentContext!);
        final bool success = await quizViewModel.deleteQuiz(docId);
        if (success) {
          Helper.showInfoMessage(msg: "Quiz deleted successfully");
          widget.onChanged();
        }
      },
    );
  }
}

/// "1h 30m" from a whole number of minutes — the form collects hours and
/// minutes separately and stores their sum.
String formatDuration(int minutes) {
  if (minutes <= 0) return "No time limit";
  final int hours = minutes ~/ 60;
  final int rest = minutes % 60;
  if (hours == 0) return "${rest}m";
  if (rest == 0) return "${hours}h";
  return "${hours}h ${rest}m";
}

Color statusColor(String status) {
  switch (status.toUpperCase()) {
    case "LIVE":
      return const Color(0xFFE0393E);
    case "UPCOMING":
      return const Color(0xFF2563EB);
    case "PENDING":
      return const Color(0xFFB54708);
    default:
      return AppTokens.inkFaint;
  }
}

IconData statusIcon(String status) {
  switch (status.toUpperCase()) {
    case "LIVE":
      return Icons.sensors;
    case "UPCOMING":
      return Icons.event_outlined;
    case "PENDING":
      return Icons.hourglass_empty;
    default:
      return Icons.help_outline;
  }
}
