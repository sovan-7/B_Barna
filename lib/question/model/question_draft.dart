import 'package:bbarna/question/model/question.dart';

/// Which option a question's answer points at.
enum QuestionOption { a, b, c, d }

extension QuestionOptionLabel on QuestionOption {
  String get label => switch (this) {
        QuestionOption.a => "A",
        QuestionOption.b => "B",
        QuestionOption.c => "C",
        QuestionOption.d => "D",
      };

  /// The form field this option's text lives in.
  QuestionField get field => switch (this) {
        QuestionOption.a => QuestionField.optionA,
        QuestionOption.b => QuestionField.optionB,
        QuestionOption.c => QuestionField.optionC,
        QuestionOption.d => QuestionField.optionD,
      };
}

/// The fields a question form collects, as plain strings.
///
/// The rich-text editors are webviews, so nothing that reads them can be
/// exercised in a test. Pulling the *rules* out into a plain value means
/// validation and assembly can be tested on their own, and the form is left
/// doing only what a form should: gather text, hand it over, show errors.
class QuestionDraft {
  final String code;
  final String question;
  final String questionBody;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String hints;
  final String solution;
  final QuestionOption? answer;

  const QuestionDraft({
    this.code = "",
    this.question = "",
    this.questionBody = "",
    this.optionA = "",
    this.optionB = "",
    this.optionC = "",
    this.optionD = "",
    this.hints = "",
    this.solution = "",
    this.answer,
  });

  String optionFor(QuestionOption option) => switch (option) {
        QuestionOption.a => optionA,
        QuestionOption.b => optionB,
        QuestionOption.c => optionC,
        QuestionOption.d => optionD,
      };

  /// Which option [question]'s stored answer matches, or null when it
  /// matches none.
  ///
  /// The old lookup was an if/else chain whose final `else` returned option
  /// 4 — so a question with no answer saved, or one whose answer no longer
  /// matched any option, displayed D as correct.
  static QuestionOption? answerOf(Question question) {
    final String answer = _strip(question.answer);
    if (answer.isEmpty) return null;
    for (final QuestionOption option in QuestionOption.values) {
      final String text = _strip(switch (option) {
        QuestionOption.a => question.option1,
        QuestionOption.b => question.option2,
        QuestionOption.c => question.option3,
        QuestionOption.d => question.option4,
      });
      if (text.isNotEmpty && text == answer) return option;
    }
    return null;
  }

  /// Field-keyed problems with this draft. Empty means valid.
  Map<QuestionField, String> validate() {
    final Map<QuestionField, String> errors = {};

    if (code.trim().isEmpty) {
      errors[QuestionField.code] = "Give the question a code";
    }
    if (_strip(question).isEmpty) {
      errors[QuestionField.question] = "Write the question";
    }

    // All four options are required: a multiple-choice question with a
    // blank option is one a student can pick and never be right about.
    // Only the code, the question and *an* answer were checked before.
    for (final QuestionOption option in QuestionOption.values) {
      if (_strip(optionFor(option)).isEmpty) {
        errors[option.field] = "Fill in option ${option.label}";
      }
    }

    if (answer == null) {
      errors[QuestionField.answer] = "Mark which option is correct";
    } else if (_strip(optionFor(answer!)).isEmpty) {
      errors[QuestionField.answer] =
          "Option ${answer!.label} is empty — it cannot be the answer";
    }
    return errors;
  }


  /// The document body this draft saves as.
  Map<String, dynamic> toMap({required int timeStamp}) => {
        "question_code": code.trim().toUpperCase(),
        "question": question,
        "question_body": questionBody,
        "option1": optionA,
        "option2": optionB,
        "option3": optionC,
        "option4": optionD,
        "hints": hints,
        "solution": solution,
        "answer": answer == null ? "" : optionFor(answer!),
        "timeStamp": timeStamp,
      };

  /// Rich text with its markup removed, for emptiness checks and for
  /// showing a question as one line in a list.
  static String plainText(String html) {
    final String text = html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&#39;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return text;
  }

  static String _strip(String html) => plainText(html);
}

/// Every field of the question form that can carry an inline error.
enum QuestionField { code, question, optionA, optionB, optionC, optionD, answer }
