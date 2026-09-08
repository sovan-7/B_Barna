import 'package:bbarna/resources/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

/// A labelled rich-text field.
///
/// The old editor shipped a big coloured button under every one of these —
/// "Upload/ View Question", "Upload/ View Solution", and six more. Every
/// one was wired to `onUpload: () {}`. They are gone; what is left is the
/// label, the editor, and an error line.
class QuestionRichField extends StatelessWidget {
  final String label;
  final HtmlEditorController controller;

  /// Shown under the label — what this field is for, when that is not
  /// obvious from two words.
  final String? hint;
  final String? error;
  final double height;

  /// Marks the field as the correct answer. Only the option fields use it.
  final Widget? trailing;

  const QuestionRichField({
    required this.label,
    required this.controller,
    this.hint,
    this.error,
    this.height = 180,
    this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF344054))),
                  if (hint != null) ...[
                    const SizedBox(height: 2),
                    Text(hint!,
                        style: const TextStyle(
                            fontSize: 11.5,
                            height: 1.35,
                            color: AppTokens.inkFaint)),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppTokens.gapSm),
              trailing!,
            ],
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTokens.surface,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(
                color: error != null ? AppTokens.danger : AppTokens.hairline),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd - 1),
            child: HtmlEditor(
              controller: controller,
              htmlToolbarOptions: const HtmlToolbarOptions(
                dropdownMenuMaxHeight: 200,
                dropdownMenuDirection: DropdownMenuDirection.down,
                // Must not go under kMinInteractiveDimension (48):
                // DropdownButton asserts on it, and the toolbar's font and
                // style pickers are DropdownButtons.
                dropdownItemHeight: kMinInteractiveDimension,
                toolbarType: ToolbarType.nativeScrollable,
                textStyle: TextStyle(
                    color: Colors.black, backgroundColor: Colors.transparent),
                defaultToolbarButtons: [
                  StyleButtons(),
                  FontButtons(clearAll: false),
                  ColorButtons(),
                  ListButtons(listStyles: false),
                  ParagraphButtons(
                      textDirection: false, lineHeight: false, caseConverter: false),
                  InsertButtons(video: false, audio: false, table: false, hr: false),
                ],
              ),
              htmlEditorOptions: const HtmlEditorOptions(
                hint: "Type here…",
                autoAdjustHeight: false,
                spellCheck: true,
                adjustHeightForKeyboard: false,
                androidUseHybridComposition: false,
                initialText: "",
              ),
              otherOptions:
                  OtherOptions(height: height, decoration: const BoxDecoration()),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 5),
          Text(error!, style: AppTokens.errorText),
        ],
      ],
    );
  }
}
