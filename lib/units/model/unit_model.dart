import 'package:bbarna/resources/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UnitModel {
  String id = stringDefault;
  String code = stringDefault;
  String courseCode = stringDefault;
  String courseName = stringDefault;
  String subjectCode = stringDefault;
  String subjectName = stringDefault;
  bool lockStatus = boolDefault;
  int timeStamp = intDefault;
  String description = stringDefault;
  String name = stringDefault;
  String image = stringDefault;
  int displayPriority = intDefault;
  bool willShow = boolDefault;
  bool isSelected = boolDefault;
  List<String> subjectCodeList = [];

  UnitModel(
      this.courseCode,
      this.courseName,
      this.subjectCode,
      this.subjectName,
      this.lockStatus,
      this.code,
      this.description,
      this.name,
      this.image,
      this.displayPriority,
      this.timeStamp,
      this.willShow,
      this.subjectCodeList);

  Map<String, dynamic> toMap() {
    return {
      "course_code": courseCode,
      "course_name": courseName,
      "subject_code": subjectCode,
      "subject_name": subjectName,
      "unit_name": name,
      "unit_code": code.trim(),
      "unit_description": description,
      "timeStamp": timeStamp,
      "lock_status": lockStatus,
      "unit_image": image,
      "display_priority": displayPriority,
      "willShow": willShow,
      "subjectCodeList": subjectCodeList
    };
  }

  UnitModel.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        courseCode = doc.data()!["course_code"] ?? stringDefault,
        courseName = doc.data()!["course_name"] ?? stringDefault,
        subjectCode = doc.data()!["subject_code"] ?? stringDefault,
        subjectName = doc.data()!["subject_name"] ?? stringDefault,
        code = doc.data()!["unit_code"] ?? stringDefault,
        description = doc.data()!["unit_description"] ?? stringDefault,
        name = doc.data()!["unit_name"] ?? stringDefault,
        image = doc.data()!["unit_image"] ?? stringDefault,
        lockStatus = doc.data()!["lock_status"] ?? boolDefault,
        displayPriority = doc.data()!["display_priority"] ?? intDefault,
        timeStamp = doc.data()!["timeStamp"] ?? intDefault,
        willShow = doc.data()!["willShow"] ?? boolDefault,
        subjectCodeList = List<String>.from(
            doc.data()!["subjectCodeList"] ?? const <String>[]),
        isSelected = false;
}