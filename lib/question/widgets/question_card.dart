import 'package:bbarna/core/widgets/remove_alert.dart';
import 'package:bbarna/question/model/question.dart';
import 'package:bbarna/question/model/question_draft.dart';
import 'package:bbarna/question/question_viewmodel/question_viewmodel.dart';
import 'package:bbarna/question/screen/edit_question.dart';
import 'package:bbarna/resources/app_tokens.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// One question row.
///
/// The old row rendered the question's stored HTML with `HtmlWidget`, so a
/// row was as tall as the question's formatting and a list of twenty was
/// unscannable. This shows the question as one line of plain text and says
/// the two things you actually want at a glance: whether all four options
/// are filled in, and which one is marked correct.
class QuestionCard extends StatefulWidget {
  final Question questionData;
  final VoidCallback onChanged;

  const QuestionCard(
      {required this.questionData, required this.onChanged, super.key});

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  bool _hovered = false;

  Question get _data => widget.questionData;

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
                  // whole intrinsic width and starves the question column.
                  Flexible(flex: 3, child: _chips()),
                  const SizedBox(width: AppTokens.gapSm),
                  _actions(showActions),
                ],
              ),
      ),
    );
  }

  Widget _identity() {
    final String text = QuestionDraft.plainText(_data.question);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: AppTokens.surfaceMuted,
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            border: Border.all(color: AppTokens.hairline),
          ),
          child: const Icon(Icons.help_outline,
              size: 17, color: AppTokens.inkMuted),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _data.questionCode.isEmpty ||
                        _data.questionCode == stringDefault
                    ? "No code"
                    : _data.questionCode,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: AppTokens.inkMuted),
              ),
              const SizedBox(height: 3),
              Text(
                text.isEmpty ? "No question text" : text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13.5,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color:
                        text.isEmpty ? AppTokens.danger : AppTokens.ink),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chips() {
    final QuestionOption? answer = QuestionDraft.answerOf(_data);
    final int filled = QuestionOption.values
        .where((option) => QuestionDraft.plainText(switch (option) {
              QuestionOption.a => _data.option1,
              QuestionOption.b => _data.option2,
              QuestionOption.c => _data.option3,
              QuestionOption.d => _data.option4,
            }).isNotEmpty)
        .length;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _chip(
          icon: filled == 4 ? Icons.checklist : Icons.warning_amber_outlined,
          label: filled == 4 ? "4 options" : "$filled of 4 options",
          color: filled == 4 ? AppTokens.inkMuted : const Color(0xFFB54708),
          filled: filled != 4,
        ),
        // A question with no answer marked is one no student can get right.
        // Nothing in the old row said so — and the old lookup would have
        // claimed option D was correct.
        _chip(
          icon: answer == null
              ? Icons.error_outline
              : Icons.check_circle_outline,
          label: answer == null ? "No answer set" : "Answer ${answer.label}",
          color: answer == null
              ? AppTokens.danger
              : const Color(0xFF108460),
          filled: true,
        ),
      ],
    );
  }

  Widget _chip({
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
              key: Key('question_edit_${_data.docId}'),
              icon: Icons.edit_outlined,
              tooltip: "Edit question",
              color: AppTokens.inkMuted,
              onTap: _openEdit,
            ),
            const SizedBox(width: 2),
            _iconButton(
              key: Key('question_delete_${_data.docId}'),
              icon: Icons.delete_outline,
              tooltip: "Delete question",
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
      MaterialPageRoute(
          builder: (context) => EditQuestion(questionData: _data)),
    ).whenComplete(widget.onChanged);
  }

  void _confirmDelete() {
    final QuestionViewModel questionViewModel =
        Provider.of<QuestionViewModel>(context, listen: false);
    // Captured up front: the delete used to be issued by list *index*, so
    // confirming after a refresh removed whichever row now sat there.
    final String docId = _data.docId;

    RemoveAlert.showRemoveAlert(
      title: _data.questionCode,
      description: "Are you sure want to delete ?",
      onPressYes: () async {
        Navigator.pop(navigatorKey.currentContext!);
        final bool success = await questionViewModel.deleteQuestion(docId);
        if (success) {
          Helper.showInfoMessage(msg: "Question deleted successfully");
        }
      },
    );
  }
}
