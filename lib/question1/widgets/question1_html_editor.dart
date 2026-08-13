import 'dart:async';

import 'package:bbarna/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

/// Rich-text field used across Add/Edit Question1, with the ability to drop
/// OS-level plain text (e.g. text highlighted in a browser tab or another
/// app) directly onto the field to insert it.
///
/// The [DropRegion] wraps ONLY the "Drag text here" label strip, not the
/// `HtmlEditor` itself. The editor body is a contenteditable element (inside
/// a same-origin `<iframe>` on web), and browsers already handle text drops
/// onto contenteditable natively — wrapping the editor too made both the
/// native handler AND this widget's [DropRegion] insert the text, doubling
/// it. Keeping the drop target off the editor avoids that double-insert;
/// dropping directly onto the editor body still works via the browser's own
/// native contenteditable handling.
class Question1HtmlEditor extends StatefulWidget {
  const Question1HtmlEditor({
    required this.controller,
    required this.heading,
    required this.onContentChanged,
    required this.onEditorInit,
    super.key,
  });

  final HtmlEditorController controller;
  final String heading;
  final ValueChanged<String?> onContentChanged;
  final VoidCallback onEditorInit;

  @override
  State<Question1HtmlEditor> createState() => _Question1HtmlEditorState();
}

class _Question1HtmlEditorState extends State<Question1HtmlEditor> {
  bool _isDragOver = false;

  FutureOr<DropOperation> _handleDropOver(DropOverEvent event) {
    final accepted =
        event.session.items.any((item) => item.canProvide(Formats.plainText));
    if (mounted) setState(() => _isDragOver = accepted);
    return accepted ? DropOperation.copy : DropOperation.none;
  }

  void _handleDropLeave(DropEvent event) {
    if (mounted) setState(() => _isDragOver = false);
  }

  Future<void> _handlePerformDrop(PerformDropEvent event) async {
    final items = event.session.items;
    if (items.isNotEmpty) {
      final reader = items.first.dataReader;
      reader?.getValue(Formats.plainText, (value) {
        if (value != null && value.isNotEmpty) {
          widget.controller.insertText(value);
        }
      });
    }
    if (mounted) setState(() => _isDragOver = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 500, maxWidth: 900),
      margin: EdgeInsets.symmetric(
          horizontal: 10, vertical: widget.heading != "" ? 10 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.heading != "")
            Text(
              "${widget.heading} : ",
              maxLines: 1,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: AppColorsInApp.colorGrey),
            ),
          Container(
            margin: const EdgeInsets.only(top: 5),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                width: _isDragOver ? 2 : 1,
                color: _isDragOver
                    ? AppColorsInApp.colorSecondary!
                    : AppColorsInApp.colorBlack1.withValues(alpha: .2),
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropRegion(
                  formats: const [Formats.plainText],
                  hitTestBehavior: HitTestBehavior.opaque,
                  onDropOver: _handleDropOver,
                  onDropLeave: _handleDropLeave,
                  onPerformDrop: _handlePerformDrop,
                  child: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: (_isDragOver
                              ? AppColorsInApp.colorSecondary
                              : AppColorsInApp.colorGreyWhite)!
                          .withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.drag_indicator,
                            size: 14, color: AppColorsInApp.colorGrey),
                        const SizedBox(width: 4),
                        Text(
                          "Drag text here to fill this field, or type directly",
                          style: TextStyle(
                              fontSize: 11, color: AppColorsInApp.colorGrey),
                        ),
                      ],
                    ),
                  ),
                ),
                HtmlEditor(
                  controller: widget.controller,
                  callbacks: Callbacks(
                    onInit: widget.onEditorInit,
                    onChangeContent: widget.onContentChanged,
                  ),
                  htmlToolbarOptions: const HtmlToolbarOptions(
                    dropdownMenuMaxHeight: 200,
                    dropdownMenuDirection: DropdownMenuDirection.down,
                    dropdownItemHeight: 60,
                    toolbarType: ToolbarType.nativeScrollable,
                    textStyle: TextStyle(
                        color: Colors.black,
                        backgroundColor: Colors.transparent),
                    defaultToolbarButtons: [
                      StyleButtons(),
                      FontSettingButtons(),
                      FontButtons(),
                      ColorButtons(),
                      ListButtons(),
                      ParagraphButtons(),
                      InsertButtons(),
                      OtherButtons(),
                    ],
                  ),
                  htmlEditorOptions: const HtmlEditorOptions(
                    hint: "Your text here...",
                    autoAdjustHeight: false,
                    spellCheck: true,
                    adjustHeightForKeyboard: false,
                    androidUseHybridComposition: false,
                    initialText: "",
                  ),
                  otherOptions: const OtherOptions(
                      height: 200, decoration: BoxDecoration()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
