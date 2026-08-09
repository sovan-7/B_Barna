// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:bbarna/core/widgets/choose_image.dart';
import 'package:bbarna/core/widgets/loader_dialog.dart';
import 'package:bbarna/course/model/course_model.dart';
import 'package:bbarna/course/viewModel/course_view_model.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/subject/model/subject_model.dart';
import 'package:bbarna/subject/viewModel/subject_view_model.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:bbarna/core/widgets/app_header.dart';
import 'package:bbarna/core/widgets/custom_text_field.dart';
import 'package:bbarna/core/widgets/sidebar.dart';
import 'package:bbarna/core/widgets/save_button.dart';
import 'package:bbarna/resources/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

class AddSubject extends StatefulWidget {
  const AddSubject({super.key});

  @override
  State<AddSubject> createState() => _AddSubjectState();
}

class _AddSubjectState extends State<AddSubject> {
  Uint8List? selectedImageBytes;
  String imageName = "";
  CourseViewModel _courseViewModel = CourseViewModel();
  SubjectViewModel _subjectViewModel = SubjectViewModel();

  TextEditingController subjectCodeController = TextEditingController();
  TextEditingController subjectNameController = TextEditingController();
  TextEditingController subjectDescriptionController = TextEditingController();
  TextEditingController displayPriorityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController sellingPriceController = TextEditingController();

  String? _selectedCourseValue;
  String? _selectedCourseType;

