import 'package:bbarna/core/widgets/loader_dialog.dart';
import 'package:bbarna/course/viewModel/course_view_model.dart';
import 'package:bbarna/documents/video/model/video_model.dart';
import 'package:bbarna/documents/video/viewModel/video_view_model.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:bbarna/core/widgets/sidebar.dart';
import 'package:bbarna/core/widgets/save_button.dart';
import 'package:bbarna/resources/app_colors.dart';
import 'package:bbarna/core/widgets/custom_text_field.dart';
import 'package:bbarna/core/widgets/app_header.dart';
import 'package:provider/provider.dart';

class EditVideo extends StatefulWidget {
  final VideoModel videoData;
  const EditVideo({required this.videoData, super.key});

  @override
  State<EditVideo> createState() => _AddVideoState();
}

class _AddVideoState extends State<EditVideo> {
  TextEditingController videoLinkController = TextEditingController();
  TextEditingController videoCodeController = TextEditingController();
  TextEditingController videoDescriptionController = TextEditingController();
  TextEditingController videoTitleController = TextEditingController();

  List<String> videoTypeList = ["FREE", "PAID"];
  String? _selectedVideoType;
  final GlobalKey<ScaffoldState> key = GlobalKey();
  @override
  void initState() {
    setState(() {
      _selectedVideoType = widget.videoData.videoType;
      videoCodeController.text = widget.videoData.code;
      videoCodeController.text = widget.videoData.code;
      videoTitleController.text = widget.videoData.title;
      videoDescriptionController.text = widget.videoData.description;
      videoLinkController.text = widget.videoData.link;
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
                    sidebarIndex: 5,
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Container(
                                  alignment: Alignment.center,
                                  child: SingleChildScrollView(child: Consumer2<
                                          CourseViewModel, VideoViewModel>(
                                      builder: (context, courseDataProvider,
                                          videoDataProvider, child) {
                                    return Column(
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomTextField(
                                              title: "Video Code",
                                              labelText: "Video Code",
                                              textEditingController:
                                                  videoCodeController,
                                            ),

                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 15.0),
                                              child: CustomTextField(
                                                title: "Video Title",
                                                labelText:
                                                    "Youtube Video Title",
                                                textEditingController:
                                                    videoTitleController,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 15.0),
                                              child: CustomTextField(
                                                title: "Video Link",
                                                labelText: "Youtube Video Link",
                                                textEditingController:
                                                    videoLinkController,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 15.0),
                                              child: CustomTextField(
                                                title: "Video Description",
                                                labelText: "Video Description",
                                                textEditingController:
                                                    videoDescriptionController,
                                              ),
                                            ),

                                            // Padding(
                                            //   padding: const EdgeInsets.only(
                                            //       top: 15.0),
                                            //   child: CustomTextField(
                                            //     title: "Display Priority",
                                            //     labelText: "Display Priority",
                                            //     textInputType:
                                            //         TextInputType.number,
                                            //   ),
                                            // ),

                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 15),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "Video Type",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColorsInApp
                                                            .colorGrey),
                                                  ),
                                                  IgnorePointer(
                                                    ignoring:
                                                        (videoTypeList.isEmpty),
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
                                                            _selectedVideoType,
                                                        isExpanded: true,
                                                        hint: const Text(
                                                            "Select Type"),
                                                        elevation: 16,
                                                        style: const TextStyle(
                                                            color: AppColorsInApp
                                                                .colorBlack1),
                                                        underline:
                                                            const SizedBox(),
                                                        onChanged:
                                                            (String? newValue) {
                                                          setState(() {
                                                            _selectedVideoType =
                                                                newValue;
                                                          });
                                                        },
                                                        items: videoTypeList
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
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 25),
                                          child: SaveButton(onPRess: () {
                                            if (videoCodeController.text.isNotEmpty &&
                                                videoLinkController
                                                    .text.isNotEmpty &&
                                                videoTitleController
                                                    .text.isNotEmpty &&
                                                _selectedVideoType != null) {
                                              VideoModel videoModel =
                                                  VideoModel(
                                                videoCodeController.text
                                                    .trim()
                                                    .toUpperCase(),
                                                videoDescriptionController.text,
                                                videoTitleController.text,
                                                videoLinkController.text,
                                                _selectedVideoType ?? "",
                                                widget.videoData.timeStamp,
                                              );
                                              LoaderDialogs.showLoadingDialog();
                                              videoDataProvider
                                                  .updateVideo(videoModel,
                                                      widget.videoData.docId)
                                                  .then((value) async {
                                                /// for remove loader
                                                Navigator.pop(context);
                                                Helper.showSnackBarMessage(
                                                    msg:
                                                        "Video updated successfully",
                                                    isSuccess: true);

                                                /// for go to previous page
                                                Navigator.pop(context);
                                              });
                                            } else {
                                              if (videoCodeController
                                                  .text.isEmpty) {
                                                Helper.showSnackBarMessage(
                                                    msg:
                                                        "Please add video code",
                                                    isSuccess: false);
                                              } else if (videoTitleController
                                                  .text.isEmpty) {
                                                Helper.showSnackBarMessage(
                                                    msg:
                                                        "Please add video title",
                                                    isSuccess: false);
                                              } else if (videoLinkController
                                                  .text.isEmpty) {
                                                Helper.showSnackBarMessage(
                                                    msg:
                                                        "Please add video title",
                                                    isSuccess: false);
                                              } else {
                                                Helper.showSnackBarMessage(
                                                    msg:
                                                        "Please select video type",
                                                    isSuccess: false);
                                              }
                                            }
                                          }),
                                        ),
                                      ],
                                    );
                                  })))),
                        ],
                      )),
                )
              ])),
            ])),
        drawer: width < 900
            ? const Drawer(
                child: ExtraSideBar(sidebarIndex: 5),
              )
            : null);
  }
}
