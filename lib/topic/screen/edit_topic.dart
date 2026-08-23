// ignore_for_file: must_be_immutable, use_build_context_synchronously

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

class EditTopic extends StatefulWidget {
  TopicModel topicData;
  EditTopic({required this.topicData, super.key});

  @override
  State<EditTopic> createState() => _EditTopicState();
}

class _EditTopicState extends State<EditTopic> {
  TextEditingController topicCodeController = TextEditingController();
  TextEditingController topicNameController = TextEditingController();
  TextEditingController displayPriorityController = TextEditingController();
  String? _selectedCourseName;
  String _selectedCourseCode = "";
  String? _selectedSubjectName;
  String _selectedSubjectCode = "";
  String selectedUnitCode = "";
  String? _selectedUnitName;
  final GlobalKey<ScaffoldState> key = GlobalKey();

  // --- dynamic unit code fields (horizontal, + / - controls) ---
  final List<TextEditingController> _extraUnitCodeControllers = [];

  void _addUnitCodeField() {
    setState(() {
      _extraUnitCodeControllers.add(TextEditingController());
    });
  }

  void _removeUnitCodeField(int index) {
    setState(() {
      _extraUnitCodeControllers[index].dispose();
      _extraUnitCodeControllers.removeAt(index);
    });
  }
  // --- end dynamic unit code fields ---

  @override
  void initState() {
    setState(() {
      topicCodeController.text = widget.topicData.code;
      topicNameController.text = widget.topicData.name;
      displayPriorityController.text =
          widget.topicData.displayPriority.toString();
      _selectedCourseName = widget.topicData.courseName;
      _selectedCourseCode = widget.topicData.courseCode;
      _selectedSubjectName = widget.topicData.subjectName;
      _selectedSubjectCode = widget.topicData.subjectCode;
      _selectedUnitName = widget.topicData.unitName;
      selectedUnitCode = widget.topicData.unitCode;

      // TODO: once TopicModel has a `unitCodeList` field, prefill from it
      // the same way EditUnit prefills from widget.unitData.subjectCodeList,
      // e.g.:
      // _extraUnitCodeControllers.addAll(
      //   widget.topicData.unitCodeList.isEmpty
      //       ? [TextEditingController()]
      //       : widget.topicData.unitCodeList
      //           .map((code) => TextEditingController(text: code)),
      // );
      // _extraUnitCodeControllers.add(TextEditingController());
      _extraUnitCodeControllers.addAll(
        widget.topicData.unitCodeList.isEmpty
            ? [TextEditingController()]
            : widget.topicData.unitCodeList
                .map((code) => TextEditingController(text: code)),
      );
    });

    Provider.of<CourseViewModel>(context, listen: false).getCourseList();
    TopicViewModel topicViewModel =
        Provider.of<TopicViewModel>(context, listen: false);
    topicViewModel.getSubjectList(courseCode: _selectedCourseCode);
    topicViewModel.getUnitList(subjectCode: _selectedSubjectCode);
    super.initState();
  }