  final GlobalKey<ScaffoldState> key = GlobalKey();
  bool willShow = false;
  bool isLocked = false;
  bool isPopular = false;
  List<String> courseTypeList = ["Full Course", "Part Course", "Mock Test"];
  @override
  void initState() {
    _courseViewModel = Provider.of<CourseViewModel>(context, listen: false);
    _courseViewModel.getCourseList();
    _subjectViewModel = Provider.of<SubjectViewModel>(context, listen: false);
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
                        sidebarIndex: 2,
                      )),
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
                        color: AppColorsInApp.colorGrey.withOpacity(0.1),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                child: SingleChildScrollView(
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
                                                  Container(
                                                    width: 350,
                                                    margin:
                                                        const EdgeInsets.only(
                                                      top: 10,
                                                      bottom: 20,
                                                    ),
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 15,
                                                            right: 15),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color: AppColorsInApp
                                                          .colorWhite,
                                                    ),
                                                    child:
                                                        DropdownButton<String>(
                                                      value:
                                                          _selectedCourseValue,
                                                      isExpanded: true,
                                                      elevation: 16,
                                                      hint: const Text(
                                                          "Select Course"),
                                                      style: const TextStyle(
                                                          color: AppColorsInApp
                                                              .colorBlack1),
                                                      underline: Container(),
                                                      onChanged:
                                                          (String? newValue) {
                                                        setState(() {
                                                          _selectedCourseValue =
                                                              newValue!;
                                                        });
                                                      },
                                                      items: _courseViewModel
                                                          .courseList
                                                          .map<
                                                                  DropdownMenuItem<
                                                                      String>>(
                                                              (CourseModel
                                                                  value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value.name,
                                                          child:
                                                              Text(value.name),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              CustomTextField(
                                                title: "Subject Code",
                                                labelText: "Subject code",
                                                textEditingController:
                                                    subjectCodeController,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20.0),
                                                child: CustomTextField(
                                                  title: "Subject Name",
                                                  labelText: "Subject Name",
                                                  textEditingController:
                                                      subjectNameController,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      "Course Type",
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: AppColorsInApp
                                                              .colorGrey),
                                                    ),
                                                    Container(
                                                      width: 350,
                                                      margin:
                                                          const EdgeInsets.only(
                                                        top: 10,
                                                        //bottom: 20,
                                                      ),
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 15,
                                                              right: 15),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color: AppColorsInApp
                                                            .colorWhite,
                                                      ),
                                                      child: DropdownButton<
                                                          String>(
                                                        value:
                                                            _selectedCourseType,
                                                        elevation: 16,
                                                        hint: const Text(
                                                            "Select Course Type"),
                                                        isExpanded: true,
                                                        style: const TextStyle(
                                                            color: AppColorsInApp
                                                                .colorBlack1),
                                                        underline: Container(),
                                                        onChanged:
                                                            (String? newValue) {
                                                          setState(() {
                                                            _selectedCourseType =
                                                                newValue!;
                                                          });
                                                        },
                                                        items: courseTypeList
                                                            .map(
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 25.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        "is Popular:  ",
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                AppColorsInApp
                                                                    .colorGrey),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      ToggleSwitch(
                                                        minWidth: 90.0,
                                                        cornerRadius: 20.0,
                                                        activeBgColors: [
                                                          const [
                                                            AppColorsInApp
                                                                .colorLightRed
                                                          ],
                                                          [
                                                            AppColorsInApp
                                                                .colorSecondary!
                                                          ],
                                                        ],
                                                        activeFgColor:
                                                            Colors.white,
                                                        inactiveBgColor:
                                                            Colors.grey,
                                                        inactiveFgColor:
                                                            Colors.white,
                                                        initialLabelIndex:
                                                            isPopular ? 1 : 0,
                                                        totalSwitches: 2,
                                                        labels: const [
                                                          'NO',
                                                          'YES'
                                                        ],
                                                        radiusStyle: true,
                                                        onToggle: (index) {
                                                          setState(() {
                                                            if (index == 0) {
                                                              isPopular = false;
                                                            } else {
                                                              isPopular = true;
                                                            }
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  )),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text("Subject Image",
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: AppColorsInApp
                                                                .colorGrey)),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 0),
                                                      child: Row(
                                                        children: [
                                                          ChooseImage(
                                                              onSelectImage:
                                                                  () async {
                                                            var picked =
                                                                await FilePicker
                                                                    .platform
                                                                    .pickFiles(
                                                              type: FileType
                                                                  .image,
                                                            );

                                                            if (picked !=
                                                                null) {
                                                              setState(() {
                                                                selectedImageBytes =
                                                                    picked
                                                                        .files
                                                                        .first
                                                                        .bytes;
                                                                imageName =
                                                                    picked
                                                                        .files
                                                                        .first
                                                                        .name;
                                                              });
                                                            }
                                                          }),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 8.0),
                                                            child: Text(
                                                                imageName.isEmpty
                                                                    ? "No file chosen"
                                                                    : imageName,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    color: AppColorsInApp
                                                                        .colorBlack1)),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (width < 900)
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 20.0),
                                                      child: CustomTextField(
                                                        title:
                                                            "Subject Description",
                                                        labelText:
                                                            "Subject Description",
                                                        textEditingController:
                                                            subjectDescriptionController,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
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
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        top: 20.0,
                                                      ),
                                                      child: CustomTextField(
                                                        title: "Subject Price",
                                                        labelText:
                                                            "Subject Price",
                                                        textEditingController:
                                                            priceController,
                                                        textInputType:
                                                            TextInputType
                                                                .number,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 25.0),
                                                      child: CustomTextField(
                                                        title: "Selling Price",
                                                        labelText:
                                                            "Selling Price",
                                                        textEditingController:
                                                            sellingPriceController,
                                                      ),
                                                    ),
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 25.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "Will display:  ",
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: AppColorsInApp
                                                                      .colorGrey),
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            ToggleSwitch(
                                                              minWidth: 90.0,
                                                              cornerRadius:
                                                                  20.0,
                                                              activeBgColors: [
                                                                const [
                                                                  AppColorsInApp
                                                                      .colorLightRed
                                                                ],
                                                                [
                                                                  AppColorsInApp
                                                                      .colorSecondary!
                                                                ],
                                                              ],
                                                              activeFgColor:
                                                                  Colors.white,
                                                              inactiveBgColor:
                                                                  Colors.grey,
                                                              inactiveFgColor:
                                                                  Colors.white,
                                                              initialLabelIndex:
                                                                  willShow
                                                                      ? 1
                                                                      : 0,
                                                              totalSwitches: 2,
                                                              labels: const [
                                                                'NO',
                                                                'YES'
                                                              ],
                                                              radiusStyle: true,
                                                              onToggle:
                                                                  (index) {
                                                                setState(() {
                                                                  if (index ==
                                                                      0) {
                                                                    willShow =
                                                                        false;
                                                                  } else {
                                                                    willShow =
                                                                        true;
                                                                  }
                                                                });
                                                              },
                                                            ),
                                                          ],
                                                        )),
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 25.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "Is Locked:  ",
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: AppColorsInApp
                                                                      .colorGrey),
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            ToggleSwitch(
                                                              minWidth: 90.0,
                                                              cornerRadius:
                                                                  20.0,
                                                              activeBgColors: [
                                                                const [
                                                                  AppColorsInApp
                                                                      .colorLightRed
                                                                ],
                                                                [
                                                                  AppColorsInApp
                                                                      .colorSecondary!
                                                                ],
                                                              ],
                                                              activeFgColor:
                                                                  Colors.white,
                                                              inactiveBgColor:
                                                                  Colors.grey,
                                                              inactiveFgColor:
                                                                  Colors.white,
                                                              initialLabelIndex:
                                                                  isLocked
                                                                      ? 1
                                                                      : 0,
                                                              totalSwitches: 2,
                                                              labels: const [
                                                                'NO',
                                                                'YES'
                                                              ],
                                                              radiusStyle: true,
                                                              onToggle:
                                                                  (index) {
                                                                setState(() {
                                                                  if (index ==
                                                                      0) {
                                                                    isLocked =
                                                                        false;
                                                                  } else {
                                                                    isLocked =
                                                                        true;
                                                                  }
                                                                });
                                                              },
                                                            ),
                                                          ],
                                                        )),
                                                  ],
                                                ),
                                            ],
                                          ),
                                          if (width > 900)
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: width > 900 ? 50 : 10),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  CustomTextField(
                                                    title:
                                                        "Subject Description",
                                                    labelText:
                                                        "Subject Description",
                                                    textEditingController:
                                                        subjectDescriptionController,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 20.0),
                                                    child: CustomTextField(
                                                      title: "Display Priority",
                                                      labelText:
                                                          "Display Priority",
                                                      textEditingController:
                                                          displayPriorityController,
                                                      textInputType:
                                                          TextInputType.number,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 20.0),
                                                    child: CustomTextField(
                                                      title: "Subject Price",
                                                      labelText:
                                                          "Subject Price",
                                                      textEditingController:
                                                          priceController,
                                                      textInputType:
                                                          TextInputType.number,
                                                    ),
                                                  ),
                                                   Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 25.0),
                                                      child: CustomTextField(
                                                        title: "Selling Price",
                                                        labelText:
                                                            "Selling Price",
                                                        textEditingController:
                                                            sellingPriceController,
                                                      ),
                                                    ),
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 25.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            "Will display:  ",
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: AppColorsInApp
                                                                    .colorGrey),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          ToggleSwitch(
                                                            minWidth: 90.0,
                                                            cornerRadius: 20.0,
                                                            activeBgColors: [
                                                              const [
                                                                AppColorsInApp
                                                                    .colorLightRed
                                                              ],
                                                              [
                                                                AppColorsInApp
                                                                    .colorSecondary!
                                                              ],
                                                            ],
                                                            activeFgColor:
                                                                Colors.white,
                                                            inactiveBgColor:
                                                                Colors.grey,
                                                            inactiveFgColor:
                                                                Colors.white,
                                                            initialLabelIndex:
                                                                willShow
                                                                    ? 1
                                                                    : 0,
                                                            totalSwitches: 2,
                                                            labels: const [
                                                              'NO',
                                                              'YES'
                                                            ],
                                                            radiusStyle: true,
                                                            onToggle: (index) {
                                                              setState(() {
                                                                if (index ==
                                                                    0) {
                                                                  willShow =
                                                                      false;
                                                                } else {
                                                                  willShow =
                                                                      true;
                                                                }
                                                              });
                                                            },
                                                          ),
                                                        ],
                                                      )),
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 25.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            "Is Locked:  ",
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: AppColorsInApp
                                                                    .colorGrey),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          ToggleSwitch(
                                                            minWidth: 90.0,
                                                            cornerRadius: 20.0,
                                                            activeBgColors: [
                                                              const [
                                                                AppColorsInApp
                                                                    .colorLightRed
                                                              ],
                                                              [
                                                                AppColorsInApp
                                                                    .colorSecondary!
                                                              ],
                                                            ],
                                                            activeFgColor:
                                                                Colors.white,
                                                            inactiveBgColor:
                                                                Colors.grey,
                                                            inactiveFgColor:
                                                                Colors.white,
                                                            initialLabelIndex:
                                                                isLocked
                                                                    ? 1
                                                                    : 0,
                                                            totalSwitches: 2,
                                                            labels: const [
                                                              'NO',
                                                              'YES'
                                                            ],
                                                            radiusStyle: true,
                                                            onToggle: (index) {
                                                              setState(() {
                                                                if (index ==
                                                                    0) {
                                                                  isLocked =
                                                                      false;
                                                                } else {
                                                                  isLocked =
                                                                      true;
                                                                }
                                                              });
                                                            },
                                                          ),
                                                        ],
                                                      )),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 30),
                                        child: SaveButton(onPRess: () async {
                                          if (subjectCodeController.text.isNotEmpty &&
                                              subjectNameController
                                                  .text.isNotEmpty &&
                                              selectedImageBytes != null &&
                                              priceController.text.isNotEmpty &&
                                              sellingPriceController
                                                  .text.isNotEmpty &&
                                              displayPriorityController
                                                  .text.isNotEmpty &&
                                              _selectedCourseType != null &&
                                              _selectedCourseValue != null) {
                                            LoaderDialogs.showLoadingDialog();
                                            String courseCode = _courseViewModel
                                                .courseList
                                                .where((element) =>
                                                    element.name ==
                                                    _selectedCourseValue)
                                                .first
                                                .code;
                                            SubjectModel subjectData =
                                                SubjectModel(
                                                    courseCode,
                                                    _selectedCourseType ??
                                                        stringDefault,
                                                    _selectedCourseValue ??
                                                        stringDefault,
                                                    double.parse(
                                                        priceController.text),
                                                    double.parse(
                                                        sellingPriceController
                                                            .text),
                                                    subjectCodeController.text
                                                        .trim()
                                                        .toUpperCase(),
                                                    subjectDescriptionController
                                                        .text,
                                                    subjectNameController.text,
                                                    "",
                                                    int.parse(
                                                        displayPriorityController
                                                            .text),
                                                    DateTime.now()
                                                        .millisecondsSinceEpoch,
                                                    willShow,
                                                    isLocked,
                                                    isPopular);
                                            await _subjectViewModel
                                                .addSubject(subjectData)
                                                .then((value) async {
                                              await _subjectViewModel
                                                  .uploadSubjectImage(
                                                      selectedImageBytes!,
                                                      subjectCodeController
                                                          .text,
                                                      value.id);
                                              Navigator.pop(context);
                                              Helper.showSnackBarMessage(
                                                  msg:
                                                      "Subject added successfully",
                                                  isSuccess: true);
                                              Navigator.pop(context);
                                            });
                                          } else {
                                            if (_selectedCourseValue == null) {
                                              Helper.showSnackBarMessage(
                                                  msg: "Please select a course",
                                                  isSuccess: false);
                                            } else if (subjectCodeController
                                                .text.isEmpty) {
                                              Helper.showSnackBarMessage(
                                                  msg:
                                                      "Please fill subject code",
                                                  isSuccess: false);
                                            } else if (subjectNameController
                                                .text.isEmpty) {
                                              Helper.showSnackBarMessage(
                                                  msg:
                                                      "Please fill subject name",
                                                  isSuccess: false);
                                            } else if (_selectedCourseType ==
                                                null) {
                                              Helper.showSnackBarMessage(
                                                  msg:
                                                      "Please fill course type",
                                                  isSuccess: false);
                                            } else if (priceController
                                                .text.isEmpty||sellingPriceController
                                                .text.isEmpty) {
                                              Helper.showSnackBarMessage(
                                                  msg: "Please fill price",
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
                child: ExtraSideBar(sidebarIndex: 2),
              )
            : null);
  }
}
