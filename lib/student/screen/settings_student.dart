// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:bbarna/core/widgets/remove_alert.dart';
import 'package:bbarna/core/widgets/save_button.dart';
import 'package:bbarna/course/model/course_model.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/student/screen/edit_enrolled_unit.dart';
import 'package:bbarna/student/screen/enrolled_unit_list.dart';
import 'package:bbarna/student/viewModel/student_viewmodel.dart';
import 'package:bbarna/subject/model/subject_model.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:bbarna/core/widgets/app_header.dart';
import 'package:bbarna/core/widgets/sidebar.dart';
import 'package:bbarna/utils/size_config.dart';
import 'package:bbarna/resources/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SettingStudent extends StatefulWidget {
  String studentId;
  String studentName;
  SettingStudent(
      {required this.studentId, required this.studentName, super.key});

  @override
  State<SettingStudent> createState() => _SettingStudentState();
}

class _SettingStudentState extends State<SettingStudent> {
  String? _selectedCourseName;
  String _selectedCourseCode = "";
  String _selectedSubjectCode = "";
  String? _selectedSubjectName;
  String _selectedSubjectImage = "";

  final GlobalKey<ScaffoldState> key = GlobalKey();
  String date = "";
  int timeStamp = intDefault;
  bool dateDifference = true;
  @override
  void initState() {
    StudentViewModel studentViewModel =
        Provider.of<StudentViewModel>(context, listen: false);
    studentViewModel.clearStudentData();
    studentViewModel.getEnrolledCourseList(widget.studentId);
    studentViewModel.getCourseList();

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
              Consumer<StudentViewModel>(
                  builder: (BuildContext context, studentVM, Widget? child) {
                return Expanded(
                  child: Row(
                    children: [
                      if (width > 900)
                        const Expanded(
                            child: ExtraSideBar(
                          sidebarIndex: 10,
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Consumer<StudentViewModel>(
                                        builder: (context, studentVM, child) {
                                      return SingleChildScrollView(
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 30),
                                                child: Text(
                                                  widget.studentName,
                                                  style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColorsInApp
                                                          .colorPrimary),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
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
                                                            CrossAxisAlignment
                                                                .start,
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
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: AppColorsInApp
                                                                          .colorGrey),
                                                                ),
                                                                IgnorePointer(
                                                                    ignoring: studentVM
                                                                        .courseList
                                                                        .isEmpty,
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          350,
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                        top: 10,
                                                                        bottom:
                                                                            20,
                                                                      ),
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              15,
                                                                          right:
                                                                              15),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                        color: AppColorsInApp
                                                                            .colorWhite,
                                                                      ),
                                                                      child: DropdownButton<
                                                                          String>(
                                                                        value:
                                                                            _selectedCourseName,
                                                                        hint: const Text(
                                                                            "Select Course"),
                                                                        isExpanded:
                                                                            true,
                                                                        elevation:
                                                                            16,
                                                                        style: const TextStyle(
                                                                            color:
                                                                                AppColorsInApp.colorBlack1),
                                                                        underline:
                                                                            const SizedBox(),
                                                                        onChanged:
                                                                            (String?
                                                                                newValue) async {
                                                                          setState(
                                                                              () {
                                                                            _selectedCourseName =
                                                                                newValue!;
                                                                            _selectedSubjectImage =
                                                                                studentVM.courseList.where((element) => element.name == _selectedCourseName).first.image;
                                                                            _selectedCourseCode =
                                                                                studentVM.courseList.where((element) => element.name == _selectedCourseName).first.code;
                                                                            _selectedSubjectCode =
                                                                                "";
                                                                            _selectedSubjectName =
                                                                                null;
                                                                          });
                                                                          studentVM
                                                                              .clearUnitList();
                                                                          await studentVM
                                                                              .getSubjectList(_selectedCourseCode);
                                                                        },
                                                                        items: {
                                                                          for (final CourseModel? value
                                                                              in studentVM.courseList)
                                                                            value!.name: value
                                                                        }.values.map<
                                                                            DropdownMenuItem<
                                                                                String>>((CourseModel?
                                                                            value) {
                                                                          return DropdownMenuItem<
                                                                              String>(
                                                                            value:
                                                                                value?.name,
                                                                            child:
                                                                                Text(value!.name.trim()),
                                                                          );
                                                                        }).toList(),
                                                                      ),
                                                                    ))
                                                              ]),
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
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: AppColorsInApp
                                                                          .colorGrey),
                                                                ),
                                                                IgnorePointer(
                                                                    ignoring: studentVM
                                                                        .courseList
                                                                        .isEmpty,
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          350,
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                        top: 10,
                                                                        bottom:
                                                                            20,
                                                                      ),
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              15,
                                                                          right:
                                                                              15),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                        color: AppColorsInApp
                                                                            .colorWhite,
                                                                      ),
                                                                      child: DropdownButton<
                                                                          String>(
                                                                        isExpanded:
                                                                            true,
                                                                        value:
                                                                            _selectedSubjectName,
                                                                        elevation:
                                                                            16,
                                                                        style: const TextStyle(
                                                                            color:
                                                                                AppColorsInApp.colorBlack1,
                                                                            overflow: TextOverflow.ellipsis),
                                                                        hint: const Text(
                                                                            "Select Subject"),
                                                                        underline:
                                                                            const SizedBox(),
                                                                        onChanged:
                                                                            (String?
                                                                                newValue) async {
                                                                          setState(
                                                                              () {
                                                                            _selectedSubjectName =
                                                                                newValue!;
                                                                            _selectedSubjectCode =
                                                                                studentVM.subjectList.where((element) => element.name == _selectedSubjectName).first.code;
                                                                          });
                                                                          studentVM
                                                                              .clearUnitList();
                                                                          await studentVM.getUnitList(
                                                                              subjectCode: _selectedSubjectCode);
                                                                        },
                                                                        items: studentVM
                                                                            .subjectList
                                                                            .map<DropdownMenuItem<String>>((SubjectModel?
                                                                                value) {
                                                                          return DropdownMenuItem<
                                                                              String>(
                                                                            value:
                                                                                value?.name,
                                                                            child:
                                                                                Text(value!.name),
                                                                          );
                                                                        }).toList(),
                                                                      ),
                                                                    )),
                                                              ]),
                                                        ]),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 30,
                                                              top: 30),
                                                      child: Column(
                                                        children: [
                                                          InkWell(
                                                            onTap: () async {
                                                              showGeneralDialog(
                                                                context:
                                                                    context,
                                                                barrierLabel:
                                                                    "Barrier",
                                                                barrierDismissible:
                                                                    true,
                                                                barrierColor: Colors
                                                                    .transparent,
                                                                transitionDuration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            500),
                                                                pageBuilder: (_,
                                                                    __, ___) {
                                                                  return const Center(
                                                                      child:
                                                                          EnrolledUnitList());
                                                                },
                                                                transitionBuilder:
                                                                    (_,
                                                                        anim,
                                                                        __,
                                                                        child) {
                                                                  Tween<Offset>
                                                                      tween;
                                                                  if (anim.status ==
                                                                      AnimationStatus
                                                                          .reverse) {
                                                                    tween = Tween(
                                                                        begin: const Offset(
                                                                            -1,
                                                                            0),
                                                                        end: Offset
                                                                            .zero);
                                                                  } else {
                                                                    tween = Tween(
                                                                        begin: const Offset(
                                                                            1,
                                                                            0),
                                                                        end: Offset
                                                                            .zero);
                                                                  }

                                                                  return SlideTransition(
                                                                    position: tween
                                                                        .animate(
                                                                            anim),
                                                                    child:
                                                                        FadeTransition(
                                                                      opacity:
                                                                          anim,
                                                                      child:
                                                                          child,
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            child: Container(
                                                              width: 350,
                                                              height: 45,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 15,
                                                                      right:
                                                                          15),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: AppColorsInApp
                                                                    .colorWhite,
                                                              ),
                                                              child: Text(
                                                                studentVM.selectedUnitLength !=
                                                                        0
                                                                    ? "${studentVM.selectedUnitLength} units selected"
                                                                    : "Select Unit",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: AppColorsInApp
                                                                        .colorBlack1),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 60,
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              selectDate(
                                                                  context);
                                                            },
                                                            child: Container(
                                                              width: 350,
                                                              height: 45,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 15,
                                                                      right:
                                                                          15),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: AppColorsInApp
                                                                    .colorWhite,
                                                              ),
                                                              child: Text(
                                                                date != ""
                                                                    ? "Valid Till $date"
                                                                    : "Valid Till",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: AppColorsInApp
                                                                        .colorBlack1),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ]),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 30, bottom: 30),
                                                child: SaveButton(onPRess: () {
                                                  if (_selectedSubjectCode !=
                                                          "" &&
                                                      _selectedSubjectName !=
                                                          null &&
                                                      _selectedSubjectImage !=
                                                          "" &&
                                                      timeStamp != intDefault) {
                                                    studentVM.enrolledCourse(
                                                        _selectedSubjectCode,
                                                        _selectedSubjectName!,
                                                        _selectedSubjectImage,
                                                        timeStamp,
                                                        widget.studentId,
                                                        widget.studentName);
                                                  } else {
                                                    Helper.showSnackBarMessage(
                                                        msg:
                                                            "Please fill the above field",
                                                        isSuccess: false);
                                                  }
                                                }),
                                              ),
                                              if (studentVM
                                                      .enrolledCourseBaseModel !=
                                                  null)
                                                Column(
                                                  children: [
                                                    const Text(
                                                      "Enrolled Courses:",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: AppColorsInApp
                                                              .colorBlack1),
                                                    ),
                                                    Column(
                                                      children: List.generate(
                                                          studentVM
                                                              .enrolledCourseBaseModel!
                                                              .enrolledCourseList
                                                              .length, (index) {
                                                        String date = getData(studentVM
                                                            .enrolledCourseBaseModel!
                                                            .enrolledCourseList[
                                                                index]
                                                            .accessTill);
                                                        return Container(
                                                          height: 70,
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 8,
                                                                  horizontal:
                                                                      12),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      12),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            color: AppColorsInApp
                                                                .colorOrange
                                                                .withValues(
                                                                    alpha: 0.1),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                    child: Image
                                                                        .network(
                                                                      studentVM
                                                                          .enrolledCourseBaseModel!
                                                                          .enrolledCourseList[
                                                                              index]
                                                                          .subjectImage,
                                                                      height:
                                                                          50,
                                                                      width: 50,
                                                                      fit: BoxFit
                                                                          .fill,
                                                                      errorBuilder: (context,
                                                                          error,
                                                                          stackTrace) {
                                                                        return Image
                                                                            .asset(
                                                                          "assets/images/logo.png",
                                                                          height:
                                                                              60,
                                                                          width:
                                                                              60,
                                                                          fit: BoxFit
                                                                              .fill,
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 15,
                                                                  ),
                                                                  Text(
                                                                    studentVM
                                                                        .enrolledCourseBaseModel!
                                                                        .enrolledCourseList[
                                                                            index]
                                                                        .subjectName,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .normal,
                                                                        letterSpacing:
                                                                            0.5,
                                                                        color: AppColorsInApp
                                                                            .colorBlack1),
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              5,
                                                                          horizontal:
                                                                              10),
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(
                                                                              3),
                                                                          color: AppColorsInApp.colorBlue.withValues(
                                                                              alpha:
                                                                                  0.5)),
                                                                      child: Text(
                                                                          "Total Unit: ${studentVM.enrolledCourseBaseModel!.enrolledCourseList[index].unitCodeList.length}")),
                                                                  const SizedBox(
                                                                    width: 15,
                                                                  ),
                                                                  InkWell(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        dateDifference =
                                                                            !dateDifference;
                                                                      });
                                                                    },
                                                                    child: Container(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                5,
                                                                            horizontal:
                                                                                10),
                                                                        decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(
                                                                                3),
                                                                            color: AppColorsInApp
                                                                                .colorYellow),
                                                                        child: Text(
                                                                            "Validity Till: $date")),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 25,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      InkWell(
                                                                        onTap:
                                                                            () async {
                                                                          RemoveAlert.showRemoveAlert(
                                                                              title: "Edit Unit",
                                                                              description: "Are you sure want to edit ?",
                                                                              onPressYes: () {
                                                                                Navigator.pop(context);
                                                                                studentVM.setEditedUnitList(studentVM.enrolledCourseBaseModel!.enrolledCourseList[index].subjectCode);
                                                                                showGeneralDialog(
                                                                                  context: context,
                                                                                  barrierLabel: "Barrier",
                                                                                  barrierDismissible: true,
                                                                                  barrierColor: Colors.transparent,
                                                                                  transitionDuration: const Duration(milliseconds: 500),
                                                                                  pageBuilder: (_, __, ___) {
                                                                                    return const Center(child: EditEnrolledUnit());
                                                                                  },
                                                                                  transitionBuilder: (_, anim, __, child) {
                                                                                    Tween<Offset> tween;
                                                                                    if (anim.status == AnimationStatus.reverse) {
                                                                                      tween = Tween(begin: const Offset(-1, 0), end: Offset.zero);
                                                                                    } else {
                                                                                      tween = Tween(begin: const Offset(1, 0), end: Offset.zero);
                                                                                    }

                                                                                    return SlideTransition(
                                                                                      position: tween.animate(anim),
                                                                                      child: FadeTransition(
                                                                                        opacity: anim,
                                                                                        child: child,
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                );
                                                                              });
                                                                        },
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .edit,
                                                                          size:
                                                                              22,
                                                                          color:
                                                                              AppColorsInApp.colorYellow,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            25,
                                                                      ),
                                                                      InkWell(
                                                                        onTap:
                                                                            () async {
                                                                          RemoveAlert.showRemoveAlert(
                                                                              title: "Remove Course",
                                                                              description: "Are you sure want to delete ?",
                                                                              onPressYes: () {
                                                                                studentVM.removeCourse(studentVM.enrolledCourseBaseModel!.enrolledCourseList[index].subjectCode).then((value) {
                                                                                  studentVM.getEnrolledCourseList(widget.studentId);
                                                                                });
                                                                              });
                                                                        },
                                                                        child:
                                                                            const Icon(
                                                                          Icons
                                                                              .delete,
                                                                          size:
                                                                              22,
                                                                          color:
                                                                              AppColorsInApp.colorPrimary,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }),
                                                    )
                                                  ],
                                                ),
                                            ]),
                                      );
                                    }),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        drawer: SizeConfig.screenWidth! < 900
            ? const Drawer(
                child: ExtraSideBar(sidebarIndex: 10),
              )
            : null);
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        timeStamp = picked.millisecondsSinceEpoch;
        date = DateFormat("dd/MM/yyyy").format(picked);
      });
    }
  }

  String getData(int timestamps) {
    String accessTill = "";
    if (dateDifference) {
      accessTill = fetchDate(timestamps);
    } else {
      accessTill = calculateDaysAndMonthsLeft(timestamps);
    }
    return accessTill;
  }

  String fetchDate(int timestamps) {
    String validity = "Invalid Data";
    try {
      if (timestamps.toString().length > 10) {
        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamps);
        validity = DateFormat("dd/MM/yyyy").format(dateTime);
      }
    } catch (e) {
      log(e.toString());
    }
    return validity;
  }

  String calculateDaysAndMonthsLeft(int timestamps) {
    String duration = "Invalid Data";
    try {
      if (timestamps.toString().length > 10) {
        DateTime targetDate = DateTime.fromMillisecondsSinceEpoch(timestamps);
        DateTime currentDate = DateTime.now();
        Duration difference = targetDate.difference(currentDate);
        int daysLeft = difference.inDays;
        int monthsLeft = (daysLeft ~/ 30);
        int yearLeft = (monthsLeft % 12);
        daysLeft = (daysLeft % 30);
        if (daysLeft > 0) {
          duration = "$daysLeft Days Left";
        }
        if (monthsLeft > 0) {
          duration = "$monthsLeft Months $daysLeft Days Left";
        }
        if (yearLeft > 0) {
          duration = "$yearLeft Year $monthsLeft Months $daysLeft Days Left";
        }
      }
    } catch (e) {
      log(e.toString());
    }
    return duration;
  }
}
