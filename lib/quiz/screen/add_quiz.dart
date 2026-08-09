import 'package:bbarna/core/widgets/loader_dialog.dart';
import 'package:bbarna/quiz/model/quiz_model.dart';
import 'package:bbarna/quiz/viewModel/quiz_view_model.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:bbarna/core/widgets/app_header.dart';
import 'package:bbarna/core/widgets/sidebar.dart';
import 'package:bbarna/core/widgets/save_button.dart';
import 'package:bbarna/resources/app_colors.dart';
import 'package:bbarna/core/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

class AddQuiz extends StatefulWidget {
  const AddQuiz({super.key});

  @override
  State<AddQuiz> createState() => _AddQuizState();
}

class _AddQuizState extends State<AddQuiz> {
  TextEditingController quizCodeController = TextEditingController();
  TextEditingController totalQuestionController = TextEditingController();
  TextEditingController totalWrongAnswerController = TextEditingController();
  TextEditingController totalTimeHourController = TextEditingController();
  TextEditingController totalTimeMinuteController = TextEditingController();
  TextEditingController quizNameController = TextEditingController();
  TextEditingController totalMarksController = TextEditingController();
  TextEditingController noDeductionController = TextEditingController();
  String? _selectedQuizType;
  final List<String> _dropdownItems = ['FREE', 'PAID'];
  final GlobalKey<ScaffoldState> key = GlobalKey();
  List<String> statusList = ["UPCOMING", "LIVE", "PENDING"];
  String selectedStatus = "UPCOMING";
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
                  if (width > 900)
                    const Expanded(
                        child: ExtraSideBar(
                      sidebarIndex: 8,
                    )),
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                      ),
                      color: AppColorsInApp.colorGrey.withValues(alpha: .1),
                      child: Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(top: 20),
                        child: SingleChildScrollView(
                          child: Consumer<QuizViewModel>(
                              builder: (context, audioDataProvider, child) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                            visible: width < 900,
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
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: SaveButton(
                                      onPRess: () {
                                        if (quizCodeController
                                                .text.isNotEmpty &&
                                            _selectedQuizType != null &&
                                            quizNameController
                                                .text.isNotEmpty) {
                                          int hour = totalTimeHourController
                                                  .text.isEmpty
                                              ? 0
                                              : int.parse(
                                                  totalTimeHourController.text);
                                          int minute = totalTimeMinuteController
                                                  .text.isEmpty
                                              ? 0
                                              : int.parse(
                                                  totalTimeMinuteController
                                                      .text);
                                          int totalTime = (hour * 60) + minute;
                                          LoaderDialogs.showLoadingDialog();
                                          QuizModel quizModel = QuizModel(
                                              quizCodeController.text
                                                  .trim()
                                                  .toUpperCase(),
                                              quizNameController.text,
                                              selectedStatus,
                                              _selectedQuizType ??
                                                  stringDefault,
                                              totalTime,
                                              DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              totalMarksController.text.isEmpty
                                                  ? 0
                                                  : int.parse(
                                                      totalMarksController
                                                          .text),
                                              noDeductionController.text.isEmpty
                                                  ? 0
                                                  : int.parse(
                                                      noDeductionController
                                                          .text),
                                              totalWrongAnswerController
                                                      .text.isEmpty
                                                  ? 0
                                                  : int.parse(
                                                      totalWrongAnswerController
                                                          .text),
                                              totalQuestionController
                                                      .text.isEmpty
                                                  ? 0
                                                  : int.parse(
                                                      totalQuestionController
                                                          .text),
                                              []);
                                          quizDataProvider
                                              .addQuiz(quizModel)
                                              .then((value) {
                                            /// remove loader
                                            Navigator.pop(context);
                                            Helper.showSnackBarMessage(
                                              msg: "Quiz added successfully",
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
                                          }else if(quizNameController.text.isEmpty){
                                             Helper.showSnackBarMessage(
                                              msg: "Please add quiz name",
                                              isSuccess: false,
                                            );
                                          }else{
                                            Helper.showSnackBarMessage(
                                              msg: "Please select quiz type",
                                              isSuccess: false,
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                )
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  )
                ]))
              ]);
            })),
        drawer: width < 900
            ? const Drawer(
                child: ExtraSideBar(sidebarIndex: 8),
              )
            : null);
  }
}
