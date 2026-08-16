import 'package:bbarna/core/widgets/loader_dialog.dart';
import 'package:bbarna/course/model/course_model.dart';
import 'package:bbarna/course/viewModel/course_view_model.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/subject/model/subject_model.dart';
import 'package:bbarna/topic/model/topic_model.dart';
import 'package:bbarna/topic/viewModel/topic_view_model.dart';
import 'package:bbarna/units/model/unit_model.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:bbarna/core/widgets/app_header.dart';
import 'package:bbarna/core/widgets/custom_text_field.dart';
import 'package:bbarna/core/widgets/sidebar.dart';
import 'package:bbarna/core/widgets/save_button.dart';
import 'package:bbarna/resources/app_colors.dart';
import 'package:provider/provider.dart';

class AddTopic extends StatefulWidget {
  const AddTopic({super.key});

  @override
  State<AddTopic> createState() => _AddTopicState();
}

class _AddTopicState extends State<AddTopic> {
  TextEditingController topicCodeController = TextEditingController();
  TextEditingController topicNameController = TextEditingController();
  TextEditingController displayPriorityController = TextEditingController();
  String _selectedCourseCode = "";
  String? _selectedCourseName;

  String? _selectedSubjectName;
  String selectedSubjectCode = "";
  String? _selectedUnitName;
  String selectedUnitCode = "";

