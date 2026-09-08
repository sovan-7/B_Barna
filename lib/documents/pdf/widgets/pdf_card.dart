import 'package:bbarna/core/widgets/remove_alert.dart';
import 'package:bbarna/documents/pdf/model/pdf_model.dart';
import 'package:bbarna/documents/pdf/screen/edit_pdf.dart';
import 'package:bbarna/documents/pdf/viewModel/pdf_view_model.dart';
import 'package:bbarna/resources/app_tokens.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// One PDF row.
///
/// The old row was a `Row` of un-flexed `Row`s wrapped in a `FittedBox`
/// below 900px, which "fixed" overflow by shrinking every row, text and
/// all, until it fit. This row flexes and reflows.
class PdfCard extends StatefulWidget {
  final PdfModel pdfData;
  final VoidCallback onChanged;

  const PdfCard({required this.pdfData, required this.onChanged, super.key});

  @override
  State<PdfCard> createState() => _PdfCardState();
}

class _PdfCardState extends State<PdfCard> {
  bool _hovered = false;

  PdfModel get _data => widget.pdfData;

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
                  // whole intrinsic width and starves the title column.
                  Flexible(flex: 4, child: _chips()),
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
    final bool hasFile =
        _data.pdfLink.trim().isNotEmpty && _data.pdfLink != stringDefault;

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
          child: Icon(Icons.picture_as_pdf_outlined,
              size: 20,
              color: hasFile ? const Color(0xFFD92D20) : AppTokens.inkFaint),
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
              // The title itself used to be the link — blue text with no
              // affordance, and nothing at all when the file was missing.
              if (hasFile)
                Row(
                  children: [
                    const Icon(Icons.attach_file,
                        size: 13, color: AppTokens.inkFaint),
                    const SizedBox(width: 5),
                    InkWell(
                      key: Key('pdf_open_${_data.docId}'),
                      onTap: () => _open(_data.pdfLink),
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text("Open the file",
                                style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2563EB))),
                            SizedBox(width: 4),
                            Icon(Icons.open_in_new,
                                size: 12, color: Color(0xFF2563EB)),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              else
                const Text("No file uploaded",
                    style:
                        TextStyle(fontSize: 11.5, color: AppTokens.danger)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _open(String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null || !await launchUrl(uri)) {
      Helper.showSnackBarMessage(
          msg: "Could not open that file", isSuccess: false);
    }
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

  Widget _chips() {
    final bool isFree = _data.pdfType.toUpperCase() == "FREE";
    final Color typeColor =
        isFree ? const Color(0xFF108460) : const Color(0xFFB54708);

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _statusChip(
          icon: isFree ? Icons.lock_open_outlined : Icons.paid_outlined,
          label: _data.pdfType.isEmpty || _data.pdfType == stringDefault
              ? "No type"
              : _data.pdfType.toUpperCase(),
          color: typeColor,
          filled: true,
        ),
        _toggleChip(
          key: Key('pdf_downloadable_${_data.docId}'),
          icon: _data.isDownloadable
              ? Icons.download_outlined
              : Icons.visibility_outlined,
          label: _data.isDownloadable ? "Downloadable" : "View only",
          on: _data.isDownloadable,
          onColor: const Color(0xFF2563EB),
          tooltip: _data.isDownloadable
              ? "Make it view-only"
              : "Allow downloads",
          onTap: () => Provider.of<PdfViewModel>(context, listen: false)
              .toggleDownloadable(_data),
        ),
        _toggleChip(
          key: Key('pdf_lock_${_data.docId}'),
          icon: _data.isLocked
              ? Icons.lock_outline_rounded
              : Icons.lock_open_outlined,
          label: _data.isLocked ? "Locked" : "Unlocked",
          on: _data.isLocked,
          onColor: const Color(0xFFB54708),
          tooltip: _data.isLocked ? "Unlock this PDF" : "Lock this PDF",
          onTap: () => Provider.of<PdfViewModel>(context, listen: false)
              .toggleLocked(_data),
        ),
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

  /// A chip that is also a control, so the two flags say what they mean and
  /// what tapping them will do. They were a bare padlock and nothing at all.
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
              color: on ? color.withValues(alpha: .10) : AppTokens.surfaceMuted,
              borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              border: Border.all(
                  color:
                      on ? color.withValues(alpha: .28) : AppTokens.hairline),
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
              key: Key('pdf_edit_${_data.docId}'),
              icon: Icons.edit_outlined,
              tooltip: "Edit PDF",
              color: AppTokens.inkMuted,
              onTap: _openEdit,
            ),
            const SizedBox(width: 2),
            _iconButton(
              key: Key('pdf_delete_${_data.docId}'),
              icon: Icons.delete_outline,
              tooltip: "Delete PDF",
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
      MaterialPageRoute(builder: (context) => EditPdf(pdfData: _data)),
    ).whenComplete(widget.onChanged);
  }

  void _confirmDelete() {
    final PdfViewModel pdfViewModel =
        Provider.of<PdfViewModel>(context, listen: false);
    final String docId = _data.docId;

    RemoveAlert.showRemoveAlert(
      title: _data.title,
      description: "Are you sure want to delete ?",
      onPressYes: () async {
        Navigator.pop(navigatorKey.currentContext!);
        final bool success = await pdfViewModel.deletePdf(docId);
        if (success) {
          Helper.showSnackBarMessage(
              msg: "PDF deleted successfully", isSuccess: false);
          widget.onChanged();
        }
      },
    );
  }
}
