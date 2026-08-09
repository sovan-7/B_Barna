import 'package:bbarna/core/widgets/loader_dialog.dart';
import 'package:bbarna/core/widgets/save_button.dart';
import 'package:bbarna/quiz/model/quiz_model.dart';
import 'package:bbarna/quiz/viewModel/quiz_view_model.dart';
import 'package:bbarna/quiz/widgets/quiz_question_widget.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:bbarna/core/widgets/app_header.dart';
import 'package:bbarna/core/widgets/sidebar.dart';
import 'package:bbarna/resources/app_colors.dart';
import 'package:bbarna/core/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

class EditQuiz extends StatefulWidget {
  final QuizModel quizModel;
  const EditQuiz({required this.quizModel, super.key});

  @override
  State<EditQuiz> createState() => _EditQuizState();
}

class _EditQuizState extends State<EditQuiz> {
  TextEditingController quizCodeController = TextEditingController();
  TextEditingController totalQuestionController = TextEditingController();
  TextEditingController totalWrongAnswerController = TextEditingController();
  TextEditingController totalTimeHourController = TextEditingController();
  TextEditingController totalTimeMinuteController = TextEditingController();

  TextEditingController quizNameController = TextEditingController();
  TextEditingController totalMarksController = TextEditingController();
  TextEditingController noDeductionController = TextEditingController();
  TextEditingController questionCodeController = TextEditingController();

  String? _selectedQuizType;
  ScrollController scrollController = ScrollController();

  final List<String> _dropdownItems = ['FREE', 'PAID'];
  final GlobalKey<ScaffoldState> key = GlobalKey();
  List<String> statusList = ["UPCOMING", "LIVE", "PENDING"];
  String selectedStatus = "UPCOMING";
  bool isGeneratedPress = false;
  bool isSelectAll = false;

