import 'package:bbarna/resources/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EnrolledCourseBaseModel {
  String studentId = stringDefault;
  String studentName = stringDefault;
  List<EnrolledCourseModel> enrolledCourseList = [];
  String docId = stringDefault;
  EnrolledCourseBaseModel.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc)
      : studentId = doc.data()?["student_id"] ?? stringDefault,
        studentName = doc.data()?["student_name"] ?? stringDefault,
        docId = doc.id,
        // Empty, not a placeholder. This used to build one course out of
        // leftover debug strings — "hggh", "bvnbn", "jhjh" — so a student
        // with no enrolments showed a course named "jhjh".
        enrolledCourseList = doc.data()?["course_list"] == null
            ? <EnrolledCourseModel>[]
            : List<EnrolledCourseModel>.from(
                (doc.data()?["course_list"] as List<dynamic>).map((x) =>
                    EnrolledCourseModel.fromMap(x as Map<String, dynamic>)));

  Map<String, dynamic> toMap() {
    return {
      "student_id": studentId,
      "student_name": studentName,
      "course_list":
          enrolledCourseList.map((course) => course.toMap()).toList(),
    };
  }
}

class EnrolledCourseModel {
  String subjectCode = stringDefault;
  String subjectName = stringDefault;
  String subjectImage = stringDefault;
  int accessTill = intDefault;
  String accessType = stringDefault;
  List<String> unitCodeList = [];

  EnrolledCourseModel(
    this.subjectCode,
    this.subjectName,
    this.subjectImage,
    this.accessTill,
    this.accessType,
    this.unitCodeList,
  );
// Convert ResultModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      "subject_code": subjectCode,
      "subject_name": subjectName,
      "subject_image": subjectImage,
      "access_till": accessTill,
      "access_type": accessType,
      "unit_code_list": unitCodeList,
    };
  }

  EnrolledCourseModel.fromMap(Map<String, dynamic> map)
      : subjectCode = map["subject_code"] ?? stringDefault,
        subjectName = map["subject_name"] ?? stringDefault,
        subjectImage = map["subject_image"] ?? stringDefault,
        accessTill = map["access_till"] ?? intDefault,
        accessType = map["access_type"] ?? stringDefault,
        unitCodeList = map["unit_code_list"] == null
            ? []
            : List<String>.from(map["unit_code_list"] as List<dynamic>);
}
