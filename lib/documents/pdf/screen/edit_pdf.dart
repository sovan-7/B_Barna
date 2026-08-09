// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';
import 'package:bbarna/core/widgets/choose_image.dart';
import 'package:bbarna/core/widgets/loader_dialog.dart';
import 'package:bbarna/documents/pdf/model/pdf_model.dart';
import 'package:bbarna/documents/pdf/viewModel/pdf_view_model.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:bbarna/core/widgets/app_header.dart';
import 'package:bbarna/core/widgets/sidebar.dart';
import 'package:bbarna/core/widgets/save_button.dart';
import 'package:bbarna/resources/app_colors.dart';
import 'package:bbarna/core/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

class EditPdf extends StatefulWidget {
  final PdfModel pdfData;
  const EditPdf({required this.pdfData, super.key});

  @override
  State<EditPdf> createState() => _EditPdfState();
}

class _EditPdfState extends State<EditPdf> {
  TextEditingController pdfCodeController = TextEditingController();
  TextEditingController pdfTitleController = TextEditingController();
  TextEditingController pdfDescriptionController = TextEditingController();
  TextEditingController displayPriorityTextEditingController =
      TextEditingController();
  Uint8List? selectedPdfBytes;
  String pdfName = "";
  bool isLocked = false;
  bool isDownloadable = false;

