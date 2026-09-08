import 'package:bbarna/core/widgets/remove_alert.dart';
import 'package:bbarna/documents/video/model/video_model.dart';
import 'package:bbarna/documents/video/screen/edit_video.dart';
import 'package:bbarna/documents/video/viewModel/video_view_model.dart';
import 'package:bbarna/resources/app_tokens.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// One video row.
///
/// The old row was a `Row` of un-flexed `Row`s wrapped in a `FittedBox`
/// below 900px, which "fixed" overflow by shrinking every row, text and
/// all, until it fit. This row flexes and reflows.
class VideoCard extends StatefulWidget {
  final VideoModel videoData;
  final VoidCallback onChanged;

  const VideoCard(
      {required this.videoData, required this.onChanged, super.key});

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  bool _hovered = false;

  VideoModel get _data => widget.videoData;

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
                  Row(children: [
                    _typeChip(),
                    const Spacer(),
                    _actions(showActions),
                  ]),
                ],
              )
            : Row(
                children: [
                  Expanded(child: _identity()),
                  const SizedBox(width: AppTokens.gapMd),
                  _typeChip(),
                  const SizedBox(width: AppTokens.gapSm),
                  _actions(showActions),
                ],
              ),
      ),
    );
  }

  Widget _identity() {
    final bool hasDescription = _data.description.trim().isNotEmpty &&
        _data.description != stringDefault;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // A play glyph rather than a thumbnail: these are links, and there
        // is no stored image to show.
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: AppTokens.surfaceMuted,
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            border: Border.all(color: AppTokens.hairline),
          ),
          child: const Icon(Icons.play_circle_outline,
              size: 20, color: Color(0xFFE0393E)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      _data.title,
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
              if (hasDescription) ...[
                const SizedBox(height: 4),
                Text(_data.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTokens.body),
              ],
              const SizedBox(height: 6),
              _linkRow(),
            ],
          ),
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
      child: Text(_data.code,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: AppTokens.inkMuted)),
    );
  }

  /// The link, trimmed of its scheme, and openable. The old row showed the
  /// raw URL as plain grey text with no way to check it.
  Widget _linkRow() {
    final String link = _data.link.trim();
    if (link.isEmpty || link == stringDefault) {
      return const Text("No link set",
          style: TextStyle(fontSize: 11.5, color: AppTokens.danger));
    }

    return Row(
      children: [
        const Icon(Icons.link, size: 13, color: AppTokens.inkFaint),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            link
                .replaceFirst(RegExp(r'^https?://'), '')
                .replaceFirst(RegExp(r'^www\.'), ''),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11.5, color: AppTokens.inkMuted),
          ),
        ),
        const SizedBox(width: 6),
        Tooltip(
          message: "Open the video",
          child: InkWell(
            key: Key('video_open_${_data.docId}'),
            onTap: () => _open(link),
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(Icons.open_in_new,
                  size: 13, color: AppTokens.inkFaint),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _open(String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null || !await launchUrl(uri)) {
      Helper.showSnackBarMessage(
          msg: "Could not open that link", isSuccess: false);
    }
  }

  /// FREE / PAID. It used to be an unlabelled coloured box.
  Widget _typeChip() {
    final bool isFree = _data.videoType.toUpperCase() == "FREE";
    final Color color =
        isFree ? const Color(0xFF108460) : const Color(0xFFB54708);
    final String label = _data.videoType.isEmpty ||
            _data.videoType == stringDefault
        ? "No type"
        : _data.videoType.toUpperCase();

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
          Icon(isFree ? Icons.lock_open_outlined : Icons.paid_outlined,
              size: 12, color: color),
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
              key: Key('video_edit_${_data.docId}'),
              icon: Icons.edit_outlined,
              tooltip: "Edit video",
              color: AppTokens.inkMuted,
              onTap: _openEdit,
            ),
            const SizedBox(width: 2),
            _iconButton(
              key: Key('video_delete_${_data.docId}'),
              icon: Icons.delete_outline,
              tooltip: "Delete video",
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
      MaterialPageRoute(builder: (context) => EditVideo(videoData: _data)),
    ).whenComplete(widget.onChanged);
  }

  void _confirmDelete() {
    final VideoViewModel videoViewModel =
        Provider.of<VideoViewModel>(context, listen: false);
    final String docId = _data.docId;

    RemoveAlert.showRemoveAlert(
      title: _data.title,
      description: "Are you sure want to delete ?",
      onPressYes: () async {
        Navigator.pop(navigatorKey.currentContext!);
        final bool success = await videoViewModel.deleteVideo(docId);
        if (success) {
          Helper.showInfoMessage(msg: "Video deleted successfully");
          widget.onChanged();
        }
      },
    );
  }
}
