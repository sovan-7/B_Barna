import 'package:bbarna/banners/viewModel/banners_viewmodel.dart';
import 'package:bbarna/core/widgets/sidebar.dart';
import 'package:bbarna/course/viewModel/course_view_model.dart';
import 'package:bbarna/documents/audio/viewModel/audio_view_model.dart';
import 'package:bbarna/documents/pdf/viewModel/pdf_view_model.dart';
import 'package:bbarna/documents/video/viewModel/video_view_model.dart';
import 'package:bbarna/login/screen/login_screen.dart';
import 'package:bbarna/question/question_viewmodel/question_viewmodel.dart';
import 'package:bbarna/quiz/viewModel/quiz_view_model.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/student/viewModel/student_viewmodel.dart';
import 'package:bbarna/subject/viewModel/subject_view_model.dart';
import 'package:bbarna/teacher/viewModel/teacher_view_model.dart';
import 'package:bbarna/topic/viewModel/topic_view_model.dart';
import 'package:bbarna/units/viewModel/unit_view_model.dart';
import 'package:bbarna/utils/size_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDMo9aZg1-zlGXCfp2Bft6o3MZaFwiv67Q",
          appId: "1:23963148123:web:f16c6712a418dedecc847e",
          messagingSenderId: "23963148123",
          projectId: "bbarna-6a725",
          authDomain: "bbarna-6a725.firebaseapp.com",
          storageBucket: "bbarna-6a725.appspot.com",
          measurementId: "G-T6QDXLT4V0"));

  sharedPreferences = await SharedPreferences.getInstance();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => QuestionViewModel()),
      ChangeNotifierProvider(create: (_) => CourseViewModel()),
      ChangeNotifierProvider(create: (_) => SubjectViewModel()),
      ChangeNotifierProvider(create: (_) => UnitViewModel()),
      ChangeNotifierProvider(create: (_) => TopicViewModel()),
      ChangeNotifierProvider(create: (_) => VideoViewModel()),
      ChangeNotifierProvider(create: (_) => PdfViewModel()),
      ChangeNotifierProvider(create: (_) => AudioViewModel()),
      ChangeNotifierProvider(create: (_) => QuizViewModel()),
      ChangeNotifierProvider(create: (_) => BannersViewModel()),
      ChangeNotifierProvider(create: (_) => StudentViewModel()),
      ChangeNotifierProvider(create: (_) => TeacherViewModel()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: snackBarKey,
        navigatorKey: navigatorKey,
        key: scaffoldKey,
        title: "BBARNA",
        home: sharedPreferences.getString("admin_id") != null
            ? const Sidebar(sidebarIndex: 0)
            : const LoginScreen());
  }
}
