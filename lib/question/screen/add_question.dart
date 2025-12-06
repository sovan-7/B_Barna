import 'package:bbarna/core/widgets/save_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:bbarna/core/widgets/app_header.dart';
import 'package:bbarna/core/widgets/custom_text_field.dart';
import 'package:bbarna/core/widgets/extra_sidebar.dart';
import 'package:bbarna/question/widgets/question_html_editor.dart';
import 'package:bbarna/resources/app_colors.dart';
import 'package:bbarna/utils/helper.dart';

class AddQuestion extends StatefulWidget {
  const AddQuestion({super.key});

  @override
  State<AddQuestion> createState() => _AddQuestionState();
}

class _AddQuestionState extends State<AddQuestion> {
  int selectedIndex = -1;
  ScrollController scrollController = ScrollController();
  TextEditingController questionCodeController = TextEditingController();
  HtmlEditorController questionController = HtmlEditorController();
  HtmlEditorController solutionController = HtmlEditorController();
  HtmlEditorController optionOneController = HtmlEditorController();
  HtmlEditorController optionTwoController = HtmlEditorController();
  HtmlEditorController optionThreeController = HtmlEditorController();
  HtmlEditorController optionFourController = HtmlEditorController();
  HtmlEditorController questionBodyController = HtmlEditorController();
  HtmlEditorController hintController = HtmlEditorController();
  final GlobalKey<ScaffoldState> key = GlobalKey();
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        key: key,
        body: PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              Navigator.of(context).pop();
            }
          },
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
                  visible: (width > 900),
                  child: const Expanded(
                      child: ExtraSideBar(
                    sidebarIndex: 9,
                  )),
                ),
                Expanded(
                    flex: 5,
                    child: Row(children: [
                      Expanded(
                        //  flex: 5,
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Container(
                            margin: width > 900
                                ? const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 30)
                                : const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 20),
                            padding: EdgeInsets.all(width > 900 ? 30 : 20),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1,
                                    color: AppColorsInApp.colorGreyWhite),
                                color: AppColorsInApp.colorBlue
                                    .withValues(alpha: .1)),
                            child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, top: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 8.0, left: 10),
                                      child: CustomTextField(
                                        labelText: "Question Code",
                                        title: "Question Code",
                                        isBorderRadius: true,
                                        textEditingController:
                                            questionCodeController,
                                      ),
                                    ),
                                    QuestionHtmlEditor(
                                      heading: "Question",
                                      controller: questionController,
                                      onUpload: () {},
                                      buttonColor: AppColorsInApp.colorBlue,
                                      buttonText: "Upload/ View Question",
                                      isHeightBigOrNot: false,
                                    ),
                                    QuestionHtmlEditor(
                                      heading: "Question Body",
                                      controller: questionBodyController,
                                      onUpload: () {},
                                      buttonColor: AppColorsInApp.colorBlue,
                                      buttonText: "Upload/ View Question Body",
                                      isHeightBigOrNot: false,
                                    ),
                                    QuestionHtmlEditor(
                                      heading: "Solution",
                                      controller: solutionController,
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
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                    color: AppColorsInApp
                                                        .colorGrey),
                                              ),
                                              SizedBox(
                                                  width: 30,
                                                  child: Radio(
                                                    groupValue: selectedIndex,
                                                    value: 1,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        selectedIndex = value!;
                                                      });
                                                    },
                                                  )),
                                            ],
                                          ),
                                        ),
                                        QuestionHtmlEditor(
                                          heading: "",
                                          controller: optionOneController,
                                          onUpload: () {},
                                          buttonColor: AppColorsInApp.colorBlue,
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
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                    color: AppColorsInApp
                                                        .colorGrey),
                                              ),
                                              SizedBox(
                                                  width: 50,
                                                  child: Radio(
                                                    groupValue: selectedIndex,
                                                    value: 2,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        selectedIndex = value!;
                                                      });
                                                    },
                                                  )),
                                            ],
                                          ),
                                        ),
                                        QuestionHtmlEditor(
                                          heading: "",
                                          controller: optionTwoController,
                                          onUpload: () {},
                                          buttonColor: AppColorsInApp.colorBlue,
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
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                    color: AppColorsInApp
                                                        .colorGrey),
                                              ),
                                              SizedBox(
                                                  width: 50,
                                                  child: Radio(
                                                    groupValue: selectedIndex,
                                                    value: 3,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        selectedIndex = value!;
                                                      });
                                                    },
                                                  )),
                                            ],
                                          ),
                                        ),
                                        QuestionHtmlEditor(
                                          heading: "",
                                          controller: optionThreeController,
                                          onUpload: () {},
                                          buttonColor: AppColorsInApp.colorBlue,
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
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                    color: AppColorsInApp
                                                        .colorGrey),
                                              ),
                                              SizedBox(
                                                  width: 50,
                                                  child: Radio(
                                                    groupValue: selectedIndex,
                                                    value: 4,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        selectedIndex = value!;
                                                      });
                                                    },
                                                  )),
                                            ],
                                          ),
                                        ),
                                        QuestionHtmlEditor(
                                          heading: "",
                                          controller: optionFourController,
                                          onUpload: () {},
                                          buttonColor: AppColorsInApp.colorBlue,
                                          buttonText: "Upload/ View Option",
                                          isHeightBigOrNot: true,
                                        ),
                                      ],
                                    ),
                                    QuestionHtmlEditor(
                                      heading: "Hints",
                                      controller: hintController,
                                      onUpload: () {},
                                      buttonColor: AppColorsInApp.colorYellow!,
                                      buttonText: "Upload/ View Hints",
                                      textColor: true,
                                      isHeightBigOrNot: true,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 25.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SaveButton(
                                            onPRess: () {
                                              clearControllerData();
                                            },
                                            buttonText: "Reset",
                                            buttonColor:
                                                AppColorsInApp.colorOrange,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 15),
                                            child:
                                                SaveButton(onPRess: () async {
                                              if (questionCodeController
                                                  .text.isEmpty) {
                                                Helper.showSnackBarMessage(
                                                    msg:
                                                        "Please add question code",
                                                    isSuccess: false);
                                              } else if (await questionController
                                                      .getText() ==
                                                  "") {
                                                Helper.showSnackBarMessage(
                                                    msg: "Please add question",
                                                    isSuccess: false);
                                              } else if (selectedIndex == -1) {
                                                Helper.showSnackBarMessage(
                                                    msg:
                                                        "Please select the correct answer",
                                                    isSuccess: false);
                                              } else {
                                                addQuestion().then((value) {
                                                  scrollController.animateTo(0,
                                                      duration: const Duration(
                                                          milliseconds: 150),
                                                      curve: Curves.easeIn);
                                                });
                                              }
                                            }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      )
                    ]))
              ]),
            ),
          ]),
        ),
        drawer: width < 900
            ? const Drawer(child: ExtraSideBar(sidebarIndex: 9))
            : null);
  }

  Future<void> addQuestion() async {
    try {
      // Reference to the collection where you want to add the document
      CollectionReference collectionReference =
          _fireStore.collection('question');

      // Data to be added
      Map<String, dynamic> data = {
        'question_code': questionCodeController.text.trim().toUpperCase(),
        'question': await questionController.getText(),
        'question_body': await questionBodyController.getText(),
        "option1": await optionOneController.getText(),
        "option2": await optionTwoController.getText(),
        "option3": await optionThreeController.getText(),
        "option4": await optionFourController.getText(),
        "hints": await hintController.getText(),
        "answer": await getAnswer(),
        "solution": await solutionController.getText(),
        "timeStamp": DateTime.now().millisecondsSinceEpoch
      };

      await collectionReference.add(data).then((value) {
        clearControllerData();
        scrollController.animateTo(0,
            duration: const Duration(milliseconds: 250), curve: Curves.easeIn);
        Helper.showSnackBarMessage(
            msg: "Question added successfully", isSuccess: true);
      });
    } catch (e) {
      Helper.showSnackBarMessage(
          msg: "Error adding data: $e", isSuccess: false);
    }
  }

  void clearControllerData() {
    questionCodeController.clear();
    questionController.clear();
    questionBodyController.clear();
    optionOneController.clear();
    optionTwoController.clear();
    optionThreeController.clear();
    optionFourController.clear();
    hintController.clear();
    solutionController.clear();
    selectedIndex = -1;
    setState(() {});
  }

  Future<String> getAnswer() async {
    String answer = "";
    switch (selectedIndex) {
      case 1:
        answer = await optionOneController.getText();
      case 2:
        answer = await optionTwoController.getText();
      case 3:
        answer = await optionThreeController.getText();
      case 4:
        answer = await optionFourController.getText();
    }
    return answer;
  }
}