  final GlobalKey<ScaffoldState> key = GlobalKey();
  @override
  void initState() {
    Provider.of<CourseViewModel>(context, listen: false).getCourseList();
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
          child: Column(
            children: [
              AppHeader(
                onTapIcon: () {
                  key.currentState?.openDrawer();
                },
              ),
              Expanded(
                child: Row(
                  children: [
                    if (width > 900)
                      const Expanded(
                          child: ExtraSideBar(
                        sidebarIndex: 4,
                      )),
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
                        color: AppColorsInApp.colorGrey.withValues(alpha: .1),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                child: SingleChildScrollView(
                                  child: Consumer2<CourseViewModel,
                                      TopicViewModel>(
                                    builder: (context, courseDataProvider,
                                        topicDataProvider, child) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        "Course",
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                AppColorsInApp
                                                                    .colorGrey),
                                                      ),
                                                      IgnorePointer(
                                                        ignoring:
                                                            courseDataProvider
                                                                .courseList
                                                                .isEmpty,
                                                        child: Container(
                                                          width: 350,
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                            top: 10,
                                                            bottom: 20,
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 15,
                                                                  right: 15),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            color:
                                                                AppColorsInApp
                                                                    .colorWhite,
                                                          ),
                                                          child: DropdownButton<
                                                              String>(
                                                            value:
                                                                _selectedCourseName,
                                                            isExpanded: true,
                                                            hint: const Text(
                                                                "Select Course"),
                                                            elevation: 16,
                                                            style: const TextStyle(
                                                                color: AppColorsInApp
                                                                    .colorBlack1),
                                                            underline:
                                                                const SizedBox(),
                                                            onChanged: (String?
                                                                newValue) {
                                                              setState(() {
                                                                _selectedCourseName =
                                                                    newValue!;
                                                                CourseModel
                                                                    courseModel =
                                                                    courseDataProvider
                                                                        .courseList
                                                                        .where((element) =>
                                                                            element.name ==
                                                                            newValue)
                                                                        .first;
                                                                _selectedCourseCode =
                                                                    courseModel
                                                                        .code;
                                                                selectedSubjectCode =
                                                                    "";
                                                                _selectedSubjectName =
                                                                    null;
                                                              });

                                                              topicDataProvider
                                                                  .getSubjectList(
                                                                      courseCode:
                                                                          _selectedCourseCode);
                                                            },
                                                            items: {
                                                              for (final CourseModel value
                                                                  in courseDataProvider
                                                                      .courseList)
                                                                value.name:
                                                                    value
                                                            }.values.map<
                                                                    DropdownMenuItem<
                                                                        String>>(
                                                                (CourseModel
                                                                    value) {
                                                              return DropdownMenuItem<
                                                                  String>(
                                                                value:
                                                                    value.name,
                                                                child: Text(
                                                                    value.name),
                                                              );
                                                            }).toList(),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        "Subject",
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                AppColorsInApp
                                                                    .colorGrey),
                                                      ),
                                                      IgnorePointer(
                                                        ignoring:
                                                            (_selectedCourseCode ==
                                                                    "" ||
                                                                topicDataProvider
                                                                    .subjectList
                                                                    .isEmpty),
                                                        child: Container(
                                                          width: 350,
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                            top: 10,
                                                            bottom: 20,
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 15,
                                                                  right: 15),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            color:
                                                                AppColorsInApp
                                                                    .colorWhite,
                                                          ),
                                                          child: DropdownButton<
                                                              String>(
                                                            value:
                                                                _selectedSubjectName,
                                                            isExpanded: true,
                                                            hint: const Text(
                                                                "Select Subject"),
                                                            elevation: 16,
                                                            style: const TextStyle(
                                                                color: AppColorsInApp
                                                                    .colorBlack1),
                                                            underline:
                                                                const SizedBox(),
                                                            onChanged: (String?
                                                                newValue) {
                                                              setState(() {
                                                                _selectedSubjectName =
                                                                    newValue!;
                                                                SubjectModel
                                                                    subjectModel =
                                                                    topicDataProvider
                                                                        .subjectList
                                                                        .where((element) =>
                                                                            element.name ==
                                                                            newValue)
                                                                        .first;
                                                                selectedSubjectCode =
                                                                    subjectModel
                                                                        .code;
                                                                _selectedUnitName =
                                                                    null;
                                                                selectedUnitCode =
                                                                    "";
                                                              });
                                                              topicDataProvider
                                                                  .getUnitList(
                                                                      subjectCode:
                                                                          selectedSubjectCode);
                                                            },
                                                            items: topicDataProvider
                                                                .subjectList
                                                                .map<
                                                                        DropdownMenuItem<
                                                                            String>>(
                                                                    (SubjectModel
                                                                        value) {
                                                              return DropdownMenuItem<
                                                                  String>(
                                                                value:
                                                                    value.name,
                                                                child: Text(
                                                                    value.name),
                                                              );
                                                            }).toList(),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        "Unit",
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                AppColorsInApp
                                                                    .colorGrey),
                                                      ),
                                                      IgnorePointer(
                                                        ignoring:
                                                            (selectedSubjectCode ==
                                                                    "" ||
                                                                topicDataProvider
                                                                    .unitList
                                                                    .isEmpty),
                                                        child: Container(
                                                          width: 350,
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                            top: 10,
                                                            bottom: 20,
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 15,
                                                                  right: 15),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            color:
                                                                AppColorsInApp
                                                                    .colorWhite,
                                                          ),
                                                          child: DropdownButton<
                                                              String>(
                                                            value:
                                                                _selectedUnitName,
                                                            isExpanded: true,
                                                            hint: const Text(
                                                                "Select Unit"),
                                                            elevation: 16,
                                                            style: const TextStyle(
                                                                color: AppColorsInApp
                                                                    .colorBlack1),
                                                            underline:
                                                                const SizedBox(),
                                                            onChanged: (String?
                                                                newValue) {
                                                              setState(() {
                                                                _selectedUnitName =
                                                                    newValue!;
                                                                UnitModel
                                                                    unitModel =
                                                                    topicDataProvider
                                                                        .unitList
                                                                        .where((element) =>
                                                                            element.name ==
                                                                            newValue)
                                                                        .first;
                                                                selectedUnitCode =
                                                                    unitModel
                                                                        .code;
                                                              });
                                                            },
                                                            items: topicDataProvider
                                                                .unitList
                                                                .map<
                                                                        DropdownMenuItem<
                                                                            String>>(
                                                                    (UnitModel
                                                                        value) {
                                                              return DropdownMenuItem<
                                                                  String>(
                                                                value:
                                                                    value.name,
                                                                child: Text(
                                                                    value.name),
                                                              );
                                                            }).toList(),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (width < 900)
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 20.0),
                                                          child:
                                                              CustomTextField(
                                                            title: "Topic Code",
                                                            labelText:
                                                                "Topic Code",
                                                            textEditingController:
                                                                topicCodeController,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 20.0),
                                                          child:
                                                              CustomTextField(
                                                            title: "Topic Name",
                                                            labelText:
                                                                "Topic Name",
                                                            textEditingController:
                                                                topicNameController,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 20.0),
                                                          child:
                                                              CustomTextField(
                                                            title:
                                                                "Display Priority",
                                                            labelText:
                                                                "Display Priority",
                                                            textEditingController:
                                                                displayPriorityController,
                                                            textInputType:
                                                                TextInputType
                                                                    .number,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                              if (width > 900)
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: width > 900
                                                          ? 50
                                                          : 10),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CustomTextField(
                                                        title: "Topic Code",
                                                        labelText: "Topic Code",
                                                        textEditingController:
                                                            topicCodeController,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 20.0),
                                                        child: CustomTextField(
                                                          title: "Topic Name",
                                                          labelText:
                                                              "Topic Name",
                                                          textEditingController:
                                                              topicNameController,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 20),
                                                        child: CustomTextField(
                                                          title:
                                                              "Display Priority",
                                                          labelText:
                                                              "Display Priority",
                                                          textEditingController:
                                                              displayPriorityController,
                                                          textInputType:
                                                              TextInputType
                                                                  .number,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 30),
                                            child: SaveButton(onPRess: () {
                                              if (topicCodeController
                                                      .text.isNotEmpty &&
                                                  _selectedCourseCode != "" &&
                                                  selectedSubjectCode != "" &&
                                                  selectedUnitCode != "" &&
                                                  displayPriorityController
                                                      .text.isNotEmpty &&
                                                  topicNameController
                                                      .text.isNotEmpty) {
                                                LoaderDialogs
                                                    .showLoadingDialog();

                                                TopicModel topicModel = TopicModel(
                                                    topicCodeController.text
                                                        .trim()
                                                        .toUpperCase(),
                                                    topicNameController.text,
                                                    DateTime.now()
                                                        .millisecondsSinceEpoch,
                                                    _selectedCourseName ??
                                                        stringDefault,
                                                    _selectedCourseCode,
                                                    _selectedSubjectName ??
                                                        stringDefault,
                                                    selectedSubjectCode,
                                                    _selectedUnitName ??
                                                        stringDefault,
                                                    selectedUnitCode,
                                                    int.parse(
                                                        displayPriorityController
                                                            .text));
                                                topicDataProvider
                                                    .addTopic(topicModel)
                                                    .then((value) async {
                                                  /// for remove loader
                                                  Navigator.pop(context);
                                                  Helper.showSnackBarMessage(
                                                      msg:
                                                          "Topic added successfully",
                                                      isSuccess: true);
                                                  Navigator.pop(context);
                                                });
                                              } else {
                                                if (_selectedCourseCode == "") {
                                                  Helper.showSnackBarMessage(
                                                      msg:
                                                          "Please select a course",
                                                      isSuccess: false);
                                                } else if (selectedSubjectCode ==
                                                    "") {
                                                  Helper.showSnackBarMessage(
                                                      msg:
                                                          "Please select a subject",
                                                      isSuccess: false);
                                                } else if (selectedUnitCode ==
                                                    "") {
                                                  Helper.showSnackBarMessage(
                                                      msg:
                                                          "Please select a unit",
                                                      isSuccess: false);
                                                } else if (topicCodeController
                                                    .text.isEmpty) {
                                                  Helper.showSnackBarMessage(
                                                      msg:
                                                          "Please fill topic code",
                                                      isSuccess: false);
                                                } else if (topicNameController
                                                    .text.isEmpty) {
                                                  Helper.showSnackBarMessage(
                                                      msg:
                                                          "Please fill topic name",
                                                      isSuccess: false);
                                                } else {
                                                  Helper.showSnackBarMessage(
                                                      msg:
                                                          "Please fill display priority",
                                                      isSuccess: false);
                                                }
                                              }
                                            }),
                                          ),
                                        ],
                                      );
                                    },
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
              ),
            ],
          ),
        ),
        drawer: width < 900
            ? const Drawer(
                child: ExtraSideBar(sidebarIndex: 4),
              )
            : null);
  }
}
