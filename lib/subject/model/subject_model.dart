import 'package:bbarna/resources/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectModel {
  String docId = stringDefault;
  String code = stringDefault;
  String courseCode = stringDefault;
  String courseName = stringDefault;
  String courseType = stringDefault;
  int timeStamp = intDefault;
  String description = stringDefault;
  String name = stringDefault;
  String image = stringDefault;
  double price = doubleDefault;
  double sellingPrice = doubleDefault;
  int displayPriority = intDefault;
  bool willDisplay = boolDefault;
  bool isLocked = boolDefault;
  bool isSelected = boolDefault;
  bool isPopular = boolDefault;
  String couponCode = stringDefault;
  double couponDiscount = doubleDefault;
  int couponValidTill = intDefault;

  SubjectModel(
      this.courseCode,
      this.courseType,
      this.courseName,
      this.price,
      this.sellingPrice,
      this.code,
      this.description,
      this.name,
      this.image,
      this.displayPriority,
      this.timeStamp,
      this.willDisplay,
      this.isLocked,
      this.isPopular,
      this.couponCode,
      this.couponDiscount,
      this.couponValidTill);

  Map<String, dynamic> toMap() {
    return {
      "course_code": courseCode,
      "course_type": courseType,
      "course_name": courseName,
      "subject_code": code.trim(),
      "subject_description": description,
      "subject_name": name,
      "created_at": timeStamp,
      "subject_image": image,
      "display_priority": displayPriority,
      "subject_price": price,
      "selling_price": sellingPrice,
      "willDisplay": willDisplay,
      "isLocked": isLocked,
      "isPopular": isPopular,
      "couponCode": couponCode,
      "couponDiscount": couponDiscount,
      "couponValidTill": couponValidTill
    };
  }

  SubjectModel.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : docId = doc.id,
        courseCode = doc.data()!["course_code"] ?? stringDefault,
        courseType = doc.data()!["course_type"] ?? stringDefault,
        courseName = doc.data()!["course_name"] ?? stringDefault,
        code = doc.data()!["subject_code"] ?? stringDefault,
        description = doc.data()!["subject_description"] ?? stringDefault,
        name = doc.data()!["subject_name"] ?? stringDefault,
        image = doc.data()!["subject_image"] ?? stringDefault,
        price = doc.data()!["subject_price"] ?? doubleDefault,
        sellingPrice = doc.data()!["selling_price"] ?? doubleDefault,
        displayPriority = doc.data()!["display_priority"] ?? intDefault,
        willDisplay = doc.data()!["willDisplay"] ?? boolDefault,
        isLocked = doc.data()!["isLocked"] ?? boolDefault,
        timeStamp = doc.data()!["created_at"] ?? intDefault,
        isPopular = doc.data()!["isPopular"] ?? boolDefault,
        isSelected = false,
        couponCode = doc.data()!["couponCode"] ?? stringDefault,
        couponDiscount = doc.data()!["couponDiscount"] ?? doubleDefault,
        couponValidTill = doc.data()!["couponValidTill"] ?? intDefault;
}
