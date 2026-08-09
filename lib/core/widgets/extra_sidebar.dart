import 'package:flutter/material.dart';
import 'package:bbarna/core/widgets/sidebar.dart';
import 'package:bbarna/core/widgets/sidebar_widget.dart';
import 'package:bbarna/resources/app_colors.dart';
import 'package:bbarna/resources/constant.dart';

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

  List<String> drawerItems = moduleList;

  List<IconData> iconList = moduleIconList;
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
