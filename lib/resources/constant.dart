import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<ScaffoldMessengerState> snackBarKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
late SharedPreferences sharedPreferences;

/// null check default value
int intDefault = -1;
double doubleDefault = -1;
bool boolDefault = false;
String stringDefault = "NA";

/// firestore collection names

const String admin = "admin";
const String question = "question";
const String course = "course";
const String subject = "subject";
const String unit = "unit";
const String topic = "topic";
const String video = "video";
const String pdf = "pdf";
const String audio = "audio";
const String quiz = "quiz";
const String banners = "banners";
const String student = "student";
const String enrolledCourse = "enrolledCourses";
const String teacher = "teacher";

/// Sidebar module names/icons, index-aligned. [Sidebar] and [ExtraSideBar]
/// render navigation from this list; [AddTeacher] generates its
/// module-access checkboxes from the same list so the two never drift apart.
const List<String> moduleList = [
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

const List<IconData> moduleIconList = [
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

