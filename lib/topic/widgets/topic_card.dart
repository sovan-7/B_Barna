import 'package:bbarna/core/widgets/remove_alert.dart';
import 'package:bbarna/resources/app_tokens.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/topic/model/topic_model.dart';
import 'package:bbarna/topic/screen/edit_topic.dart';
import 'package:bbarna/topic/screen/topic_details.dart';
import 'package:bbarna/topic/viewModel/topic_view_model.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// One topic row.
///
/// The old row was three stacked `Row`s of coloured "Course Name:" /
/// "Subject Name:" / "Unit Name:" boxes beside a fixed-width strip of four
/// counters and five icons, none of it flexed — a long topic name pushed
/// the buttons off the edge, and below 900px the list wrapped the whole
/// thing in a `FittedBox`, which "fixed" that by shrinking every row, text
/// and all, until it fit. This row flexes and reflows.
class TopicCard extends StatefulWidget {
  final TopicModel topicData;

  /// Called after something changed, so the list can refresh.
  final VoidCallback onChanged;

  const TopicCard({required this.topicData, required this.onChanged, super.key});

  @override
  State<TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<TopicCard> {
  bool _hovered = false;

  TopicModel get _data => widget.topicData;

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
        _priorityBadge(),
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
              // Where the topic sits: course, then subject, then unit.
              // Three labelled boxes reading "Course Name:", "Subject
              // Name:" and "   Unit Name:   " used to take a whole line
              // each for what is really one breadcrumb.
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
              if (_data.unitCodeList.length > 1) ...[
                const SizedBox(height: 4),
                Text(
                  // A topic can be shared across several units; nothing in
                  // the old row said so.
                  "Also in ${_data.unitCodeList.length - 1} more unit"
                  "${_data.unitCodeList.length - 1 == 1 ? '' : 's'}",
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
    String or(String value, String fallback) =>
        value.isEmpty || value == stringDefault ? fallback : value;
    return "${or(_data.courseName, 'No course')}"
        "  ›  ${or(_data.subjectName, 'No subject')}"
        "  ›  ${or(_data.unitName, 'No unit')}";
  }

  /// Display priority, read at a glance. It used to be a `PriorityButton`
  /// crammed into the same row as the code chip and five icons.
  Widget _priorityBadge() {
    return Container(
      height: 46,
      width: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTokens.surfaceMuted,
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        border: Border.all(color: AppTokens.hairline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("P",
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppTokens.inkFaint)),
          Text("${_data.displayPriority}",
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTokens.inkMuted)),
        ],
      ),
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

  /// What is attached. The old strip printed all four counters at a fixed
  /// 80px each whether they were zero or not, so a topic with nothing on
  /// it looked exactly as busy as a full one. Empty kinds are dropped, and
  /// a topic with nothing attached says so instead.
  Widget _chips() {
    final List<Widget> chips = <Widget>[];
    for (final ContentKind kind in ContentKind.values) {
      final int count = _data.contentCodes(kind).length;
      if (count == 0) continue;
      chips.add(_countChip(kind, count));
    }

    if (chips.isEmpty) {
      return Wrap(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTokens.surfaceMuted,
              borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              border: Border.all(color: AppTokens.hairline),
            ),
            child: const Text("No content yet",
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppTokens.inkFaint)),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: chips,
    );
  }

  static const Map<ContentKind, IconData> _kindIcons = {
    ContentKind.video: Icons.play_circle_outline,
    ContentKind.audio: Icons.graphic_eq,
    ContentKind.pdf: Icons.picture_as_pdf_outlined,
    ContentKind.quiz: Icons.quiz_outlined,
  };

  Widget _countChip(ContentKind kind, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTokens.surfaceMuted,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        border: Border.all(color: AppTokens.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_kindIcons[kind], size: 12, color: AppTokens.inkMuted),
          const SizedBox(width: 5),
          Text("${kind.label} $count",
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppTokens.inkMuted)),
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
              key: Key('topic_content_${_data.docId}'),
              // A bare `+` used to open this. Nothing said it led to the
              // videos, audio, PDFs and quizzes on the topic.
              icon: Icons.playlist_add,
              tooltip: "Manage content",
              color: AppTokens.inkMuted,
              onTap: _openContent,
            ),
            const SizedBox(width: 2),
            _iconButton(
              key: Key('topic_edit_${_data.docId}'),
              icon: Icons.edit_outlined,
              tooltip: "Edit topic",
              color: AppTokens.inkMuted,
              onTap: _openEdit,
            ),
            const SizedBox(width: 2),
            _iconButton(
              key: Key('topic_delete_${_data.docId}'),
              icon: Icons.delete_outline,
              tooltip: "Delete topic",
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

  void _openContent() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TopicDetails(topicData: _data)),
    ).whenComplete(widget.onChanged);
  }

  void _openEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTopic(topicData: _data)),
    ).whenComplete(widget.onChanged);
  }

  void _confirmDelete() {
    final TopicViewModel topicViewModel =
        Provider.of<TopicViewModel>(context, listen: false);
    final String docId = _data.docId;

    RemoveAlert.showRemoveAlert(
      title: _data.name,
      description: "Are you sure want to delete ?",
      onPressYes: () async {
        // RemoveAlert never closes itself, and it is dismissed before the
        // delete so there is no second route in flight for the refresh to
        // race with. The old handler popped twice afterwards, which took
        // the alert *and* whatever was under it off the navigator.
        Navigator.pop(navigatorKey.currentContext!);
        final bool success = await topicViewModel.deleteTopic(docId);
        if (success) {
          Helper.showSnackBarMessage(
              msg: "Topic deleted successfully", isSuccess: false);
          widget.onChanged();
        }
      },
    );
  }
}
