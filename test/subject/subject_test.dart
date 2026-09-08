import 'dart:typed_data';

import 'package:bbarna/course/model/course_model.dart';
import 'package:bbarna/course/repo/course_repo.dart';
import 'package:bbarna/course/viewModel/course_view_model.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/subject/model/subject_model.dart';
import 'package:bbarna/subject/repo/subject_repo.dart';
import 'package:bbarna/subject/screen/add_subject.dart';
import 'package:bbarna/subject/screen/edit_subject.dart';
import 'package:bbarna/subject/screen/subject_list.dart';
import 'package:bbarna/subject/viewModel/subject_view_model.dart';
import 'package:bbarna/subject/widgets/subject_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockSubjectRepo extends Mock implements SubjectRepo {}

class MockCourseRepo extends Mock implements CourseRepo {}

class SubjectModelFake extends Fake implements SubjectModel {}

SubjectModel _subject(
  String id,
  String code,
  String name, {
  String courseName = "Physics — Class 11",
  String courseType = "Full Course",
  double price = 1000,
  double sellingPrice = 750,
  int priority = 1,
  int timeStamp = 0,
  bool willDisplay = true,
  bool isLocked = false,
  bool isPopular = false,
}) {
  final SubjectModel model = SubjectModel(
      "PHY-11",
      courseType,
      courseName,
      price,
      sellingPrice,
      code,
      "A description.",
      name,
      "",
      priority,
      timeStamp,
      willDisplay,
      isLocked,
      isPopular);
  model.docId = id;
  return model;
}

List<SubjectModel> _fixture() => [
      _subject('a', 'MECH', 'Mechanics', timeStamp: 300),
      _subject('b', 'ORG', 'Organic Chemistry',
          courseName: "Chemistry — Class 12",
          timeStamp: 200,
          isLocked: true,
          sellingPrice: 1000),
      _subject(
          'c',
          'TRIG',
          'An extremely long subject name that will certainly not fit on one '
              'line of any card at any breakpoint whatsoever',
          timeStamp: 100,
          willDisplay: false,
          isPopular: true),
    ];

CourseModel _course(String code, String name) {
  final CourseModel model =
      CourseModel(code, "", name, "", 1, 0, true, false);
  model.docId = code;
  return model;
}

const List<Size> _sizes = [
  Size(1440, 900),
  Size(1024, 768),
  Size(700, 900),
  Size(380, 820),
];

late MockSubjectRepo repo;
late MockCourseRepo courseRepo;