  @override
  void initState() {
    Provider.of<QuizViewModel>(context, listen: false).clearData();
    setState(() {
      quizCodeController.text = widget.quizModel.code;
      totalQuestionController.text = widget.quizModel.totalQuestion.toString();
      quizNameController.text = widget.quizModel.name;
      totalMarksController.text = widget.quizModel.totalMarks.toString();
      totalWrongAnswerController.text =
          widget.quizModel.totalWrongAnswer.toString();
      int hour = widget.quizModel.totalTime ~/ 60;
      int minute = (widget.quizModel.totalTime % 60);
      totalTimeHourController.text = hour.toString();
      totalTimeMinuteController.text = minute.toString();

      _selectedQuizType = widget.quizModel.type;
      selectedStatus = widget.quizModel.status;
      noDeductionController.text = widget.quizModel.numberDeduction.toString();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        key: key,
        body: PopScope(
            onPopInvoked: (bool val) {},
            canPop: true,
            child: Consumer<QuizViewModel>(
                builder: (context, quizDataProvider, child) {
              return Column(children: [
                AppHeader(
                  onTapIcon: () {
                    key.currentState?.openDrawer();
                  },
                ),
                Expanded(
                    child: Row(children: [
                  if (width > 1200)
                    const Expanded(
                        child: ExtraSideBar(
                      sidebarIndex: 8,
                    )),
                  Expanded(
                      flex: 5,
                      child: Consumer<QuizViewModel>(
                          builder: (context, quizDataProvider, child) {
                        return Container(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 20),
                          alignment: Alignment.center,
                          color: AppColorsInApp.colorGrey.withValues(alpha: .1),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              // direction: Axis.vertical,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          CustomTextField(
                                            title: "Quiz Code",
                                            labelText: "Quiz code",
                                            textEditingController:
                                                quizCodeController,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 15.0),
                                            child: CustomTextField(
                                              title: "Quiz Name",
                                              labelText: "Quiz name",
                                              textEditingController:
                                                  quizNameController,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 15.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Quiz Type",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColorsInApp
                                                          .colorGrey),
                                                ),
                                                Container(
                                                  width: 350,
                                                  margin: const EdgeInsets.only(
                                                    top: 10,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15, right: 15),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: AppColorsInApp
                                                        .colorWhite,
                                                  ),
                                                  child: DropdownButton<String>(
                                                    value: _selectedQuizType,
                                                    elevation: 16,
                                                    isExpanded: true,
                                                    hint: const Text(
                                                        "Select Type"),
                                                    style: const TextStyle(
                                                        color: AppColorsInApp
                                                            .colorBlack1),
                                                    underline: const SizedBox(),
                                                    onChanged:
                                                        (String? newValue) {
                                                      setState(() {
                                                        _selectedQuizType =
                                                            newValue!;
                                                      });
                                                    },
                                                    items: _dropdownItems.map<
                                                            DropdownMenuItem<
                                                                String>>(
                                                        (String value) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: value,
                                                        child: Text(value),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 15.0),
                                            child: CustomTextField(
                                              title: "No. of Question",
                                              labelText: "No. of Question",
                                              textEditingController:
                                                  totalQuestionController,
                                              textInputType:
                                                  TextInputType.number,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 15.0),
                                            child: CustomTextField(
                                              title: "No. of Wrong Answer",
                                              labelText: "No. of Wrong Answer",
                                              textEditingController:
                                                  totalWrongAnswerController,
                                              textInputType:
                                                  TextInputType.number,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 15.0, left: 15),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 150,
                                                  child: CustomTextField(
                                                    title: "Total Time (Hour)",
                                                    labelText: "Hour",
                                                    textEditingController:
                                                        totalTimeHourController,
                                                    textInputType:
                                                        TextInputType.number,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 50,
                                                ),
                                                SizedBox(
                                                  width: 150,
                                                  child: CustomTextField(
                                                    title: "Minutes",
                                                    labelText: "Minute",
                                                    textEditingController:
                                                        totalTimeMinuteController,
                                                    textInputType:
                                                        TextInputType.number,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Visibility(
                                            visible: width < 1200,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 15.0),
                                                  child: CustomTextField(
                                                    title: "No. of Marks",
                                                    labelText: "No. of Marks",
                                                    textEditingController:
                                                        totalMarksController,
                                                    textInputType:
                                                        TextInputType.number,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 15.0),
                                                  child: CustomTextField(
                                                    title: "No Deduction",
                                                    labelText: "No Deduction",
                                                    textEditingController:
                                                        noDeductionController,
                                                    textInputType:
                                                        TextInputType.number,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 25),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: List.generate(
                                                        statusList.length,
                                                        (index) => InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  selectedStatus =
                                                                      statusList[
                                                                          index];
                                                                });
                                                              },
                                                              child: Container(
                                                                height: 30,
                                                                width: 90,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                margin:
                                                                    EdgeInsets
                                                                        .only(
                                                                  left:
                                                                      index != 0
                                                                          ? 8
                                                                          : 0,
                                                                ),
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                5),
                                                                    color: statusList[index] ==
                                                                            selectedStatus
                                                                        ? AppColorsInApp
                                                                            .colorSecondary
                                                                        : AppColorsInApp
                                                                            .colorGrey),
                                                                child: Text(
                                                                  statusList[
                                                                      index],
                                                                  style: const TextStyle(
                                                                      color: AppColorsInApp
                                                                          .colorWhite,
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ),
                                                            )),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Visibility(
                                            visible: (!isGeneratedPress &&
                                                width < 900),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 30,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SaveButton(onPRess: () {
                                                    if (quizCodeController
                                                            .text.isNotEmpty &&
                                                        quizNameController
                                                            .text.isNotEmpty) {
                                                      LoaderDialogs
                                                          .showLoadingDialog();
                                                      int hour =
                                                          totalTimeHourController
                                                                  .text.isEmpty
                                                              ? 0
                                                              : int.parse(
                                                                  totalTimeHourController
                                                                      .text);
                                                      int minute =
                                                          totalTimeMinuteController
                                                                  .text.isEmpty
                                                              ? 0
                                                              : int.parse(
                                                                  totalTimeMinuteController
                                                                      .text);
                                                      int totalTime =
                                                          (hour * 60) + minute;
                                                      QuizModel quizModel = QuizModel(
                                                          widget.quizModel.code
                                                              .toUpperCase(),
                                                          widget.quizModel.name,
                                                          widget
                                                              .quizModel.status,
                                                          widget.quizModel.type,
                                                          totalTime,
                                                          widget.quizModel
                                                              .timeStamp,
                                                          totalMarksController
                                                                  .text.isEmpty
                                                              ? 0
                                                              : int.parse(
                                                                  totalMarksController
                                                                      .text),
                                                          noDeductionController
                                                                  .text.isEmpty
                                                              ? 0
                                                              : int.parse(
                                                                  noDeductionController
                                                                      .text),
                                                          totalWrongAnswerController
                                                                  .text.isEmpty
                                                              ? 0
                                                              : int.parse(
                                                                  totalWrongAnswerController.text),
                                                          int.parse(totalQuestionController.text),
                                                          widget.quizModel.questionCodeList);
                                                      quizDataProvider
                                                          .updateQuiz(
                                                              quizModel,
                                                              widget.quizModel
                                                                  .docId)
                                                          .then((value) {
                                                        /// remove loader
                                                        Navigator.pop(context);
                                                        Helper
                                                            .showSnackBarMessage(
                                                          msg:
                                                              "Quiz updated successfully",
                                                          isSuccess: true,
                                                        );
                                                        Navigator.pop(context);
                                                      });
                                                    } else {
                                                      Helper
                                                          .showSnackBarMessage(
                                                        msg:
                                                            "Please fill above field",
                                                        isSuccess: false,
                                                      );
                                                    }
                                                  }),
                                                  const SizedBox(
                                                    width: 30,
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        isGeneratedPress =
                                                            !isGeneratedPress;
                                                      });
                                                      if (widget
                                                          .quizModel
                                                          .questionCodeList
                                                          .isNotEmpty) {
                                                        quizDataProvider
                                                            .fetchQuizQuestionList(
                                                                widget.quizModel
                                                                    .questionCodeList);
                                                      }
                                                    },
                                                    child: Container(
                                                      height: 35,
                                                      width: 160,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          color: AppColorsInApp
                                                              .colorSecondary),
                                                      child: const Text(
                                                        "Generate Question",
                                                        style: TextStyle(
                                                            color:
                                                                AppColorsInApp
                                                                    .colorWhite,
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: width > 900,
                                      child: Expanded(
                                        flex: 2,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            CustomTextField(
                                              title: "No. of Marks",
                                              labelText: "No. of Marks",
                                              textEditingController:
                                                  totalMarksController,
                                              textInputType:
                                                  TextInputType.number,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 15.0),
                                              child: CustomTextField(
                                                title: "No Deduction",
                                                labelText: "No Deduction",
                                                textEditingController:
                                                    noDeductionController,
                                                textInputType:
                                                    TextInputType.number,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 25),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: List.generate(
                                                    statusList.length,
                                                    (index) => InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              selectedStatus =
                                                                  statusList[
                                                                      index];
                                                            });
                                                          },
                                                          child: Container(
                                                            height: 30,
                                                            width: 90,
                                                            alignment: Alignment
                                                                .center,
                                                            margin:
                                                                EdgeInsets.only(
                                                              left: index != 0
                                                                  ? 8
                                                                  : 0,
                                                            ),
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                color: statusList[
                                                                            index] ==
                                                                        selectedStatus
                                                                    ? AppColorsInApp
                                                                        .colorSecondary
                                                                    : AppColorsInApp
                                                                        .colorGrey),
                                                            child: Text(
                                                              statusList[index],
                                                              style: const TextStyle(
                                                                  color: AppColorsInApp
                                                                      .colorWhite,
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                          ),
                                                        )),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 30,
                                              ),
                                              child: Visibility(
                                                visible: !isGeneratedPress,
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      isGeneratedPress =
                                                          !isGeneratedPress;
                                                    });
                                                    if (widget
                                                        .quizModel
                                                        .questionCodeList
                                                        .isNotEmpty) {
                                                      quizDataProvider
                                                          .fetchQuizQuestionList(
                                                              widget.quizModel
                                                                  .questionCodeList);
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 35,
                                                    width: 165,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: AppColorsInApp
                                                            .colorSecondary),
                                                    child: const Text(
                                                      "Generate Question",
                                                      style: TextStyle(
                                                          color: AppColorsInApp
                                                              .colorWhite,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Column(
                                      children: List.generate(
                                          quizDataProvider.quizQuestionList
                                              .length, (index) {
                                    return width < 900
                                        ? FittedBox(
                                            child: QuizQuestionListWidget(
                                            question: quizDataProvider
                                                .quizQuestionList[index],
                                            questionIndex: index,
                                            quizData: widget.quizModel,
                                            isSelected: quizDataProvider
                                                .quizQuestionList[index]
                                                .isSelected,
                                            onPress: (bool value) {
                                              quizDataProvider
                                                  .updateOldQuestion(index);
                                            },
                                          ))
                                        : QuizQuestionListWidget(
                                            question: quizDataProvider
                                                .quizQuestionList[index],
                                            questionIndex: index,
                                            quizData: widget.quizModel,
                                            isSelected: quizDataProvider
                                                .quizQuestionList[index]
                                                .isSelected,
                                            onPress: (bool value) {
                                              quizDataProvider
                                                  .updateOldQuestion(index);
                                            },
                                          );
                                  })),
                                ),
                                Visibility(
                                  visible: isGeneratedPress,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColorsInApp.colorLightBlue
                                          .withValues(alpha: .2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.only(
                                        left: 10, bottom: 10, right: 40),
                                    margin: const EdgeInsets.only(
                                        bottom: 8, left: 12, right: 12, top: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            CustomTextField(
                                              labelText: "Question Code",
                                              title: "",
                                              textEditingController:
                                                  questionCodeController,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10),
                                              child: InkWell(
                                                onTap: () {
                                                  quizDataProvider
                                                      .fetchQuestionListById(
                                                          questionCodeController
                                                              .text
                                                              .trim()
                                                              .toUpperCase());
                                                },
                                                child: Container(
                                                  height: 35,
                                                  width: 160,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: AppColorsInApp
                                                          .colorYellow),
                                                  child: const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.add,
                                                        size: 20,
                                                        color: AppColorsInApp
                                                            .colorWhite,
                                                      ),
                                                      SizedBox(
                                                        width: 8,
                                                      ),
                                                      Text(
                                                        "Search Question",
                                                        style: TextStyle(
                                                            color:
                                                                AppColorsInApp
                                                                    .colorWhite,
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Visibility(
                                          visible: quizDataProvider
                                              .questionList.isNotEmpty,
                                          child: Row(
                                            children: [
                                              Text(
                                                "Select All:",
                                                style: TextStyle(
                                                    color: isSelectAll
                                                        ? Colors.green[800]
                                                        : AppColorsInApp
                                                            .colorPrimary,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Checkbox(
                                                  activeColor: AppColorsInApp
                                                      .colorSecondary,
                                                  checkColor:
                                                      AppColorsInApp.colorWhite,
                                                  value: isSelectAll,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      isSelectAll =
                                                          !isSelectAll;
                                                    });
                                                    quizDataProvider
                                                        .selectAllQuestion(
                                                            val ?? false);
                                                  })
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Column(
                                    children: List.generate(
                                        quizDataProvider.questionList.length,
                                        (index) {
                                  return width < 900
                                      ? FittedBox(
                                          child: QuizQuestionListWidget(
                                          question: quizDataProvider
                                              .questionList[index],
                                          questionIndex: index,
                                          quizData: widget.quizModel,
                                          isSelected: quizDataProvider
                                              .questionList[index].isSelected,
                                          onPress: () {
                                            quizDataProvider
                                                .addNewQuestion(index);
                                          },
                                        ))
                                      : QuizQuestionListWidget(
                                          question: quizDataProvider
                                              .questionList[index],
                                          questionIndex: index,
                                          quizData: widget.quizModel,
                                          isSelected: quizDataProvider
                                              .questionList[index].isSelected,
                                          onPress: (bool value) {
                                            quizDataProvider
                                                .addNewQuestion(index);
                                          },
                                        );
                                })),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 20, top: 30),
                                  child: SaveButton(onPRess: () {
                                    if (quizCodeController.text.isNotEmpty &&
                                        quizNameController.text.isNotEmpty) {
                                      List<String> selectedQuestionList = [];
                                      for (int i = 0;
                                          i <
                                              quizDataProvider
                                                  .quizQuestionList.length;
                                          i++) {
                                        if (quizDataProvider
                                            .quizQuestionList[i].isSelected) {
                                          selectedQuestionList.add(
                                              quizDataProvider
                                                  .quizQuestionList[i]
                                                  .questionCode);
                                        }
                                      }
                                      for (int i = 0;
                                          i <
                                              quizDataProvider
                                                  .questionList.length;
                                          i++) {
                                        if (quizDataProvider
                                            .questionList[i].isSelected) {
                                          selectedQuestionList.add(
                                              quizDataProvider.questionList[i]
                                                  .questionCode);
                                        }
                                      }
                                      LoaderDialogs.showLoadingDialog();
                                      int hour =
                                          totalTimeHourController.text.isEmpty
                                              ? 0
                                              : int.parse(
                                                  totalTimeHourController.text);
                                      int minute = totalTimeMinuteController
                                              .text.isEmpty
                                          ? 0
                                          : int.parse(
                                              totalTimeMinuteController.text);
                                      int totalTime = (hour * 60) + minute;
                                      QuizModel quizModel = QuizModel(
                                          quizCodeController.text
                                              .trim()
                                              .toUpperCase(),
                                          quizNameController.text,
                                          selectedStatus,
                                          _selectedQuizType ?? stringDefault,
                                          totalTime,
                                          widget.quizModel.timeStamp,
                                          totalMarksController.text.isEmpty
                                              ? 0
                                              : int.parse(
                                                  totalMarksController.text),
                                          noDeductionController.text.isEmpty
                                              ? 0
                                              : int.parse(
                                                  noDeductionController.text),
                                          totalWrongAnswerController
                                                  .text.isEmpty
                                              ? 0
                                              : int.parse(
                                                  totalWrongAnswerController
                                                      .text),
                                          selectedQuestionList.length,
                                          selectedQuestionList);
                                      quizDataProvider
                                          .updateQuiz(
                                              quizModel, widget.quizModel.docId)
                                          .then((value) {
                                        /// remove loader
                                        Navigator.pop(context);
                                        Helper.showSnackBarMessage(
                                          msg: "Quiz updated successfully",
                                          isSuccess: true,
                                        );
                                        Navigator.pop(context);
                                      });
                                    } else {
                                      if (quizCodeController.text.isEmpty) {
                                        Helper.showSnackBarMessage(
                                          msg: "Please add quiz code",
                                          isSuccess: false,
                                        );
                                      } else if (quizNameController
                                          .text.isEmpty) {
                                        Helper.showSnackBarMessage(
                                          msg: "Please add quiz name",
                                          isSuccess: false,
                                        );
                                      } else {
                                        Helper.showSnackBarMessage(
                                          msg: "Please select quiz type",
                                          isSuccess: false,
                                        );
                                      }
                                    }
                                  }),
                                ),
                              ],
                            ),
                          ),
                        );
                      })),
                ])),
              ]);
            })),
        drawer: width < 1200
            ? const Drawer(
                child: ExtraSideBar(sidebarIndex: 8),
              )
            : null);
  }

  double getHeight(double value, double width) {
    double height = value;

    return height;
  }
}