  @override
  void dispose() {
    topicCodeController.dispose();
    topicNameController.dispose();
    displayPriorityController.dispose();
    for (final c in _extraUnitCodeControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _buildExtraUnitCodeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Unit Codes",
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColorsInApp.colorGrey),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (int i = 0; i < _extraUnitCodeControllers.length; i++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 130,
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: AppColorsInApp.colorWhite,
                      ),
                      child: TextField(
                        controller: _extraUnitCodeControllers[i],
                        style:
                            const TextStyle(color: AppColorsInApp.colorBlack1),
                        decoration: const InputDecoration(
                          hintText: "Code",
                          hintStyle: TextStyle(color: AppColorsInApp.colorGrey),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline,
                          color: AppColorsInApp.colorLightRed),
                      onPressed: _extraUnitCodeControllers.length > 1
                          ? () => _removeUnitCodeField(i)
                          : null,
                    ),
                  ],
                ),
              IconButton(
                icon: Icon(Icons.add_circle_outline,
                    color: AppColorsInApp.colorSecondary),
                onPressed: _addUnitCodeField,
              ),
            ],
          ),
        ),
      ],
    );
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
                                  child: Consumer2<CourseViewModel,
                                          TopicViewModel>(
                                      builder: (context, courseDataProvider,
                                          topicDataProvider, child) {
                                    return SingleChildScrollView(
                                      child: Column(
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
                                                    MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      const Text(
                                                        "Course",
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: AppColorsInApp
                                                                .colorGrey),
                                                      ),
                                                      IgnorePointer(
                                                        ignoring:
                                                            courseDataProvider
                                                                .courseList
                                                                .isEmpty,
                                                        child: Container(
                                                          width: 350,
                                                          margin: const EdgeInsets
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
                                                                    .circular(10),
                                                            color: AppColorsInApp
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
                                                                            element
                                                                                .name ==
                                                                            newValue)
                                                                        .first;
                                                                _selectedCourseCode =
                                                                    courseModel
                                                                        .code;
                                                                _selectedSubjectName =
                                                                    null;
                                                                _selectedSubjectCode =
                                                                    "";
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
                                                                value.name: value
                                                            }.values.map<
                                                                    DropdownMenuItem<
                                                                        String>>(
                                                                (CourseModel
                                                                    value) {
                                                              return DropdownMenuItem<
                                                                  String>(
                                                                value: value.name,
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
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      const Text(
                                                        "Subject",
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: AppColorsInApp
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
                                                          margin: const EdgeInsets
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
                                                                    .circular(10),
                                                            color: AppColorsInApp
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
                                                                            element
                                                                                .name ==
                                                                            newValue)
                                                                        .first;
                                                                _selectedSubjectCode =
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
                                                                          _selectedSubjectCode);
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
                                                                value: value.name,
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
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      const Text(
                                                        "Unit",
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: AppColorsInApp
                                                                .colorGrey),
                                                      ),
                                                      IgnorePointer(
                                                        ignoring:
                                                            (_selectedSubjectCode ==
                                                                    "" ||
                                                                topicDataProvider
                                                                    .unitList
                                                                    .isEmpty),
                                                        child: Container(
                                                          width: 350,
                                                          margin: const EdgeInsets
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
                                                                    .circular(10),
                                                            color: AppColorsInApp
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
                                                                            element
                                                                                .name ==
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
                                                                value: value.name,
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
                                                                  .only(
                                                                  top: 20.0),
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
                                                ],
                                              ),
                                              if (width > 900)
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left:
                                                          width > 900 ? 50 : 10),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      CustomTextField(
                                                        title: "Topic Code",
                                                        labelText: "Topic Code",
                                                        textEditingController:
                                                            topicCodeController,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                                top: 20.0),
                                                        child: CustomTextField(
                                                          title: "Topic Name",
                                                          labelText: "Topic Name",
                                                          textEditingController:
                                                              topicNameController,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                                top: 20),
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
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20.0,bottom: 20),
                                              child: _buildExtraUnitCodeFields(),
                                            ),
                                          ),
                                          SaveButton(onPRess: () async {
                                            if (topicCodeController
                                                    .text.isNotEmpty &&
                                                _selectedCourseCode != "" &&
                                                _selectedSubjectCode != "" &&
                                                selectedUnitCode != "" &&
                                                displayPriorityController
                                                    .text.isNotEmpty &&
                                                topicNameController
                                                    .text.isNotEmpty) {
                                              LoaderDialogs.showLoadingDialog();
                                      
                                              final List<String> unitCodeList =
                                                  _extraUnitCodeControllers
                                                      .map((c) => c.text
                                                          .trim()
                                                          .toUpperCase())
                                                      .where((v) => v.isNotEmpty)
                                                      .toList();
                                      
                                              TopicModel unitData = TopicModel(
                                                  topicCodeController.text
                                                      .trim()
                                                      .toUpperCase(),
                                                  topicNameController.text,
                                                  widget.topicData.timeStamp,
                                                  _selectedCourseName ??
                                                      stringDefault,
                                                  _selectedCourseCode,
                                                  _selectedSubjectName ??
                                                      stringDefault,
                                                  _selectedSubjectCode,
                                                  _selectedUnitName ??
                                                      stringDefault,
                                                  selectedUnitCode,
                                                  int.parse(
                                                      displayPriorityController
                                                          .text),
                                                  unitCodeList);
                                              // TODO: once TopicModel has a
                                              // `unitCodeList` field, pass
                                              // it into the constructor above,
                                              // e.g. ..., unitCodeList);
                                              await topicDataProvider
                                                  .updateTopic(unitData,
                                                      widget.topicData.docId)
                                                  .then((value) async {
                                                /// remove loader
                                                Navigator.pop(context);
                                                Helper.showSnackBarMessage(
                                                    msg:
                                                        "Topic updated successfully",
                                                    isSuccess: true);
                                                Navigator.pop(context);
                                              });
                                            } else {
                                              if (_selectedCourseCode == "") {
                                                Helper.showSnackBarMessage(
                                                    msg: "Please select a course",
                                                    isSuccess: false);
                                              } else if (_selectedSubjectCode ==
                                                  "") {
                                                Helper.showSnackBarMessage(
                                                    msg:
                                                        "Please select a subject",
                                                    isSuccess: false);
                                              } else if (selectedUnitCode == "") {
                                                Helper.showSnackBarMessage(
                                                    msg: "Please select a unit",
                                                    isSuccess: false);
                                              } else if (topicCodeController
                                                  .text.isEmpty) {
                                                Helper.showSnackBarMessage(
                                                    msg: "Please fill topic code",
                                                    isSuccess: false);
                                              } else if (topicNameController
                                                  .text.isEmpty) {
                                                Helper.showSnackBarMessage(
                                                    msg: "Please fill topic name",
                                                    isSuccess: false);
                                              } else {
                                                Helper.showSnackBarMessage(
                                                    msg:
                                                        "Please fill display priority",
                                                    isSuccess: false);
                                              }
                                            }
                                          }),
                                        ],
                                      ),
                                    );
                                  })),
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
