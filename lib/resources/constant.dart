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
const String liveClasses = "live_classes";

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
  "LIVE CLASSES",
];

/// Position of the Live Classes module within [moduleList] — the value
/// every Live Class screen passes as `ExtraSideBar(sidebarIndex: ...)`.
const int liveClassModuleIndex = 12;

/// What the sidebar *shows*, index-aligned with [moduleList].
///
/// [moduleList] is the persisted identity of a module: a teacher's
/// module-access list stores those exact strings and
/// `Helper.allowedModuleIndices` matches on them, so renaming an entry
/// there would silently revoke access for every existing teacher. This
/// list carries the human label instead, and is safe to reword.
const List<String> moduleDisplayList = [
  "Banners",
  "Courses",
  "Subjects",
  "Units",
  "Topics",
  "Videos",
  "PDFs",
  "Audio",
  "Quizzes",
  "Questions",
  "Students",
  "Teachers",
  "Live Classes",
];

const String roleAdmin = "admin";
const String roleSubadmin = "subadmin";

/// SharedPreferences key the logged-in teacher's module_access list is
/// stored under at login — [Sidebar] and [ExtraSideBar] read it back to
/// restrict which modules they render.
const String moduleAccessPrefsKey = "module_access";

/// SharedPreferences key remembering whether the navigation rail was left
/// collapsed, so the choice survives the pushReplacement each add/edit
/// screen makes on its way back to [Sidebar].
const String sidebarCollapsedPrefsKey = "sidebar_collapsed";

/// [AddTeacher] generates its role selector from this list — keep it as the
/// single source of truth for valid teacher roles.
const List<String> roleList = [roleAdmin, roleSubadmin];

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
  Icons.live_tv,
];

