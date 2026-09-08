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

  /// The coupon live on this subject, as the student app reads it:
  /// `couponDiscount` is a flat rupee amount off `sellingPrice`, not a
  /// percentage, and `couponValidTill` is epoch millis.
  ///
  /// Read-only in this panel. They are deliberately absent from [toMap]
  /// because there is no coupon editor here, and writing the "NA"/-1
  /// defaults back would wipe a live coupon on every subject save.
  /// [SubjectRepo.updateSubject] uses `update()`, which touches only the
  /// keys [toMap] lists, so the document keeps them.
  String couponCode = stringDefault;
  double couponDiscount = doubleDefault;
  int couponValidTill = intDefault;

  SubjectModel(
    this.courseCode,
    this.courseType,
    this.courseName,
    this.price,
    this. sellingPrice,
    this.code,
    this.description,
    this.name,
    this.image,
    this.displayPriority,
    this.timeStamp,
    this.willDisplay,
    this.isLocked,
    this.isPopular
  );

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
      "selling_price":sellingPrice,
      "willDisplay": willDisplay,
      "isLocked": isLocked,
      "isPopular":isPopular
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
        sellingPrice=doc.data()!["selling_price"] ?? doubleDefault,
        displayPriority = doc.data()!["display_priority"] ?? intDefault,
        willDisplay = doc.data()!["willDisplay"] ?? boolDefault,
        isLocked = doc.data()!["isLocked"] ?? boolDefault,
        timeStamp = doc.data()!["created_at"] ?? intDefault,
        isPopular=doc.data()!["isPopular"] ?? boolDefault,
        couponCode = doc.data()!["couponCode"] ?? stringDefault,
        // Firestore hands a whole number back as an int, so cast through num
        // rather than assuming double.
        couponDiscount =
            (doc.data()!["couponDiscount"] as num?)?.toDouble() ?? doubleDefault,
        couponValidTill = doc.data()!["couponValidTill"] ?? intDefault,
        isSelected = false;
}
