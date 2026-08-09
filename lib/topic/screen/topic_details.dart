import 'package:bbarna/core/widgets/loader_dialog.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/topic/model/topic_model.dart';
import 'package:bbarna/topic/viewModel/topic_view_model.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bbarna/core/widgets/app_header.dart';
import 'package:bbarna/core/widgets/sidebar.dart';
import 'package:bbarna/resources/app_colors.dart';
import 'package:bbarna/topic/widgets/topic_table.dart';
import 'package:provider/provider.dart';

class TopicDetails extends StatefulWidget {
  final TopicModel topicData;
  const TopicDetails({required this.topicData, super.key});

  @override
  State<TopicDetails> createState() => _TopicDetailsState();
}

class _TopicDetailsState extends State<TopicDetails> {
  final GlobalKey<ScaffoldState> key = GlobalKey();
  List<TextEditingController> audioControllerList = [];
  List<TextEditingController> videoControllerList = [];
  List<TextEditingController> pdfControllerList = [];
  List<TextEditingController> quizControllerList = [];

  @override
  void initState() {
    setState(() {
      audioControllerList = List.generate(
          widget.topicData.audioCodeList.length,
          (index) => TextEditingController(
              text: widget.topicData.audioCodeList[index]));
      videoControllerList = List.generate(
          widget.topicData.videoCodeList.length,
          (index) => TextEditingController(
              text: widget.topicData.videoCodeList[index]));
      pdfControllerList = List.generate(
          widget.topicData.pdfCodeList.length,
          (index) =>
              TextEditingController(text: widget.topicData.pdfCodeList[index]));
      quizControllerList = List.generate(
          widget.topicData.quizCodeList.length,
          (index) => TextEditingController(
              text: widget.topicData.quizCodeList[index]));
    });
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
                        child: SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.only(
                              top: 25,
                              bottom: 25,
                              left: 15,
                              right: 15,
                            ),
                            child: Consumer<TopicViewModel>(
                              builder: (context, topicDataProvider, child) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Topic Details",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                          color: AppColorsInApp.colorBlack1),
                                    ),
                                    TopicTable(
                                      topicText: "Video",
                                      topicName: widget.topicData.name,
                                      onChanged: (value) {},
                                      onAdd: () {
                                        setState(() {
                                          videoControllerList
                                              .add(TextEditingController());
                                        });
                                      },
                                      onRemove: (index) {
                                        setState(() {
                                          videoControllerList.removeAt(index);
                                        });
                                      },
                                      onSave: () {
                                        List<String> videoCodeList = [];
                                        for (int i = 0;
                                            i < videoControllerList.length;
                                            i++) {
                                          if (videoControllerList[i]
                                              .text
                                              .isNotEmpty) {
                                            videoCodeList.add(
                                                videoControllerList[i].text);
                                          }
                                        }
                                        LoaderDialogs.showLoadingDialog();

                                        FirebaseFirestore.instance
                                            .collection(topic)
                                            .doc(widget.topicData.docId)
                                            .update({
                                          'video_code_list': videoCodeList,
                                        }).then((value) {
                                          Navigator.pop(context);
                                          Helper.showSnackBarMessage(
                                              msg:
                                                  "Video code added successfully",
                                              isSuccess: true);
                                          setState(() {
                                            videoControllerList.clear();
                                          });
                                          Navigator.pop(context);
                                        });
                                      },
                                      controllerList: videoControllerList,
                                    ),
                                    TopicTable(
                                      topicText: "Audio",
                                      topicName: widget.topicData.name,
                                      onChanged: (value) {},
                                      onAdd: () {
                                        setState(() {
                                          audioControllerList
                                              .add(TextEditingController());
                                        });
                                      },
                                      onRemove: (index) {
                                        setState(() {
                                          audioControllerList.removeAt(index);
                                        });
                                      },
                                      onSave: () {
                                        List<String> audioCodeList = [];
                                        for (int i = 0;
                                            i < audioControllerList.length;
                                            i++) {
                                          if (audioControllerList[i]
                                              .text
                                              .isNotEmpty) {
                                            audioCodeList.add(
                                                audioControllerList[i].text);
                                          }
                                        }
                                        LoaderDialogs.showLoadingDialog();

                                        FirebaseFirestore.instance
                                            .collection(topic)
                                            .doc(widget.topicData.docId)
                                            .update({
                                          'audio_code_list': audioCodeList,
                                        }).then((value) {
                                          Navigator.pop(context);
                                          Helper.showSnackBarMessage(
                                              msg:
                                                  "Audio code added successfully",
                                              isSuccess: true);
                                          setState(() {
                                            audioControllerList.clear();
                                          });
                                          Navigator.pop(context);
                                        });
                                      },
                                      controllerList: audioControllerList,
                                    ),
                                    TopicTable(
                                      topicText: "PDF",
                                      topicName: widget.topicData.name,
                                      onChanged: (value) {},
                                      onAdd: () {
                                        setState(() {
                                          pdfControllerList
                                              .add(TextEditingController());
                                        });
                                      },
                                      onRemove: (index) {
                                        setState(() {
                                          pdfControllerList.removeAt(index);
                                        });
                                      },
                                      onSave: () {
                                        List<String> pdfCodeList = [];
                                        for (int i = 0;
                                            i < pdfControllerList.length;
                                            i++) {
                                          if (pdfControllerList[i]
                                              .text
                                              .isNotEmpty) {
                                            pdfCodeList
                                                .add(pdfControllerList[i].text);
                                          }
                                        }
                                        LoaderDialogs.showLoadingDialog();

                                        FirebaseFirestore.instance
                                            .collection(topic)
                                            .doc(widget.topicData.docId)
                                            .update({
                                          'pdf_code_list': pdfCodeList,
                                        }).then((value) {
                                          Navigator.pop(context);
                                          Helper.showSnackBarMessage(
                                              msg:
                                                  "Pdf code added successfully",
                                              isSuccess: true);
                                          setState(() {
                                            pdfControllerList.clear();
                                          });
                                          Navigator.pop(context);
                                        });
                                      },
                                      controllerList: pdfControllerList,
                                    ),
                                    TopicTable(
                                      topicText: "Quiz",
                                      topicName: widget.topicData.name,
                                      onChanged: (value) {},
                                      onAdd: () {
                                        setState(() {
                                          quizControllerList
                                              .add(TextEditingController());
                                        });
                                      },
                                      onRemove: (index) {
                                        setState(() {
                                          quizControllerList.removeAt(index);
                                        });
                                      },
                                      onSave: () {
                                        List<String> quizCodeList = [];
                                        for (int i = 0;
                                            i < quizControllerList.length;
                                            i++) {
                                          if (quizControllerList[i]
                                              .text
                                              .isNotEmpty) {
                                            quizCodeList.add(
                                                quizControllerList[i].text);
                                          }
                                        }
                                        LoaderDialogs.showLoadingDialog();

                                        FirebaseFirestore.instance
                                            .collection(topic)
                                            .doc(widget.topicData.docId)
                                            .update({
                                          'quiz_code_list': quizCodeList,
                                        }).then((value) {
                                          Navigator.pop(context);
                                          Helper.showSnackBarMessage(
                                              msg:
                                                  "Quiz code added successfully",
                                              isSuccess: true);
                                          setState(() {
                                            quizControllerList.clear();
                                          });
                                          Navigator.pop(context);
                                        });
                                      },
                                      controllerList: quizControllerList,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        )),
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
