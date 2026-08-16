import 'dart:typed_data';

import 'package:bbarna/core/widgets/choose_image.dart';
import 'package:bbarna/core/widgets/loader_dialog.dart';
import 'package:bbarna/course/model/course_model.dart';
import 'package:bbarna/course/viewModel/course_view_model.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/subject/model/subject_model.dart';
import 'package:bbarna/units/model/unit_model.dart';
import 'package:bbarna/units/viewModel/unit_view_model.dart';
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

class AddUnit extends StatefulWidget {
  const AddUnit({super.key});

  @override
  State<AddUnit> createState() => _AddUnitState();
}

class _AddUnitState extends State<AddUnit> {
  Uint8List? selectedImageBytes;
  String imageName = "";
  TextEditingController unitCodeController = TextEditingController();
  TextEditingController unitNameController = TextEditingController();
  TextEditingController unitDescriptionController = TextEditingController();
  TextEditingController displayPriorityController = TextEditingController();

  // --- dynamic extra code fields (horizontal, + / - controls) ---
  final List<TextEditingController> _extraCodeControllers = [
    TextEditingController(),
  ];

  void _addCodeField() {
    setState(() {
      _extraCodeControllers.add(TextEditingController());
    });
  }

  void _removeCodeField(int index) {
    setState(() {
      _extraCodeControllers[index].dispose();
      _extraCodeControllers.removeAt(index);
    });
  }
  // --- end dynamic extra code fields ---

  String? _selectedCourseName;
  String? _selectedSubjectName;
  String _selectedCourseCode = "";
  String _selectedSubjectCode = "";
  final GlobalKey<ScaffoldState> key = GlobalKey();
  bool willShow = false;
  bool isLocked = false;

  @override
  void initState() {
    Provider.of<CourseViewModel>(context, listen: false).getCourseList();
    super.initState();
  }

