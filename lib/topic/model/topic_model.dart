import 'package:bbarna/resources/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Which Firestore array on the topic document holds a kind of content, and
/// where the codes in it point.
///
/// The four content lists were four copy-pasted blocks in the details
/// screen, each writing a hard-coded field name through a raw
/// `FirebaseFirestore.instance` call. Naming them once means the screen,
/// the view model and the repo cannot drift apart on a spelling.
enum ContentKind { video, audio, pdf, quiz }

extension ContentKindData on ContentKind {
  /// The array field on the topic document.
  String get field => switch (this) {
        ContentKind.video => "video_code_list",
        ContentKind.audio => "audio_code_list",
        ContentKind.pdf => "pdf_code_list",
        ContentKind.quiz => "quiz_code_list",
      };

  /// The collection the codes point into.
  String get collection => switch (this) {
        ContentKind.video => video,
        ContentKind.audio => audio,
        ContentKind.pdf => pdf,
        ContentKind.quiz => quiz,
      };

  /// The code field on that collection's documents.
  String get codeField => switch (this) {
        ContentKind.video => "video_code",
        ContentKind.audio => "audio_code",
        ContentKind.pdf => "pdf_code",
        ContentKind.quiz => "quiz_code",
      };

  /// The human-readable field on that collection's documents. Quizzes call
  /// theirs `quiz_name`; the other three call theirs `*_title`.
  String get titleField => switch (this) {
        ContentKind.video => "video_title",
        ContentKind.audio => "audio_title",
        ContentKind.pdf => "pdf_title",
        ContentKind.quiz => "quiz_name",
      };

  String get label => switch (this) {
        ContentKind.video => "Video",
        ContentKind.audio => "Audio",
        ContentKind.pdf => "PDF",
        ContentKind.quiz => "Quiz",
      };

  /// The label as it reads mid-sentence. PDF is an acronym, so it does not
  /// lowercase the way the other three do.
  String get inlineLabel =>
      this == ContentKind.pdf ? "PDF" : label.toLowerCase();
}

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

  /// The codes attached for one kind of content.
  List<String> contentCodes(ContentKind kind) => switch (kind) {
        ContentKind.video => videoCodeList,
        ContentKind.audio => audioCodeList,
        ContentKind.pdf => pdfCodeList,
        ContentKind.quiz => quizCodeList,
      };

  void setContentCodes(ContentKind kind, List<String> codes) {
    switch (kind) {
      case ContentKind.video:
        videoCodeList = codes;
      case ContentKind.audio:
        audioCodeList = codes;
      case ContentKind.pdf:
        pdfCodeList = codes;
      case ContentKind.quiz:
        quizCodeList = codes;
    }
  }

  /// How many pieces of content of any kind are attached.
  int get contentCount =>
      videoCodeList.length +
      audioCodeList.length +
      pdfCodeList.length +
      quizCodeList.length;

  /// The topic's own details — deliberately *not* the four content arrays.
  ///
  /// Editing a topic builds a fresh model from the form, which knows
  /// nothing about attached content; writing the arrays from here would
  /// send four empty lists and detach every video, audio, PDF and quiz on
  /// the topic. The content arrays are owned by the content screen and
  /// written one at a time through `TopicRepo.setContentCodes`, and this
  /// map is applied with `update()`, which merges — so the fields it omits
  /// are left exactly as they are.
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
