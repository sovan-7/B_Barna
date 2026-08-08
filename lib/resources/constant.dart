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



