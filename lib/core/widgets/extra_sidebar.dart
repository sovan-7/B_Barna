import 'package:flutter/material.dart';
import 'package:bbarna/core/widgets/sidebar.dart';
import 'package:bbarna/core/widgets/sidebar_widget.dart';
import 'package:bbarna/resources/app_colors.dart';

class ExtraSideBar extends StatefulWidget {
  final int sidebarIndex;
  final bool isFromLogin;
  const ExtraSideBar(
      {required this.sidebarIndex, this.isFromLogin = false, super.key});

  @override
  State<ExtraSideBar> createState() => _ExtraSideBarState();
}

class _ExtraSideBarState extends State<ExtraSideBar> {
  int selectedIndex = 0;

  List<String> drawerItems = [
    "BANNERS",
    "COURSES",
    "SUBJECT",
    "UNIT",
    "TOPIC",
    "VIDEOS",
    "PDF",
    "AUDIO",
    "QUIZ",
    "QUESTIONS",
    "STUDENTS",
    "TEACHERS",
  ];

  List<IconData> iconList = [
    Icons.image,
    Icons.subject_outlined,
    Icons.book,
    Icons.ad_units,
    Icons.topic_outlined,
    Icons.video_file,
    Icons.picture_as_pdf,
    Icons.audio_file,
    Icons.quiz_outlined,
    Icons.question_mark_sharp,
    Icons.people,
    Icons.people_alt_outlined,
  ];
  @override
  void initState() {
    selectedIndex = widget.sidebarIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          // color: Colors.pink,
          child: Image.asset(
            "assets/images/logo.png",
            height: 150,
            width: 150,
          ),
        ),
        Expanded(
          child: Container(
            color: AppColorsInApp.colorGrey.withValues(alpha: .4),
            child: ListView.builder(
                itemCount: drawerItems.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      if (widget.isFromLogin) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Sidebar(sidebarIndex: index)));
                      } else {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Sidebar(sidebarIndex: index)));
                      }
                    },
                    child: SidebarWidget(
                      iconData: iconList[index],
                      itemText: drawerItems[index],
                      isSelected: index == selectedIndex,
                    ),
                  );
                }),
          ),
        )
      ],
    );
  }
}
