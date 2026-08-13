import 'package:bbarna/question1/model/question1.dart';
import 'package:bbarna/question1/screen/edit_question1.dart';
import 'package:bbarna/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class Question1ListWidget extends StatelessWidget {
  const Question1ListWidget({
    required this.question,
    required this.questionIndex,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Question1 question;
  final int questionIndex;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColorsInApp.colorWhite,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${questionIndex + 1}. ",
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppColorsInApp.colorBlack1),
                    ),
                    Expanded(
                      child: HtmlWidget(
                        question.question,
                        textStyle: const TextStyle(overflow: TextOverflow.visible),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: AppColorsInApp.colorYellow1),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Code: ",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColorsInApp.colorBlack1),
                            ),
                            SelectableText(
                              question.questionCode,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.normal,
                                  color: AppColorsInApp.colorBlack1),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: HtmlWidget(
                          question.answer,
                          textStyle: TextStyle(
                              color: Colors.green[700],
                              fontSize: 15,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                EditQuestion1(question: question)))
                        .whenComplete(onEdit);
                  },
                  child: Icon(Icons.edit, color: AppColorsInApp.colorYellow),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: InkWell(
                    onTap: onDelete,
                    child: const Icon(Icons.delete,
                        color: AppColorsInApp.colorPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
