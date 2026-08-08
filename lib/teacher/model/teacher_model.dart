import 'package:bbarna/resources/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherModel {
  String docId = stringDefault;
  String name = stringDefault;
  String imageUrl = stringDefault;
  String username = stringDefault;
  String password = stringDefault;
  int timeStamp = intDefault;

  TeacherModel({
    required this.docId,
    required this.name,
    required this.imageUrl,
    required this.username,
    required this.password,
    required this.timeStamp,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "image_url": imageUrl,
      "username": username,
      "password": password,
      "timeStamp": timeStamp,
    };
  }

  TeacherModel.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : docId = doc.id,
        name = doc.data()!["name"] ?? stringDefault,
        imageUrl = doc.data()!["image_url"] ?? stringDefault,
        username = doc.data()!["username"] ?? stringDefault,
        password = doc.data()!["password"] ?? stringDefault,
        timeStamp = doc.data()!["timeStamp"] ?? intDefault;
}
