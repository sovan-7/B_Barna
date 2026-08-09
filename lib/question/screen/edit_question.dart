// ignore_for_file: use_build_context_synchronously

import 'package:bbarna/core/widgets/save_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bbarna/core/widgets/app_header.dart';
import 'package:bbarna/core/widgets/custom_text_field.dart';
import 'package:bbarna/core/widgets/sidebar.dart';
import 'package:bbarna/question/question_viewmodel/question_viewmodel.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:bbarna/utils/size_config.dart';
import 'package:bbarna/question/model/question.dart';
import 'package:bbarna/question/widgets/question_html_editor.dart';
import 'package:bbarna/resources/app_colors.dart';
import 'package:provider/provider.dart';

class EditQuestion extends StatefulWidget {
  final Question question;
  const EditQuestion({required this.question, super.key});

  @override
  State<EditQuestion> createState() => _EditQuestionState();
}

class _EditQuestionState extends State<EditQuestion> {
  final GlobalKey<ScaffoldState> key = GlobalKey();
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    QuestionViewModel questionViewModel =
        Provider.of<QuestionViewModel>(context, listen: false);
    questionViewModel.clearControllerData();
    Future.delayed(const Duration(seconds: 2), () {
      questionViewModel.setControllerData(question: widget.question);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        body: PopScope(
          onPopInvoked: (bool val) {},
          canPop: true,
          child: Column(children: [
            AppHeader(
              onTapIcon: () {
                key.currentState?.openDrawer();
              },
            ),
            Expanded(
              child: Row(children: [
                Visibility(
                    visible: (SizeConfig.screenWidth! > 900),
                    child: const Expanded(
                        child: ExtraSideBar(
                      sidebarIndex: 9,
                    ))),
                Expanded(
                    flex: 5,
                    child: Row(children: [
                      Expanded(
                        //flex: 5,
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Container(
                            margin: SizeConfig.screenWidth! > 900
                                ? const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 30)
                                : const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 20),
                            padding: EdgeInsets.all(
                                SizeConfig.screenWidth! > 900 ? 30 : 20),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1,
                                    color: AppColorsInApp.colorGreyWhite),
                                color:
                                    AppColorsInApp.colorBlue.withValues(alpha: .1)),
                            child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, top: 10),
                                child: Consumer<QuestionViewModel>(builder:
                                    (context, questionDataProvider, child) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 8.0, left: 10),
                                        child: CustomTextField(
                                          labelText: "Question Code",
                                          title: "Question Code",
                                          isBorderRadius: true,
                                          textEditingController:
                                              questionDataProvider
                                                  .questionCodeController,
                                        ),
                                      ),
                                      QuestionHtmlEditor(
                                        heading: "Question",
                                        controller: questionDataProvider
                                            .questionController,
                                        onUpload: () {},
                                        buttonColor: AppColorsInApp.colorBlue,
                                        buttonText: "Upload/ View Question",
                                        isHeightBigOrNot: false,
                                      ),
                                      QuestionHtmlEditor(
                                        heading: "Question Body",
                                        controller: questionDataProvider
                                            .questionBodyController,
                                        onUpload: () {},
                                        buttonColor: AppColorsInApp.colorBlue,
                                        buttonText:
                                            "Upload/ View Question Body",
                                        isHeightBigOrNot: false,
                                      ),
                                      QuestionHtmlEditor(
                                        heading: "Solution",
                                        controller: questionDataProvider
                                            .solutionController,
                                        onUpload: () {},
                                        buttonColor:
                                            AppColorsInApp.colorSecondary!,
                                        buttonText: "Upload/ View Solution",
                                        textColor: true,
                                        isHeightBigOrNot: true,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Row(
                                              children: [
                                                const Text(
                                                  "Option A: ",
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 0.5,
                                                      color: AppColorsInApp
                                                          .colorGrey),
                                                ),
                                                SizedBox(
                                                    width: 50,
                                                    child: Radio(
                                                      groupValue:
                                                          questionDataProvider
                                                              .selectIndex,
                                                      value: 1,
                                                      onChanged: (value) {
                                                        questionDataProvider
                                                            .setSelectedIndex(
                                                                value!);
                                                      },
                                                    )),
                                              ],
                                            ),
                                          ),
                                          QuestionHtmlEditor(
                                            heading: "",
                                            controller: questionDataProvider
                                                .optionOneController,
                                            onUpload: () {},
                                            buttonColor:
                                                AppColorsInApp.colorBlue,
                                            buttonText: "Upload/ View Option",
                                            isHeightBigOrNot: true,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Row(
                                              children: [
                                                const Text(
                                                  "Option B: ",
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 0.5,
                                                      color: AppColorsInApp
                                                          .colorGrey),
                                                ),
                                                SizedBox(
                                                    width: 50,
                                                    child: Radio(
                                                      groupValue:
                                                          questionDataProvider
                                                              .selectIndex,
                                                      value: 2,
                                                      onChanged: (value) {
                                                        questionDataProvider
                                                            .setSelectedIndex(
                                                                value!);
                                                      },
                                                    )),
                                              ],
                                            ),
                                          ),
                                          QuestionHtmlEditor(
                                            heading: "",
                                            controller: questionDataProvider
                                                .optionTwoController,
                                            onUpload: () {},
                                            buttonColor:
                                                AppColorsInApp.colorBlue,
                                            buttonText: "Upload/ View Option",
                                            isHeightBigOrNot: true,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Row(
                                              children: [
                                                const Text(
                                                  "Option C: ",
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 0.5,
                                                      color: AppColorsInApp
                                                          .colorGrey),
                                                ),
                                                SizedBox(
                                                    width: 50,
                                                    child: Radio(
                                                      groupValue:
                                                          questionDataProvider
                                                              .selectIndex,
                                                      value: 3,
                                                      onChanged: (value) {
                                                        questionDataProvider
                                                            .setSelectedIndex(
                                                                value!);
                                                      },
                                                    )),
                                              ],
                                            ),
                                          ),
                                          QuestionHtmlEditor(
                                            heading: "",
                                            controller: questionDataProvider
                                                .optionThreeController,
                                            onUpload: () {},
                                            buttonColor:
                                                AppColorsInApp.colorBlue,
                                            buttonText: "Upload/ View Option",
                                            isHeightBigOrNot: true,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Row(
                                              children: [
                                                const Text(
                                                  "Option D: ",
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 0.5,
                                                      color: AppColorsInApp
                                                          .colorGrey),
                                                ),
                                                SizedBox(
                                                    width: 50,
                                                    child: Radio(
                                                      groupValue:
                                                          questionDataProvider
                                                              .selectIndex,
                                                      value: 4,
                                                      onChanged: (value) {
                                                        questionDataProvider
                                                            .setSelectedIndex(
                                                                value!);
                                                      },
                                                    )),
                                              ],
                                            ),
                                          ),
                                          QuestionHtmlEditor(
                                            heading: "",
                                            controller: questionDataProvider
                                                .optionFourController,
                                            onUpload: () {},
                                            buttonColor:
                                                AppColorsInApp.colorBlue,
                                            buttonText: "Upload/ View Option",
                                            isHeightBigOrNot: true,
                                          ),
                                        ],
                                      ),
                                      QuestionHtmlEditor(
                                        heading: "Hints",
                                        controller:
                                            questionDataProvider.hintController,
                                        onUpload: () {},
                                        buttonColor:
                                            AppColorsInApp.colorYellow!,
                                        buttonText: "Upload/ View Hints",
                                        textColor: true,
                                        isHeightBigOrNot: true,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 25.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SaveButton(
                                              onPRess: () {
                                                questionDataProvider
                                                    .clearControllerData();
                                              },
                                              buttonText: "Reset",
                                              buttonColor:
                                                  AppColorsInApp.colorOrange,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child:
                                                  SaveButton(onPRess: () async {
                                                if (questionDataProvider
                                                    .questionCodeController
                                                    .text
                                                    .isEmpty) {
                                                  Helper.showSnackBarMessage(
                                                      msg:
                                                          "Please add question code",
                                                      isSuccess: false);
                                                } else if (await questionDataProvider
                                                        .questionController
                                                        .getText() ==
                                                    "") {
                                                  Helper.showSnackBarMessage(
                                                      msg:
                                                          "Please add question",
                                                      isSuccess: false);
                                                } else if (questionDataProvider
                                                        .selectIndex ==
                                                    -1) {
                                                  Helper.showSnackBarMessage(
                                                      msg:
                                                          "Please select the correct answer",
                                                      isSuccess: false);
                                                } else {
                                                  updateQuestion(
                                                      widget.question.docId,
                                                      questionDataProvider);
                                                }
                                              }),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                })),
                          ),
                        ),
                      )
                    ]))
              ]),
            ),
          ]),
        ),
        drawer: SizeConfig.screenWidth! > 900
            ? null
            : const Drawer(
                child: ExtraSideBar(sidebarIndex: 9),
              ));
  }

  Future<void> updateQuestion(
      String documentId, QuestionViewModel questionViewModel) async {
    try {
      DocumentReference documentReference =
          _fireStore.collection('question').doc(documentId);
      // Data to be added
      Map<String, dynamic> data = {
        'question_code': questionViewModel.questionCodeController.text.trim().toUpperCase(),
        'question': await questionViewModel.questionController.getText(),
        'question_body':
            await questionViewModel.questionBodyController.getText(),
        "option1": await questionViewModel.optionOneController.getText(),
        "option2": await questionViewModel.optionTwoController.getText(),
        "option3": await questionViewModel.optionThreeController.getText(),
        "option4": await questionViewModel.optionFourController.getText(),
        "hints": await questionViewModel.hintController.getText(),
        "answer": await getAnswer(questionViewModel),
        "solution": await questionViewModel.solutionController.getText(),
        "timeStamp":widget.question.timeStamp
      };
      // Update the document with new data
      await documentReference.update(data);
      Helper.showSnackBarMessage(
          msg: "Question updated successfully", isSuccess: true);
      Navigator.pop(context);
    } catch (e) {
      Helper.showSnackBarMessage(msg: "Error while updating", isSuccess: false);
    }
  }

  Future<String> getAnswer(QuestionViewModel questionViewModel) async {
    String answer = "";
    switch (questionViewModel.selectIndex) {
      case 1:
        answer = await questionViewModel.optionOneController.getText();
      case 2:
        answer = await questionViewModel.optionTwoController.getText();
      case 3:
        answer = await questionViewModel.optionThreeController.getText();
      case 4:
        answer = await questionViewModel.optionFourController.getText();
    }
    return answer;
  }
}
