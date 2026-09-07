import 'package:bbarna/live_class/model/live_class_model.dart';
import 'package:bbarna/live_class/repo/live_class_repo.dart';
import 'package:bbarna/live_class/screen/add_live_class.dart';
import 'package:bbarna/live_class/screen/edit_live_class.dart';
import 'package:bbarna/live_class/screen/live_class_list.dart';
import 'package:bbarna/live_class/viewModel/live_class_view_model.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockLiveClassRepo extends Mock implements LiveClassRepo {}

class LiveClassModelFake extends Fake implements LiveClassModel {}

LiveClassModel _model(String id, String title, DateTime start,
        {String teacher = "Ravi Kumar"}) =>
    LiveClassModel(
      docId: id,
      title: title,
      description:
          "A long description that has to wrap and then be clamped, because "
          "admins paste whole lesson plans into this field.",
      youtubeLink: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      teacherName: teacher,
      startDateTime: start,
      endDateTime: start.add(const Duration(minutes: 90)),
    );

/// One of each bucket, plus the awkward content that breaks layouts: a very
/// long title and a very long teacher name.
List<LiveClassModel> _fixture() {
  final DateTime now = DateTime.now();
  return [
    _model('live', "Trigonometry — Chapter 4 revision",
        now.subtract(const Duration(minutes: 20))),
    _model('up1', "Organic Chemistry: nomenclature drill",
        now.add(const Duration(days: 1))),
    _model(
        'up2',
        "An extremely long class title that will certainly not fit on a "
            "single line of any card at any breakpoint whatsoever",
        now.add(const Duration(days: 3)),
        teacher: "Dr. Subramanian Venkataraghavan Iyer"),
    _model('past', "Algebra recap", now.subtract(const Duration(days: 4))),
  ];
}

/// Widths worth checking: a wide desktop, a laptop, the point the toolbar
/// stacks, and a phone.
const List<Size> _sizes = [
  Size(1440, 900),
  Size(1024, 768),
  Size(700, 900),
  Size(380, 820),
];

Future<void> _pump(WidgetTester tester, Size size, Widget home,
    LiveClassViewModel vm) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(ChangeNotifierProvider<LiveClassViewModel>.value(
    value: vm,
    child: MaterialApp(navigatorKey: navigatorKey, home: home),
  ));
  // pump, not pumpAndSettle: the LIVE badge's dot pulses forever, so there
  // is no settled state to wait for whenever a live class is on screen.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  setUpAll(() => registerFallbackValue(LiveClassModelFake()));

  late MockLiveClassRepo repo;

  setUp(() {
    repo = MockLiveClassRepo();
    when(() => repo.getLiveClassList()).thenAnswer((_) async => _fixture());
    when(() => repo.getTeacherNames())
        .thenAnswer((_) async => ['Ravi Kumar', 'Anita Desai']);
  });

  for (final Size size in _sizes) {
    testWidgets('list lays out at ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
      final vm = LiveClassViewModel(liveClassRepo: repo);
      await _pump(tester, size, const Scaffold(body: LiveClassList()), vm);

      expect(tester.takeException(), isNull);
      expect(find.text('Live Classes'), findsOneWidget);
      // Upcoming is the default tab and the fixture puts two classes in it.
      expect(find.text('Organic Chemistry: nomenclature drill'), findsOneWidget);
    });

    testWidgets('add form lays out at ${size.width.toInt()}', (tester) async {
      final vm = LiveClassViewModel(liveClassRepo: repo);
      await _pump(tester, size, const AddLiveClass(), vm);

      expect(tester.takeException(), isNull);
      expect(find.text('Schedule a class'), findsOneWidget);
      expect(find.byKey(const Key('live_class_save_button')), findsOneWidget);
    });

    testWidgets('edit form lays out at ${size.width.toInt()}', (tester) async {
      final vm = LiveClassViewModel(liveClassRepo: repo);
      await _pump(
        tester,
        size,
        EditLiveClass(liveClassData: _fixture().first),
        vm,
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Edit class'), findsOneWidget);
    });
  }

  testWidgets('each tab renders its own bucket', (tester) async {
    final vm = LiveClassViewModel(liveClassRepo: repo);
    await _pump(tester, const Size(1440, 900),
        const Scaffold(body: LiveClassList()), vm);

    await tester.tap(find.byKey(const Key('live_class_tab_live')));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Trigonometry — Chapter 4 revision'), findsOneWidget);

    await tester.tap(find.byKey(const Key('live_class_tab_past')));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Algebra recap'), findsOneWidget);
  });

  testWidgets('an empty bucket offers a way out', (tester) async {
    when(() => repo.getLiveClassList()).thenAnswer((_) async => []);
    final vm = LiveClassViewModel(liveClassRepo: repo);
    await _pump(tester, const Size(1440, 900),
        const Scaffold(body: LiveClassList()), vm);

    expect(tester.takeException(), isNull);
    expect(find.text('Nothing scheduled yet'), findsOneWidget);
    expect(find.text('Schedule a class'), findsOneWidget);

    // Past is a filing bucket, not something you can act on — no CTA there.
    await tester.tap(find.byKey(const Key('live_class_tab_past')));
    await tester.pump();
    expect(find.text('No finished classes'), findsOneWidget);
    expect(find.text('Schedule a class'), findsNothing);
  });

  testWidgets('an invalid submit marks the offending fields', (tester) async {
    final vm = LiveClassViewModel(liveClassRepo: repo);
    await _pump(tester, const Size(1024, 768), const AddLiveClass(), vm);

    await tester.tap(find.byKey(const Key('live_class_save_button')));
    await tester.pump();

    expect(find.text('Give the class a title'), findsOneWidget);
    expect(find.text('Pick when the class starts'), findsOneWidget);
    expect(find.text('Pick when the class ends'), findsOneWidget);
    verifyNever(() => repo.addLiveClass(any()));

    // Fixing one field clears just that message.
    await tester.enterText(
        find.byType(TextField).first, "Integration by parts");
    await tester.pump();
    expect(find.text('Give the class a title'), findsNothing);
    expect(find.text('Pick when the class starts'), findsOneWidget);
  });
}
