import 'dart:typed_data';

import 'package:bbarna/core/widgets/app_header.dart';
import 'package:bbarna/core/widgets/choose_image.dart';
import 'package:bbarna/core/widgets/custom_text_field.dart';
import 'package:bbarna/core/widgets/sidebar.dart';
import 'package:bbarna/core/widgets/loader_dialog.dart';
import 'package:bbarna/core/widgets/save_button.dart';
import 'package:bbarna/documents/audio/model/audio_model.dart';
import 'package:bbarna/documents/audio/viewModel/audio_view_model.dart';
import 'package:bbarna/resources/app_colors.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddAudio extends StatefulWidget {
  const AddAudio({super.key});

  @override
  State<AddAudio> createState() => _AddAudioState();
}

class _AddAudioState extends State<AddAudio> {
  TextEditingController audioCodeController = TextEditingController();
  TextEditingController audioTitleController = TextEditingController();
  TextEditingController audioDescriptionController = TextEditingController();
  final GlobalKey<ScaffoldState> key = GlobalKey();
  List<String> audioTypeList = ["FREE", "PAID"];
  String? _selectedAudioType;
  Uint8List? selectedAudioBytes;
  String audioName = "";
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
                    sidebarIndex: 7,
                  )),
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                    color: Colors.grey.withValues(alpha: .1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: SingleChildScrollView(child:
                                Consumer<AudioViewModel>(builder:
                                    (context, audioDataProvider, child) {
                              return Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15.0),
                                    child: CustomTextField(
                                      title: "Audio Code",
                                      labelText: "Audio code",
                                      textEditingController:
                                          audioCodeController,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15.0),
                                    child: CustomTextField(
                                      title: "Audio Title",
                                      labelText: "Audio Title",
                                      textEditingController:
                                          audioTitleController,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15.0),
                                    child: CustomTextField(
                                      title: "Audio Description",
                                      labelText: "Audio Description",
                                      textEditingController:
                                          audioDescriptionController,
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
                                          "Audio Type",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppColorsInApp.colorGrey),
                                        ),
                                        IgnorePointer(
                                          ignoring: (audioTypeList.isEmpty),
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
                                              color: AppColorsInApp.colorWhite,
                                            ),
                                            child: DropdownButton<String>(
                                              value: _selectedAudioType,
                                              isExpanded: true,
                                              hint: const Text("Select Type"),
                                              elevation: 16,
                                              style: const TextStyle(
                                                  color: AppColorsInApp
                                                      .colorBlack1),
                                              underline: const SizedBox(),
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  _selectedAudioType = newValue;
                                                });
                                              },
                                              items: audioTypeList
                                                  .map((String value) {
                                                return DropdownMenuItem<String>(
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
                                    padding: const EdgeInsets.only(
                                        top: 15.0, left: 5.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ChooseImage(
                                            title: "Chose Audio",
                                            onSelectImage: () async {
                                              var picked = await FilePicker
                                                  .platform
                                                  .pickFiles(
                                                type: FileType.audio,
                                              );

                                              if (picked != null) {
                                                setState(() {
                                                  selectedAudioBytes =
                                                      picked.files.first.bytes;
                                                  audioName =
                                                      picked.files.first.name;
                                                });
                                              }
                                            }),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                              audioName.isEmpty
                                                  ? "No File Chosen"
                                                  : audioName,
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 25),
                                    child: SaveButton(onPRess: () {
                                      if (audioCodeController.text.isNotEmpty &&
                                          selectedAudioBytes != null &&
                                          _selectedAudioType != null) {
                                        AudioModel audioModel = AudioModel(
                                          audioCodeController.text
                                              .trim()
                                              .toUpperCase(),
                                          audioDescriptionController.text,
                                          audioTitleController.text,
                                          "",
                                          _selectedAudioType ?? stringDefault,
                                          DateTime.now().millisecondsSinceEpoch,
                                        );
                                        LoaderDialogs.showLoadingDialog();
                                        audioDataProvider
                                            .addAudio(audioModel)
                                            .then((value) async {
                                          await audioDataProvider
                                              .uploadAudio(
                                                  selectedAudioBytes!,
                                                  audioCodeController.text,
                                                  value.id)
                                              .whenComplete(() {
                                            /// for remove loader
                                            Navigator.pop(context);
                                            Helper.showSnackBarMessage(
                                                msg: "Audio added successfully",
                                                isSuccess: true);
                                            audioDataProvider.clearData();

                                            /// going to previous page
                                            Navigator.pop(context);
                                          });
                                        });
                                      } else {
                                        if (audioCodeController.text.isEmpty) {
                                          Helper.showSnackBarMessage(
                                              msg: "Please add audio code",
                                              isSuccess: false);
                                        } else if (audioTitleController
                                            .text.isEmpty) {
                                          Helper.showSnackBarMessage(
                                              msg: "Please add audio title",
                                              isSuccess: false);
                                        } else if (selectedAudioBytes == null) {
                                          Helper.showSnackBarMessage(
                                              msg: "Please upload audio file",
                                              isSuccess: false);
                                        } else {
                                          Helper.showSnackBarMessage(
                                              msg: "Please add audio type",
                                              isSuccess: false);
                                        }
                                      }
                                    }),
                                  )
                                ],
                              );
                            })),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]))
            ])),
        drawer: width < 900
            ? const Drawer(
                child: ExtraSideBar(sidebarIndex: 7),
              )
            : null);
  }
}
