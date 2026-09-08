import 'package:bbarna/core/widgets/selectable_label.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/student/model/enrolled_course_model.dart';
import 'package:bbarna/student/model/student_model.dart';
import 'package:bbarna/student/repo/student_repo.dart';
import 'package:bbarna/course/model/course_model.dart';
import 'package:bbarna/student/screen/settings_student.dart';
import 'package:bbarna/student/screen/student_list.dart';
import 'package:bbarna/student/widgets/enrolment_validity.dart';
import 'package:bbarna/student/widgets/unit_picker_dialog.dart';
import 'package:bbarna/units/model/unit_model.dart';
import 'package:bbarna/student/viewModel/student_viewmodel.dart';
import 'package:bbarna/student/widgets/student_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockStudentRepo extends Mock implements StudentRepo {}

Student _student(
  String id,
  String name, {
  String phone = "9876543210",
  String email = "a@example.com",
  dynamic devices = 0,
}) =>
    Student(
      studentId: id,
      studentName: name,
      studentProfileImage: "",
      studentPhoneNumber: phone,
      studentWhatsappNumber: phone,
      studentEmail: email,
      deviceCount: devices,
    );

List<Student> _fixture() => [
      _student('a', 'Anita Desai', phone: "9000000001", devices: 2),
      _student('b', 'Ravi Kumar',
          phone: "9000000002", email: "ravi@example.com"),
      _student('c', 'Subramanian Venkataraghavan Iyer',
          phone: "9000000003", email: "", devices: 1),
    ];

const List<Size> _sizes = [
  Size(1440, 900),
  Size(1024, 768),
  Size(700, 900),
  Size(380, 820),
];

late MockStudentRepo repo;

