// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:bbarna/core/widgets/loader_dialog.dart';
import 'package:bbarna/core/widgets/app_header.dart';
import 'package:bbarna/core/widgets/choose_image.dart';
import 'package:bbarna/core/widgets/custom_text_field.dart';
import 'package:bbarna/core/widgets/sidebar.dart';
import 'package:bbarna/core/widgets/save_button.dart';
import 'package:bbarna/course/model/course_model.dart';
import 'package:bbarna/course/viewModel/course_view_model.dart';
import 'package:bbarna/resources/app_colors.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

class AddCourse extends StatefulWidget {
  const AddCourse({super.key});

  @override
  State<AddCourse> createState() => _AddCourseState();
}

class _AddCourseState extends State<AddCourse> {
  Uint8List? selectedImageBytes;
  String imageName = "";
  CourseViewModel courseViewModel = CourseViewModel();
  final GlobalKey<ScaffoldState> key = GlobalKey();
  TextEditingController courseCodeController = TextEditingController();
  TextEditingController courseNameController = TextEditingController();
  TextEditingController courseDescriptionController = TextEditingController();
  TextEditingController displayPriorityController = TextEditingController();
  bool willShow = false;
  bool isLocked = false;

  @override
  void initState() {
    courseViewModel = Provider.of(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        key: key,
        body: Column(
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
                      sidebarIndex: 1,
                    )),
                  Expanded(
                    flex: 5,
                    child: Container(
                      alignment: Alignment.topCenter,
                      padding: EdgeInsets.only(
                          left: 20, right: 20, top: width < 900 ? 20 : 100),
                      color: AppColorsInApp.colorGrey.withValues(alpha: .1),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomTextField(
                                        title: "Course Code",
                                        labelText: "Course Code",
                                        textEditingController:
                                            courseCodeController),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: CustomTextField(
                                          title: "Course Name",
                                          labelText: "Course Name",
                                          textEditingController:
                                              courseNameController),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text("Course Image",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColorsInApp
                                                      .colorGrey)),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: Row(
                                              children: [
                                                Row(
                                                  children: [
                                                    ChooseImage(
                                                      onSelectImage: () async {
                                                        var picked =
                                                            await FilePicker
                                                                .platform
                                                                .pickFiles(
                                                          type: FileType.image,
                                                        );

                                                        if (picked != null) {
                                                          setState(() {
                                                            selectedImageBytes =
                                                                picked
                                                                    .files
                                                                    .first
                                                                    .bytes;
                                                            imageName = picked
                                                                .files
                                                                .first
                                                                .name;
                                                          });
                                                        }
                                                      },
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0),
                                                      child: Text(
                                                          imageName.isEmpty
                                                              ? "No File Chosen"
                                                              : imageName,
                                                          style: const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color: AppColorsInApp
                                                                  .colorBlack1)),
                                                    ),
                                                  ],
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
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 20.0),
                                            child: CustomTextField(
                                              title: "Course Description",
                                              labelText: "Course Description",
                                              textEditingController:
                                                  courseDescriptionController,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 20.0),
                                            child: CustomTextField(
                                              title: "Display Priority",
                                              labelText: "Display Priority",
                                              textEditingController:
                                                  displayPriorityController,
                                              textInputType:
                                                  TextInputType.number,
                                            ),
                                          ),
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20.0),
                                              child: Row(
                                                children: [
                                                  const Text(
                                                    "Will Display: ",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColorsInApp
                                                            .colorGrey),
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
                                                    activeFgColor: Colors.white,
                                                    inactiveBgColor:
                                                        Colors.grey,
                                                    inactiveFgColor:
                                                        Colors.white,
                                                    initialLabelIndex:
                                                        willShow ? 1 : 0,
                                                    totalSwitches: 2,
                                                    labels: const ['NO', 'YES'],
                                                    radiusStyle: true,
                                                    onToggle: (index) {
                                                      setState(() {
                                                        if (index == 0) {
                                                          willShow = false;
                                                        } else {
                                                          willShow = true;
                                                        }
                                                      });
                                                    },
                                                  ),
                                                ],
                                              )),
                                        ],
                                      ),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(top: 20.0),
                                        child: Row(
                                          children: [
                                            const Text(
                                              "Is Locked: ",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      AppColorsInApp.colorGrey),
                                            ),
                                            ToggleSwitch(
                                              minWidth: 90.0,
                                              cornerRadius: 20.0,
                                              activeBgColors: [
                                                const [
                                                  AppColorsInApp.colorLightRed
                                                ],
                                                [
                                                  AppColorsInApp.colorSecondary!
                                                ],
                                              ],
                                              activeFgColor: Colors.white,
                                              inactiveBgColor: Colors.grey,
                                              inactiveFgColor: Colors.white,
                                              initialLabelIndex:
                                                  isLocked ? 1 : 0,
                                              totalSwitches: 2,
                                              labels: const ['NO', 'YES'],
                                              radiusStyle: true,
                                              onToggle: (index) {
                                                setState(() {
                                                  if (index == 0) {
                                                    isLocked = false;
                                                  } else {
                                                    isLocked = true;
                                                  }
                                                });
                                              },
                                            ),
                                          ],
                                        )),
                                  ],
                                ),
                                if (width > 900)
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: width > 900 ? 50 : 10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomTextField(
                                          title: "Course Description",
                                          labelText: "Course Description",
                                          textEditingController:
                                              courseDescriptionController,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20.0),
                                          child: CustomTextField(
                                            title: "Display Priority",
                                            labelText: "Display Priority",
                                            textEditingController:
                                                displayPriorityController,
                                            textInputType: TextInputType.number,
                                          ),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                top: 40.0),
                                            child: Row(
                                              children: [
                                                const Text(
                                                  "Will Display: ",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColorsInApp
                                                          .colorGrey),
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
                                                  activeFgColor: Colors.white,
                                                  inactiveBgColor: Colors.grey,
                                                  inactiveFgColor: Colors.white,
                                                  initialLabelIndex:
                                                      willShow ? 1 : 0,
                                                  totalSwitches: 2,
                                                  labels: const ['NO', 'YES'],
                                                  radiusStyle: true,
                                                  onToggle: (index) {
                                                    setState(() {
                                                      if (index == 0) {
                                                        willShow = false;
                                                      } else {
                                                        willShow = true;
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
                                if (courseCodeController.text.isNotEmpty &&
                                    displayPriorityController.text.isNotEmpty &&
                                    selectedImageBytes != null &&
                                    courseNameController.text.isNotEmpty) {
                                  CourseModel courseData = CourseModel(
                                      courseCodeController.text
                                          .trim()
                                          .toUpperCase(),
                                      courseDescriptionController.text,
                                      courseNameController.text,
                                      "",
                                      int.parse(displayPriorityController.text),
                                      DateTime.now().millisecondsSinceEpoch,
                                      willShow,
                                      isLocked);
                                  await courseViewModel
                                      .addCourse(courseData)
                                      .then((value) async {
                                    LoaderDialogs.showLoadingDialog();
                                    await courseViewModel
                                        .uploadCourseImage(selectedImageBytes!,
                                            courseCodeController.text, value.id)
                                        .whenComplete(() {
                                      /// for remove loader
                                      Navigator.pop(context);
                                      Helper.showSnackBarMessage(
                                          msg: "Course added successfully",
                                          isSuccess: true);

                                      /// for remove snackbar
                                      Navigator.pop(context);
                                    });
                                  });
                                } else {
                                  if (courseCodeController.text.isEmpty) {
                                    Helper.showSnackBarMessage(
                                        msg: "Please add course code",
                                        isSuccess: false);
                                  } else if (courseNameController
                                      .text.isEmpty) {
                                    Helper.showSnackBarMessage(
                                        msg: "Please add course name",
                                        isSuccess: false);
                                  } else if (selectedImageBytes == null) {
                                    Helper.showSnackBarMessage(
                                        msg: "Please upload course image",
                                        isSuccess: false);
                                  } else {
                                    Helper.showSnackBarMessage(
                                        msg: "Please add display priority",
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
          ],
        ),
        drawer: width < 900
            ? const Drawer(
                child: ExtraSideBar(sidebarIndex: 1),
              )
            : null);
  }
}