  List<String> pdfTypeList = ["FREE", "PAID"];
  String? _selectedPdfType;
  final GlobalKey<ScaffoldState> key = GlobalKey();
  @override
  void initState() {
    setState(() {
      pdfCodeController.text = widget.pdfData.code;

      pdfTitleController.text = widget.pdfData.title;

      pdfDescriptionController.text = widget.pdfData.description;
      _selectedPdfType = widget.pdfData.pdfType;
      pdfName = "${widget.pdfData.code}_pdf.pdf";
      isLocked = widget.pdfData.isLocked;
      isDownloadable = widget.pdfData.isDownloadable;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        key: key,
        body: PopScope(
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              // handle back press
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
                if (width > 900)
                  const Expanded(
                      child: ExtraSideBar(
                    sidebarIndex: 6,
                  )),
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.grey.withValues(alpha: .1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: SingleChildScrollView(
                              child: Consumer<PdfViewModel>(
                                  builder: (context, pdfDataProvider, child) {
                                return Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CustomTextField(
                                        title: "PDF Code",
                                        labelText: "PDF code",
                                        textEditingController:
                                            pdfCodeController,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 15.0),
                                        child: CustomTextField(
                                          title: "PDF Title",
                                          labelText: "PDF Title",
                                          textEditingController:
                                              pdfTitleController,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 15.0),
                                        child: CustomTextField(
                                          title: "Description",
                                          labelText: "Description",
                                          textEditingController:
                                              pdfDescriptionController,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 15),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Pdf Type",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      AppColorsInApp.colorGrey),
                                            ),
                                            IgnorePointer(
                                              ignoring: (pdfTypeList.isEmpty),
                                              child: Container(
                                                width: 350,
                                                margin: const EdgeInsets.only(
                                                  top: 10,
                                                  bottom: 20,
                                                ),
                                                padding: const EdgeInsets.only(
                                                    left: 15, right: 15),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color:
                                                      AppColorsInApp.colorWhite,
                                                ),
                                                child: DropdownButton<String>(
                                                  value: _selectedPdfType,
                                                  isExpanded: true,
                                                  hint:
                                                      const Text("Select Type"),
                                                  elevation: 16,
                                                  style: const TextStyle(
                                                      color: AppColorsInApp
                                                          .colorBlack1),
                                                  underline: const SizedBox(),
                                                  onChanged:
                                                      (String? newValue) {
                                                    setState(() {
                                                      _selectedPdfType =
                                                          newValue;
                                                    });
                                                  },
                                                  items: pdfTypeList
                                                      .map((String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ChooseImage(
                                                title: "Choose Pdf",
                                                onSelectImage: () async {
                                                  var picked = await FilePicker
                                                      .platform
                                                      .pickFiles(
                                                    type: FileType.custom,
                                                    allowedExtensions: ['pdf'],
                                                  );

                                                  if (picked != null) {
                                                    setState(() {
                                                      selectedPdfBytes = picked
                                                          .files.first.bytes;
                                                      pdfName = picked
                                                          .files.first.name;
                                                    });
                                                  }
                                                }),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Text(
                                                  pdfName.isEmpty
                                                      ? "No File Chosen"
                                                      : pdfName,
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: AppColorsInApp
                                                          .colorBlack1)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(top: 15.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "Is Locked: ",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColorsInApp
                                                        .colorGrey),
                                              ),
                                              ToggleSwitch(
                                                minWidth: 90.0,
                                                cornerRadius: 10.0,
                                                activeBgColors: [
                                                  const [
                                                    AppColorsInApp.colorLightRed
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
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(top: 15.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "Is Downloadable: ",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColorsInApp
                                                        .colorGrey),
                                              ),
                                              ToggleSwitch(
                                                minWidth: 90.0,
                                                cornerRadius: 10.0,
                                                activeBgColors: [
                                                  const [
                                                    AppColorsInApp.colorLightRed
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
                                                    isDownloadable ? 1 : 0,
                                                totalSwitches: 2,
                                                labels: const ['NO', 'YES'],
                                                radiusStyle: true,
                                                onToggle: (index) {
                                                  setState(() {
                                                    if (index == 0) {
                                                      isDownloadable = false;
                                                    } else {
                                                      isDownloadable = true;
                                                    }
                                                  });
                                                },
                                              ),
                                            ],
                                          )),
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(top: 35),
                                          child: SaveButton(
                                            onPRess: () {
                                              if (pdfCodeController
                                                      .text.isNotEmpty &&
                                                  pdfTitleController
                                                      .text.isNotEmpty &&
                                                  _selectedPdfType != null) {
                                                PdfModel pdfModel = PdfModel(
                                                    pdfCodeController.text
                                                        .trim()
                                                        .toUpperCase(),
                                                    pdfDescriptionController
                                                        .text,
                                                    pdfTitleController.text,
                                                    widget.pdfData.pdfLink,
                                                    isDownloadable,
                                                    _selectedPdfType ??
                                                        stringDefault,
                                                    widget.pdfData.timeStamp,
                                                    isLocked);
                                                LoaderDialogs
                                                    .showLoadingDialog();
                                                pdfDataProvider
                                                    .updatePdf(pdfModel,
                                                        widget.pdfData.docId)
                                                    .then((value) async {
                                                  if (selectedPdfBytes !=
                                                      null) {
                                                    await pdfDataProvider
                                                        .uploadPdf(
                                                            selectedPdfBytes!,
                                                            pdfCodeController
                                                                .text,
                                                            widget
                                                                .pdfData.docId);
                                                  }

                                                  /// for remove loader
                                                  Navigator.pop(context);
                                                  Helper.showSnackBarMessage(
                                                      msg:
                                                          "Pdf updated successfully",
                                                      isSuccess: true);

                                                  /// going to previous page
                                                  Navigator.pop(context);
                                                });
                                              } else {
                                                if (pdfCodeController
                                                    .text.isEmpty) {
                                                  Helper.showSnackBarMessage(
                                                      msg:
                                                          "Please add pdf code",
                                                      isSuccess: false);
                                                } else if (pdfTitleController
                                                    .text.isEmpty) {
                                                  Helper.showSnackBarMessage(
                                                      msg:
                                                          "Please add pdf title",
                                                      isSuccess: false);
                                                } else if (selectedPdfBytes ==
                                                    null) {
                                                  Helper.showSnackBarMessage(
                                                      msg:
                                                          "Please upload pdf file",
                                                      isSuccess: false);
                                                } else {
                                                  Helper.showSnackBarMessage(
                                                      msg:
                                                          "Please select pdf type",
                                                      isSuccess: false);
                                                }
                                              }
                                            },
                                          ))
                                    ]);
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ])),
            ])),
        drawer: width < 900
            ? const Drawer(
                child: ExtraSideBar(sidebarIndex: 6),
              )
            : null);
  }
}