Future<void> _pump(
    WidgetTester tester, Size size, Widget home, StudentViewModel vm) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(ChangeNotifierProvider<StudentViewModel>.value(
    value: vm,
    child: MaterialApp(navigatorKey: navigatorKey, home: home),
  ));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUp(() {
    repo = MockStudentRepo();
    when(() => repo.getFirstStudentList(any()))
        .thenAnswer((_) async => _fixture());
    when(() => repo.getStudentListLength()).thenAnswer((_) async => 3);
  });

  group('layout', () {
    for (final Size size in _sizes) {
      testWidgets('the list lays out at ${size.width.toInt()}', (tester) async {
        final vm = StudentViewModel(studentRepo: repo);
        await _pump(tester, size, const Scaffold(body: StudentList()), vm);

        expect(tester.takeException(), isNull);
        expect(find.text('Students'), findsOneWidget);
        expect(find.byType(StudentCard), findsNWidgets(3));
      });
    }
  });

  group('the card', () {
    testWidgets('shows contact details and missing ones', (tester) async {
      final vm = StudentViewModel(studentRepo: repo);
      await _pump(tester, const Size(1440, 900),
          const Scaffold(body: StudentList()), vm);

      expect(find.text('Anita Desai'), findsOneWidget);
      expect(find.text('9000000001'), findsOneWidget);
      expect(find.text('No email'), findsOneWidget);
    });

    testWidgets('says how many devices a student is signed in on',
        (tester) async {
      final vm = StudentViewModel(studentRepo: repo);
      await _pump(tester, const Size(1440, 900),
          const Scaffold(body: StudentList()), vm);

      // It used to be a bare logout icon with " - 2" beside it.
      expect(find.text('2 devices'), findsOneWidget);
      expect(find.text('1 device'), findsOneWidget);
      expect(find.text('No devices'), findsOneWidget);
    });

    testWidgets('a device count stored as a string still reads', (tester) async {
      // `deviceCount` is `dynamic` on the model and arrives either way.
      when(() => repo.getFirstStudentList(any()))
          .thenAnswer((_) async => [_student('a', 'Anita', devices: "3")]);

      final vm = StudentViewModel(studentRepo: repo);
      await _pump(tester, const Size(1440, 900),
          const Scaffold(body: StudentList()), vm);

      expect(find.text('3 devices'), findsOneWidget);
    });
  });

  group('the list', () {
    testWidgets('says how much of the collection is loaded', (tester) async {
      when(() => repo.getStudentListLength()).thenAnswer((_) async => 4200);
      final vm = StudentViewModel(studentRepo: repo);
      await _pump(tester, const Size(1440, 900),
          const Scaffold(body: StudentList()), vm);

      expect(find.text('Showing 3 of 4200'), findsOneWidget);
      expect(find.byKey(const Key('paged_list_load_more')), findsOneWidget);
    });

    testWidgets('search filters by name, phone or email', (tester) async {
      final vm = StudentViewModel(studentRepo: repo);
      await _pump(tester, const Size(1440, 900),
          const Scaffold(body: StudentList()), vm);

      await tester.enterText(find.byType(TextField).first, 'anita');
      await tester.pump();
      expect(find.byType(StudentCard), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '9000000002');
      await tester.pump();
      expect(find.byType(StudentCard), findsOneWidget);

      // Email was never searched before.
      await tester.enterText(find.byType(TextField).first, 'ravi@');
      await tester.pump();
      expect(find.byType(StudentCard), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '');
      await tester.pump();
      expect(find.byType(StudentCard), findsNWidgets(3));
    });

    testWidgets('mounting mid-build does not throw', (tester) async {
      final vm = StudentViewModel(studentRepo: repo);
      await _pump(tester, const Size(1024, 768),
          const Scaffold(body: StudentList()), vm);
      expect(tester.takeException(), isNull);
    });
  });

  group('delete', () {
    test('removes the student from both lists, by id', () async {
      when(() => repo.deleteStudent(any())).thenAnswer((_) async {});

      final vm = StudentViewModel(studentRepo: repo);
      await vm.fetchFirstStudentList();

      expect(await vm.deleteStudent('b'), isTrue);

      verify(() => repo.deleteStudent('b')).called(1);
      expect(vm.studentList.map((s) => s.studentId).toList(), ['a', 'c']);
      // The old delete left copyStudentList holding the deleted student, so
      // clearing the search brought them back.
      expect(vm.copyStudentList.map((s) => s.studentId).toList(), ['a', 'c']);
      expect(vm.studentListLength, 2);
    });

    test('a deleted student does not come back when the search clears',
        () async {
      when(() => repo.deleteStudent(any())).thenAnswer((_) async {});

      final vm = StudentViewModel(studentRepo: repo);
      await vm.fetchFirstStudentList();
      await vm.deleteStudent('b');

      vm.searchStudent(searchText: "ravi");
      expect(vm.studentList, isEmpty);
      vm.searchStudent(searchText: "");
      expect(vm.studentList.map((s) => s.studentId).toList(), ['a', 'c']);
    });
  });

  group('devices', () {
    test('clearing the count goes through the repo and updates in place',
        () async {
      when(() => repo.clearDeviceCount(any())).thenAnswer((_) async {});

      final vm = StudentViewModel(studentRepo: repo);
      await vm.fetchFirstStudentList();

      expect(await vm.clearDeviceCount('a'), isTrue);

      // It used to write through FirebaseFirestore.instance from the list
      // widget and then set the count on whichever row sat at an index.
      verify(() => repo.clearDeviceCount('a')).called(1);
      expect(
          vm.studentList.firstWhere((s) => s.studentId == 'a').deviceCount, 0);
    });
  });

  group('enrolment validity', () {
    // 2026-01-01, so the arithmetic below is fixed rather than relative to
    // whenever the suite runs.
    final DateTime now = DateTime(2026, 1, 1);
    int inDays(int days) =>
        now.add(Duration(days: days)).millisecondsSinceEpoch;

    test('a value too short to be a timestamp reads as unset', () {
      expect(EnrolmentValidity.isUnset(intDefault), isTrue);
      expect(EnrolmentValidity.formatDate(intDefault), isNull);
      expect(EnrolmentValidity.formatRemaining(intDefault), isNull);
    });

    test('years are divided out, not left in the month count', () {
      // The old maths did `yearLeft = monthsLeft % 12` — a remainder where
      // a division belonged — and never subtracted the years, so 25 months
      // rendered as "1 Year 25 Months 5 Days Left".
      expect(EnrolmentValidity.formatRemaining(inDays(760), now: now),
          "2 years 1 month left");
      expect(EnrolmentValidity.formatRemaining(inDays(400), now: now),
          "1 year 1 month left");
    });

    test('days show on their own but not beside a year', () {
      expect(
          EnrolmentValidity.formatRemaining(inDays(5), now: now), "5 days left");
      expect(EnrolmentValidity.formatRemaining(inDays(1), now: now), "1 day left");
      expect(EnrolmentValidity.formatRemaining(inDays(45), now: now),
          "1 month 15 days left");
    });

    test('a date already past says so instead of "Invalid Data"', () {
      // Every branch of the old version tested `> 0`, so an expired
      // enrolment matched none of them and fell through.
      expect(EnrolmentValidity.formatRemaining(inDays(-30), now: now),
          "Expired");
      expect(EnrolmentValidity.hasExpired(inDays(-1), now: now), isTrue);
      expect(EnrolmentValidity.hasExpired(inDays(1), now: now), isFalse);
    });

    test('the end date is formatted for reading', () {
      expect(EnrolmentValidity.formatDate(DateTime(2026, 3, 14).millisecondsSinceEpoch),
          "14 Mar 2026");
    });
  });

  group('the settings screen', () {
    Future<void> pumpSettings(WidgetTester tester,
        {Size size = const Size(1024, 900)}) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(ChangeNotifierProvider<StudentViewModel>(
        create: (_) => StudentViewModel(studentRepo: repo),
        child: MaterialApp(
          navigatorKey: navigatorKey,
          home: const SettingStudent(
              studentId: 'a', studentName: 'Anita Desai'),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    setUp(() {
      when(() => repo.getCourseList()).thenAnswer((_) async => [
            CourseModel('PHY-11', '', 'Physics — Class 11', '', 1, 0, true,
                false),
          ]);
      when(() => repo.getSubjectList(any())).thenAnswer((_) async => []);
      when(() => repo.getEnrolledCourseList(any()))
          .thenAnswer((_) async => null);
    });

    for (final Size size in _sizes) {
      testWidgets('lays out at ${size.width.toInt()}', (tester) async {
        await pumpSettings(tester, size: size);
        expect(tester.takeException(), isNull);
        expect(find.text('Anita Desai'), findsOneWidget);
      });
    }

    testWidgets('a student with no enrolments says so, and does not crash',
        (tester) async {
      // getEnrolledCourseList used to take `docs.first` unguarded.
      await pumpSettings(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Not enrolled in anything yet'), findsOneWidget);
    });

    testWidgets('the subject picker waits for a course', (tester) async {
      await pumpSettings(tester);

      // The old gate watched `courseList.isEmpty` rather than the chosen
      // course, so this was open from the moment courses loaded.
      expect(find.text('Choose a course first'), findsOneWidget);
      final DropdownButton<String> subject =
          tester.widget(find.byKey(const Key('enrol_subject_dropdown')));
      expect(subject.onChanged, isNull);
    });

    testWidgets('the units picker waits for a subject', (tester) async {
      await pumpSettings(tester);
      expect(find.text('Choose a subject first'), findsOneWidget);
    });

    testWidgets('enrolling with nothing chosen names the missing field',
        (tester) async {
      await pumpSettings(tester);

      await tester.ensureVisible(find.byKey(const Key('student_enrol_button')));
      await tester.tap(find.byKey(const Key('student_enrol_button')));
      await tester.pump();

      // It used to say "Please fill the above field" whatever was missing.
      expect(find.text('Choose a course'), findsOneWidget);
      expect(find.text('Choose a subject'), findsOneWidget);
      expect(find.text('Choose at least one unit'), findsOneWidget);
      expect(find.text('Set how long the access lasts'), findsOneWidget);
    });

    testWidgets('an enrolment shows its units and validity', (tester) async {
      when(() => repo.getEnrolledCourseList(any()))
          .thenAnswer((_) async => _enrolment([
                EnrolledCourseModel('MECH', 'Mechanics', '',
                    DateTime(2027, 3, 14).millisecondsSinceEpoch, 'PAID',
                    ['U1', 'U2']),
                // An enrolment that grants nothing.
                EnrolledCourseModel('ORG', 'Organic Chemistry', '',
                    DateTime(2020, 1, 1).millisecondsSinceEpoch, 'PAID', []),
              ]));

      await pumpSettings(tester, size: const Size(1440, 900));

      expect(find.text('2 units'), findsOneWidget);
      expect(find.text('No units'), findsOneWidget);
      expect(find.text('14 Mar 2027'), findsOneWidget);
      expect(find.text('1 Jan 2020'), findsOneWidget);
    });

    testWidgets('each row toggles its own validity chip independently',
        (tester) async {
      when(() => repo.getEnrolledCourseList(any()))
          .thenAnswer((_) async => _enrolment([
                EnrolledCourseModel('MECH', 'Mechanics', '',
                    DateTime(2020, 1, 1).millisecondsSinceEpoch, 'PAID',
                    ['U1']),
                EnrolledCourseModel('ORG', 'Organic', '',
                    DateTime(2020, 1, 1).millisecondsSinceEpoch, 'PAID',
                    ['U1']),
              ]));

      await pumpSettings(tester, size: const Size(1440, 900));
      expect(find.text('1 Jan 2020'), findsNWidgets(2));

      await tester.tap(find.byKey(const Key('enrolled_validity_MECH')));
      await tester.pump();

      // The flag used to be shared, so one tap flipped every row.
      expect(find.text('Expired'), findsOneWidget);
      expect(find.text('1 Jan 2020'), findsOneWidget);
    });
  });

  group('the unit picker', () {
    UnitModel _unit(String code, String name) => UnitModel("PHY", "Physics",
        "MECH", "Mechanics", false, code, "", name, "", 1, 0, true, const []);

    testWidgets('selection is an exact match, not a substring',
        (tester) async {
      // Both dialogs did `selection[index].contains(unit.code)` — so a unit
      // coded U1 read as selected whenever its slot held U10.
      final List<UnitModel> units = [_unit('U1', 'One'), _unit('U10', 'Ten')];
      final UnitPickerDialog dialog = UnitPickerDialog(
        title: "Units",
        units: units,
        selection: const ['', 'U10'],
        onToggle: (_) {},
        onToggleAll: () {},
        onSave: () {},
      );

      expect(dialog.isSelected(0), isFalse);
      expect(dialog.isSelected(1), isTrue);
      expect(dialog.selectedCount, 1);
      expect(dialog.allSelected, isFalse);
    });

    testWidgets('an empty subject says so instead of showing a blank box',
        (tester) async {
      tester.view.physicalSize = const Size(900, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: UnitPickerDialog(
            title: "Units",
            units: const [],
            selection: const [],
            onToggle: (_) {},
            onToggleAll: () {},
            onSave: () {},
          ),
        ),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('This subject has no units yet'), findsOneWidget);
      // Nothing to save.
      expect(
          tester
              .widget<ElevatedButton>(find.byKey(const Key('unit_picker_save')))
              .onPressed,
          isNull);
    });

    testWidgets('the dialog fits a small window', (tester) async {
      // It was pinned at 600x600 regardless of the window.
      tester.view.physicalSize = const Size(420, 560);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: UnitPickerDialog(
            title: "Units",
            units: [
              for (int i = 0; i < 12; i++) _unit('U$i', 'Unit number $i'),
            ],
            selection: List<String>.filled(12, ''),
            onToggle: (_) {},
            onToggleAll: () {},
            onSave: () {},
          ),
        ),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('0 of 12 selected'), findsOneWidget);
    });

  // The name and the code are what an admin pastes elsewhere -- into a
  // search box, a spreadsheet, another module's form -- so they render as
  // SelectableLabel rather than plain Text.
  testWidgets('names and codes in the list are selectable', (tester) async {
    await _pump(tester, const Size(1440, 900),
        const Scaffold(body: StudentList()), StudentViewModel(studentRepo: repo));

    final Iterable<SelectableLabel> labels =
        tester.widgetList<SelectableLabel>(find.byType(SelectableLabel));
    expect(labels, isNotEmpty);
    for (final SelectableLabel label in labels) {
      expect(label.data.trim(), isNotEmpty);
    }
    // Drag-select and Ctrl/Cmd-C come from the SelectableText each builds.
    expect(
      find.descendant(
        of: find.byType(SelectableLabel),
        matching: find.byType(SelectableText),
      ),
      findsWidgets,
    );
  });

  });

  group('enrolment', () {
    test('a student with no enrolments reads as null, not a crash', () async {
      // The repo used to take `docs.first` unguarded.
      when(() => repo.getEnrolledCourseList(any()))
          .thenAnswer((_) async => null);

      final vm = StudentViewModel(studentRepo: repo);
      await vm.getEnrolledCourseList('a');

      expect(vm.enrolledCourseBaseModel, isNull);
    });

    test('a course map with no fields yields no units', () {
      final EnrolledCourseModel course =
          EnrolledCourseModel.fromMap(const <String, dynamic>{});
      expect(course.unitCodeList, isEmpty);
      expect(course.subjectCode, stringDefault);
    });
  });
}

/// An enrolment document holding [courses].
///
/// `EnrolledCourseBaseModel` only builds from a Firestore snapshot, which
/// is a sealed type; this reaches the same shape through the map
/// constructor its list is made of.
EnrolledCourseBaseModel _enrolment(List<EnrolledCourseModel> courses) {
  final EnrolledCourseBaseModel model = _StubEnrolment();
  model.enrolledCourseList = courses;
  return model;
}

class _StubEnrolment implements EnrolledCourseBaseModel {
  @override
  String docId = "enrolment-1";
  @override
  String studentId = "a";
  @override
  String studentName = "Anita Desai";
  @override
  List<EnrolledCourseModel> enrolledCourseList = [];
  @override
  Map<String, dynamic> toMap() => {};
}