Future<void> _pump(WidgetTester tester, Size size, Widget home,
    SubjectViewModel vm) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider<SubjectViewModel>.value(value: vm),
      ChangeNotifierProvider<CourseViewModel>(
          create: (_) => CourseViewModel(courseRepo: courseRepo)),
    ],
    child: MaterialApp(navigatorKey: navigatorKey, home: home),
  ));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUpAll(() {
    registerFallbackValue(SubjectModelFake());
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    repo = MockSubjectRepo();
    courseRepo = MockCourseRepo();
    when(() => repo.getSubjectList()).thenAnswer((_) async => _fixture());
    when(() => courseRepo.getCourseList()).thenAnswer((_) async => [
          _course('PHY-11', 'Physics — Class 11'),
          _course('CHEM-12', 'Chemistry — Class 12'),
        ]);
  });

  group('layout', () {
    for (final Size size in _sizes) {
      testWidgets('the list lays out at ${size.width.toInt()}', (tester) async {
        final vm = SubjectViewModel(subjectRepo: repo);
        await _pump(tester, size, const Scaffold(body: SubjectList()), vm);

        expect(tester.takeException(), isNull);
        expect(find.text('Subjects'), findsOneWidget);
        expect(find.byType(SubjectCard), findsNWidgets(3));
      });

      testWidgets('the add form lays out at ${size.width.toInt()}',
          (tester) async {
        final vm = SubjectViewModel(subjectRepo: repo);
        await _pump(tester, size, const AddSubject(), vm);

        expect(tester.takeException(), isNull);
        expect(find.text('Add a subject'), findsOneWidget);
      });

      testWidgets('the edit form lays out at ${size.width.toInt()}',
          (tester) async {
        final vm = SubjectViewModel(subjectRepo: repo);
        await _pump(
            tester, size, EditSubject(subjectData: _fixture().first), vm);

        expect(tester.takeException(), isNull);
        expect(find.text('Edit subject'), findsOneWidget);
      });
    }
  });

  group('the list', () {
    testWidgets('is newest first', (tester) async {
      final vm = SubjectViewModel(subjectRepo: repo);
      await _pump(tester, const Size(1440, 900),
          const Scaffold(body: SubjectList()), vm);

      expect(vm.subjectList.map((s) => s.docId).toList(), ['a', 'b', 'c']);
    });

    testWidgets('search matches subject, code or course name',
        (tester) async {
      final vm = SubjectViewModel(subjectRepo: repo);
      await _pump(tester, const Size(1440, 900),
          const Scaffold(body: SubjectList()), vm);

      // By course — the old search only looked at code and name.
      await tester.enterText(find.byType(TextField).first, 'chemistry');
      await tester.pump();
      expect(find.byType(SubjectCard), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'trig');
      await tester.pump();
      expect(find.byType(SubjectCard), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '');
      await tester.pump();
      expect(find.byType(SubjectCard), findsNWidgets(3));
    });

    testWidgets('an empty result says which kind of empty it is',
        (tester) async {
      when(() => repo.getSubjectList()).thenAnswer((_) async => []);
      final vm = SubjectViewModel(subjectRepo: repo);
      await _pump(tester, const Size(1024, 768),
          const Scaffold(body: SubjectList()), vm);

      expect(find.text('No subjects yet'), findsOneWidget);
      expect(find.text('Add a subject'), findsOneWidget);
    });

    testWidgets('mounting mid-build does not throw', (tester) async {
      final vm = SubjectViewModel(subjectRepo: repo);
      await _pump(tester, const Size(1024, 768),
          const Scaffold(body: SubjectList()), vm);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a discounted subject shows what students pay',
        (tester) async {
      final vm = SubjectViewModel(subjectRepo: repo);
      await _pump(tester, const Size(1440, 900),
          const Scaffold(body: SubjectList()), vm);

      // 750 selling against 1000 list. The card used to show only the
      // list price — the number nobody is charged.
      expect(find.text('₹750.00'), findsWidgets);
      expect(find.text('₹1000.00'), findsWidgets);
      expect(find.text('-25%'), findsWidgets);
    });
  });

  group('the flag toggles', () {
    testWidgets('lock goes through the repo and updates in place',
        (tester) async {
      when(() => repo.setSubjectFlag(any(), any(), any()))
          .thenAnswer((_) async {});

      final vm = SubjectViewModel(subjectRepo: repo);
      await _pump(tester, const Size(1440, 900),
          const Scaffold(body: SubjectList()), vm);
      clearInteractions(repo);

      await tester.tap(find.byKey(const Key('subject_lock_a')));
      await tester.pump();
      await tester.pump();

      // It used to call FirebaseFirestore.instance straight from the widget
      // and then refetch the whole list to flip one boolean.
      verify(() => repo.setSubjectFlag('a', 'isLocked', true)).called(1);
      expect(vm.subjectList.firstWhere((s) => s.docId == 'a').isLocked, isTrue);
      verifyNever(() => repo.getSubjectList());
    });

    testWidgets('popular goes through the repo too', (tester) async {
      when(() => repo.setSubjectFlag(any(), any(), any()))
          .thenAnswer((_) async {});

      final vm = SubjectViewModel(subjectRepo: repo);
      await _pump(tester, const Size(1440, 900),
          const Scaffold(body: SubjectList()), vm);
      clearInteractions(repo);

      await tester.tap(find.byKey(const Key('subject_popular_a')));
      await tester.pump();
      await tester.pump();

      verify(() => repo.setSubjectFlag('a', 'isPopular', true)).called(1);
      expect(
          vm.subjectList.firstWhere((s) => s.docId == 'a').isPopular, isTrue);
    });
  });

  group('createSubject keeps the collection clean', () {
    Future<void> withNavigator(WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(body: SizedBox()),
      ));
    }

    test('uploads against the new document id', () async {
      when(() => repo.addSubject(any())).thenAnswer((_) async => 'new-id');
      when(() => repo.uploadSubjectImage(any(), any()))
          .thenAnswer((_) async {});

      final vm = SubjectViewModel(subjectRepo: repo);
      final Uint8List bytes = Uint8List.fromList([1, 2, 3]);
      expect(await vm.createSubject(_subject('', 'MECH', 'Mechanics'), bytes),
          isTrue);

      // Keyed by document id, not subject code — two subjects sharing a
      // code used to overwrite each other's image in storage.
      verify(() => repo.uploadSubjectImage(bytes, 'new-id')).called(1);
    });

    testWidgets('a failed upload takes the empty document with it',
        (tester) async {
      when(() => repo.addSubject(any())).thenAnswer((_) async => 'new-id');
      when(() => repo.uploadSubjectImage(any(), any()))
          .thenThrow(Exception('storage down'));
      when(() => repo.deleteSubject(any())).thenAnswer((_) async {});
      await withNavigator(tester);

      final vm = SubjectViewModel(subjectRepo: repo);
      expect(
          await vm.createSubject(
              _subject('', 'MECH', 'Mechanics'), Uint8List.fromList([1])),
          isFalse);

      verify(() => repo.deleteSubject('new-id')).called(1);
    });
  });

  group('updateSubject', () {
    test('leaves the existing image alone when none was picked', () async {
      when(() => repo.updateSubject(any(), any())).thenAnswer((_) async {});

      final vm = SubjectViewModel(subjectRepo: repo);
      expect(
          await vm.updateSubject(_subject('a', 'MECH', 'Mechanics'), 'a'),
          isTrue);

      verifyNever(() => repo.uploadSubjectImage(any(), any()));
    });
  });

  group('the form', () {
    testWidgets('an invalid submit marks every offending field',
        (tester) async {
      final vm = SubjectViewModel(subjectRepo: repo);
      await _pump(tester, const Size(1024, 900), const AddSubject(), vm);

      await tester.tap(find.byKey(const Key('subject_save_button')));
      await tester.pump();

      // The old form reported one problem at a time, by snackbar only.
      expect(find.text('Choose the course this belongs to'), findsOneWidget);
      expect(find.text('Choose a course type'), findsOneWidget);
      expect(find.text('Give the subject a code'), findsOneWidget);
      expect(find.text('Give the subject a name'), findsOneWidget);
      expect(find.text('Set a display priority'), findsOneWidget);
      expect(find.text('Set a price'), findsOneWidget);
      expect(find.text('Choose a subject image'), findsOneWidget);
      verifyNever(() => repo.addSubject(any()));
    });

    testWidgets('a selling price above the price is rejected',
        (tester) async {
      final vm = SubjectViewModel(subjectRepo: repo);
      await _pump(tester, const Size(1024, 900),
          EditSubject(subjectData: _fixture().first), vm);

      final Finder priceFields = find.byType(TextField);
      // Price is the 5th field: code, name, description, priority, price,
      // selling price — ordered by the form's own layout.
      await tester.enterText(priceFields.at(4), '100');
      await tester.enterText(priceFields.at(5), '500');
      await tester.pump();

      await tester.tap(find.byKey(const Key('subject_save_button')));
      await tester.pump();

      expect(find.text('Cannot be more than the price'), findsOneWidget);
      verifyNever(() => repo.updateSubject(any(), any()));
    });

    testWidgets('editing does not demand a new image', (tester) async {
      when(() => repo.updateSubject(any(), any())).thenAnswer((_) async {});
      final vm = SubjectViewModel(subjectRepo: repo);
      await _pump(tester, const Size(1024, 900),
          EditSubject(subjectData: _fixture().first), vm);

      await tester.tap(find.byKey(const Key('subject_save_button')));
      await tester.pump();
      await tester.pump();

      expect(find.text('Choose a subject image'), findsNothing);
      verify(() => repo.updateSubject(any(), 'a')).called(1);
    });

    testWidgets('a course that no longer exists stays selectable',
        (tester) async {
      when(() => courseRepo.getCourseList()).thenAnswer((_) async => []);
      final vm = SubjectViewModel(subjectRepo: repo);
      await _pump(tester, const Size(1024, 900),
          EditSubject(subjectData: _fixture().first), vm);

      // Editing must not silently drop the course a subject already names.
      expect(find.text('Physics — Class 11'), findsWidgets);
    });
  });
}
