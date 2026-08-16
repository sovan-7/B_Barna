import 'package:bbarna/resources/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TopicModel {
  String docId = stringDefault;
  String code = stringDefault;
  int timeStamp = intDefault;
  String name = stringDefault;
  String courseName = stringDefault;
  String courseCode = stringDefault;
  String subjectName = stringDefault;
  String subjectCode = stringDefault;
  String unitName = stringDefault;
  String unitCode = stringDefault;
  int displayPriority = intDefault;
  List<String> audioCodeList = [];
  List<String> quizCodeList = [];
  List<String> videoCodeList = [];
  List<String> pdfCodeList = [];
  List<String> unitCodeList = [];

  TopicModel(
      this.code,
      this.name,
      this.timeStamp,
      this.courseName,
      this.courseCode,
      this.subjectName,
      this.subjectCode,
      this.unitName,
      this.unitCode,
      this.displayPriority,
      this.unitCodeList);

  Map<String, dynamic> toMap() {
    return {
      "topic_code": code.trim(),
      "topic_name": name,
      "timeStamp": timeStamp,
      "course_name": courseName,
      "course_code": courseCode,
      "subject_name": subjectName,
      "subject_code": subjectCode,
      "unit_name": unitName,
      "unit_code": unitCode,
      "display_priority": displayPriority,
      "unitCodeList": unitCodeList
    };
  }

  TopicModel.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : docId = doc.id,
        code = doc.data()!["topic_code"] ?? stringDefault,
        name = doc.data()!["topic_name"] ?? stringDefault,
        timeStamp = doc.data()!["timeStamp"] ?? intDefault,
        courseName = doc.data()!["course_name"] ?? stringDefault,
        courseCode = doc.data()!["course_code"] ?? stringDefault,
        subjectName = doc.data()!["subject_name"] ?? stringDefault,
        subjectCode = doc.data()!["subject_code"] ?? stringDefault,
        unitName = doc.data()!["unit_name"] ?? stringDefault,
        unitCode = doc.data()!["unit_code"] ?? stringDefault,
        displayPriority = doc.data()!["display_priority"] ?? intDefault,
        audioCodeList = doc.data()!["audio_code_list"] == null
            ? []
            : List<String>.from(doc.data()!["audio_code_list"].map((x) => x)),
        videoCodeList = doc.data()!["video_code_list"] == null
            ? []
            : List<String>.from(doc.data()!["video_code_list"].map((x) => x)),
        pdfCodeList = doc.data()!["pdf_code_list"] == null
            ? []
            : List<String>.from(doc.data()!["pdf_code_list"].map((x) => x)),
        quizCodeList = doc.data()!["quiz_code_list"] == null
            ? []
            : List<String>.from(doc.data()!["quiz_code_list"].map((x) => x)),
        unitCodeList = doc.data()!["unitCodeList"] == null
            ? []
            : List<String>.from(doc.data()!["unitCodeList"].map((x) => x));
}
