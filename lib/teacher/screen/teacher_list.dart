import 'package:bbarna/core/widgets/add_widget.dart';
import 'package:bbarna/core/widgets/custom_searchbar.dart';
import 'package:bbarna/resources/app_colors.dart';
import 'package:bbarna/teacher/screen/add_teacher.dart';
import 'package:bbarna/teacher/viewModel/teacher_view_model.dart';
import 'package:bbarna/teacher/widgets/teacher_card.dart';
import 'package:bbarna/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeacherList extends StatefulWidget {
  const TeacherList({super.key});

  @override
  State<TeacherList> createState() => _TeacherListState();
}

class _TeacherListState extends State<TeacherList> {
  TeacherViewModel _teacherViewModel = TeacherViewModel();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    _teacherViewModel = Provider.of(context, listen: false);
    getTeacherList();
    super.initState();
  }

  void getTeacherList() async {
    await _teacherViewModel.getTeacherList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherViewModel>(builder: (context, teacherVM, child) {
      return Container(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
          bottom: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "TEACHER LIST",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 1.0,
                      color: AppColorsInApp.colorBlack1),
                ),
                AddWidget(
                  addCall: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddTeacher()))
                        .whenComplete(() {
                      if (searchController.text.isEmpty) {
                        Provider.of<TeacherViewModel>(context, listen: false)
                            .getTeacherList();
                      }
                    });
                  },
                )
              ],
            ),
            CustomSearchBar(
              textEditingController: searchController,
              onChange: () {
                teacherVM.searchTeacher(searchText: searchController.text);
              },
              onClear: () {
                searchController.clear();
                teacherVM.searchTeacher(searchText: searchController.text);
              },
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.withOpacity(0.2)),
                child: teacherVM.teacherList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_alt_outlined,
                              size: 60,
                              color: AppColorsInApp.colorGrey,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "No teachers added yet",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: AppColorsInApp.colorGrey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: teacherVM.teacherList.length,
                        itemBuilder: (context, index) {
                          return SizeConfig.screenWidth! < 900
                              ? FittedBox(
                                  child: TeacherCard(
                                    teacherData: teacherVM.teacherList[index],
                                  ),
                                )
                              : TeacherCard(
                                  teacherData: teacherVM.teacherList[index],
                                );
                        }),
              ),
            )
          ],
        ),
      );
    });
  }
}