  @override
  void dispose() {
    unitCodeController.dispose();
    unitNameController.dispose();
    unitDescriptionController.dispose();
    displayPriorityController.dispose();
    for (final c in _extraCodeControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _buildExtraCodeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Subject Codes",
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
              for (int i = 0; i < _extraCodeControllers.length; i++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: AppColorsInApp.colorWhite,
                      ),
                      child: TextField(
                        controller: _extraCodeControllers[i],
                        style:
                            const TextStyle(color: AppColorsInApp.colorBlack1),
                        decoration: const InputDecoration(
                          hintText: "Code",
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline,
                          color: AppColorsInApp.colorLightRed),
                      onPressed: _extraCodeControllers.length > 1
                          ? () => _removeCodeField(i)
                          : null,
                    ),
                  ],
                ),
              IconButton(
                icon: Icon(Icons.add_circle_outline,
                    color: AppColorsInApp.colorSecondary),
                onPressed: _addCodeField,
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
                      sidebarIndex: 3,
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
                              child: Consumer2<CourseViewModel, UnitViewModel>(
                                  builder: (context, courseDataProvider,
                                      unitDataProvider, child) {
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
                                                    ignoring: courseDataProvider
                                                        .courseList.isEmpty,
                                                    child: Container(
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
                                                            BorderRadius
                                                                .circular(10),
                                                        color: AppColorsInApp
                                                            .colorWhite,
                                                      ),
                                                      child: DropdownButton<
                                                          String>(
                                                        value:
                                                            _selectedCourseName,
                                                        elevation: 16,
                                                        isExpanded: true,
                                                        hint: const Text(
                                                            "Select Course"),
                                                        style: const TextStyle(
                                                            color: AppColorsInApp
                                                                .colorBlack1),
                                                        underline: Container(),
                                                        onChanged: (String?
                                                            newValue) async {
                                                          setState(() {
                                                            _selectedCourseName =
                                                                newValue!;
                                                            _selectedCourseCode =
                                                                courseDataProvider
                                                                    .courseList
                                                                    .where((element) =>
                                                                        element
                                                                            .name ==
                                                                        _selectedCourseName)
                                                                    .first
                                                                    .code;
                                                            _selectedSubjectCode =
                                                                "";
                                                            _selectedSubjectName =
                                                                null;
                                                          });

                                                          await unitDataProvider
                                                              .getSubjectListByCourseCode(
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
                                                            unitDataProvider
                                                                .subjectListByCourseId
                                                                .isEmpty),
                                                    child: Container(
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
                                                            BorderRadius
                                                                .circular(10),
                                                        color: AppColorsInApp
                                                            .colorWhite,
                                                      ),
                                                      child: DropdownButton<
                                                          String>(
                                                        value:
                                                            _selectedSubjectName,
                                                        elevation: 16,
                                                        isExpanded: true,
                                                        hint: const Text(
                                                            "Select Subject"),
                                                        style: const TextStyle(
                                                            color: AppColorsInApp
                                                                .colorBlack1),
                                                        underline: Container(),
                                                        onChanged:
                                                            (String? value) {
                                                          setState(() {
                                                            _selectedSubjectName =
                                                                value;
                                                            _selectedSubjectCode =
                                                                unitDataProvider
                                                                    .subjectListByCourseId
                                                                    .where((element) =>
                                                                        element
                                                                            .name ==
                                                                        _selectedSubjectName)
                                                                    .first
                                                                    .code;
                                                          });
                                                        },
                                                        items: unitDataProvider
                                                            .subjectListByCourseId
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
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text("Unit Image",
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: AppColorsInApp
                                                              .colorGrey)),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 5),
                                                    child: Row(
                                                      children: [
                                                        ChooseImage(
                                                            onSelectImage:
                                                                () async {
                                                          var picked =
                                                              await FilePicker
                                                                  .platform
                                                                  .pickFiles(
                                                            type:
                                                                FileType.image,
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
                                                        }),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
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
                                                            "Will Display:  ",
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
                                                              top: 20),
                                                      child: CustomTextField(
                                                        title: "Unit Code",
                                                        labelText: "Unit Code",
                                                        textEditingController:
                                                            unitCodeController,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 20.0),
                                                      child:
                                                          _buildExtraCodeFields(),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 20.0),
                                                      child: CustomTextField(
                                                        title: "Unit Name",
                                                        labelText: "Unit Name",
                                                        textEditingController:
                                                            unitNameController,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 20.0),
                                                      child: CustomTextField(
                                                        title:
                                                            "Unit Description",
                                                        labelText:
                                                            "Unit Description",
                                                        textEditingController:
                                                            unitDescriptionController,
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
                                                    title: "Unit Code",
                                                    labelText: "Unit Code",
                                                    textEditingController:
                                                        unitCodeController,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 20.0),
                                                    child:
                                                        _buildExtraCodeFields(),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 20.0),
                                                    child: CustomTextField(
                                                      title: "Unit Name",
                                                      labelText: "Unit Name",
                                                      textEditingController:
                                                          unitNameController,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 20),
                                                    child: CustomTextField(
                                                      title: "Unit Description",
                                                      labelText:
                                                          "Unit Description",
                                                      textEditingController:
                                                          unitDescriptionController,
                                                    ),
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
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 30),
                                        child: SaveButton(onPRess: () async {
                                          if (unitCodeController
                                                  .text.isNotEmpty &&
                                              _selectedSubjectCode != "" &&
                                              selectedImageBytes != null &&
                                              displayPriorityController
                                                  .text.isNotEmpty) {
                                            LoaderDialogs.showLoadingDialog();

                                            final extraCodes =
                                                _extraCodeControllers
                                                    .map((c) => c.text.trim())
                                                    .where((v) => v.isNotEmpty)
                                                    .toList();

                                            UnitModel unitData = UnitModel(
                                                _selectedCourseCode,
                                                _selectedCourseName ??
                                                    stringDefault,
                                                _selectedSubjectCode,
                                                _selectedSubjectName ??
                                                    stringDefault,
                                                isLocked,
                                                unitCodeController.text
                                                    .trim()
                                                    .toUpperCase(),
                                                unitDescriptionController.text,
                                                unitNameController.text,
                                                "",
                                                int.parse(
                                                    displayPriorityController
                                                        .text),
                                                DateTime.now()
                                                    .millisecondsSinceEpoch,
                                                willShow,
                                                extraCodes);
                                            // NOTE: extraCodes is computed above.
                                            // If UnitModel gets an
                                            // `extraCodes` field, pass it into
                                            // the constructor call above.
                                            await unitDataProvider
                                                .addUnit(unitData)
                                                .then((value) async {
                                              // if (selectedImageBytes != null) {
                                              await unitDataProvider
                                                  .uploadUnitImage(
                                                      selectedImageBytes!,
                                                      unitCodeController.text,
                                                      value.id)
                                                  .whenComplete(() {
                                                /// remove loader
                                                Navigator.pop(context);

                                                Helper.showSnackBarMessage(
                                                    msg:
                                                        "Unit added successfully",
                                                    isSuccess: true);
                                                Navigator.pop(context);
                                              });
                                              //}
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
                                            } else if (unitCodeController
                                                .text.isEmpty) {
                                              Helper.showSnackBarMessage(
                                                  msg: "Please fill topic code",
                                                  isSuccess: false);
                                            } else if (unitNameController
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
                                      ),
                                    ],
                                  ),
                                );
                              }),
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
        drawer: width < 900
            ? const Drawer(
                child: ExtraSideBar(sidebarIndex: 3),
              )
            : null);
  }
}
