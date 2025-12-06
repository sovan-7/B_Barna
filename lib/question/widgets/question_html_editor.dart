// ignore_for_file: must_be_immutable, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:bbarna/resources/app_colors.dart';

class QuestionHtmlEditor extends StatelessWidget {
  HtmlEditorController controller;
  String heading = "";
  Function onUpload;
  String buttonText;
  Color buttonColor;
  bool textColor;
  bool isHeightBigOrNot;
  QuestionHtmlEditor(
      {required this.heading,
      required this.controller,
      required this.onUpload,
      required this.buttonText,
      required this.buttonColor,
      required this.isHeightBigOrNot,
      this.textColor = true,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 500,
        maxWidth: 900,
      ),
      margin: EdgeInsets.symmetric(
          horizontal: 10, vertical: heading != "" ? 10 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (heading != "")
            Text(
              "$heading : ",
              maxLines: 1,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: AppColorsInApp.colorGrey),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 1,
                      color: AppColorsInApp.colorBlack1.withValues(alpha: .2)),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: HtmlEditor(
                  controller: controller,
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
                    initialText: '''
                                <style>
                                  body, p, div {
                                   font-size: 16px !important;
                                    }
                            * {
                              background-color: transparent !important; 
                              color: black !important;
                            }
                          </style>
                        ''',
                  ),
                  otherOptions: const OtherOptions(
                      height: 200, decoration: BoxDecoration()),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: InkWell(
                  onTap: () {
                    onUpload();
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: buttonColor,
                    ),
                    child: Text(
                      buttonText,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: textColor
                              ? AppColorsInApp.colorWhite
                              : AppColorsInApp.colorBlack1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
