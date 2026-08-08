import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/teacher/model/teacher_model.dart';
import 'package:bbarna/teacher/repo/teacher_repo.dart';
import 'package:bbarna/teacher/screen/add_teacher.dart';
import 'package:bbarna/teacher/viewModel/teacher_view_model.dart';

class MockTeacherRepo extends Mock implements TeacherRepo {}

class TeacherModelFake extends Fake implements TeacherModel {}

Future<void> pumpAddTeacher(
    WidgetTester tester, TeacherViewModel viewModel) async {
  tester.view.physicalSize = const Size(1400, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ChangeNotifierProvider<TeacherViewModel>.value(
      value: viewModel,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        home: const AddTeacher(),
      ),
    ),
  );
}

/// Selects an image via the widget's own ChooseImage flow isn't feasible in
/// a widget test (file_picker shows a native OS dialog). AddTeacher exposes
/// its selected-image state through its State for exactly this reason —
/// tests reach in via the State object rather than driving a real file
/// picker, which is untestable in this environment.
// A real, minimal 1x1 transparent PNG — MemoryImage eagerly decodes whatever
// bytes it's given, so garbage bytes would throw an unrelated image-codec
// error and mask the actual validation assertions below.
final Uint8List _validPngBytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=');

void selectFakeImage(WidgetTester tester,
    {String name = 'photo.png', int size = 1024}) {
  final state = tester.state<AddTeacherTestHooks>(find.byType(AddTeacher));
  state.setSelectedImageForTest(
    PlatformFile(name: name, size: size, bytes: _validPngBytes),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(TeacherModelFake());
    registerFallbackValue(Uint8List(0));
  });

  late MockTeacherRepo repo;
  late TeacherViewModel viewModel;

  setUp(() {
    repo = MockTeacherRepo();
    viewModel = TeacherViewModel(teacherRepo: repo);
    when(() => repo.generateStorageKey()).thenReturn('key-1');
    when(() => repo.uploadTeacherImage(any(), any()))
        .thenAnswer((_) async => 'https://example.com/photo.jpg');
    when(() => repo.addTeacher(any())).thenAnswer((_) async {});
  });

  testWidgets('blocks submission when name is empty', (tester) async {
    await pumpAddTeacher(tester, viewModel);
    selectFakeImage(tester);
    await tester.enterText(find.byKey(const Key('teacher_username_field')), 'jane_doe');
    await tester.enterText(find.byKey(const Key('teacher_password_field')), 'password123');
    await tester.tap(find.byKey(const Key('teacher_save_button')));
    await tester.pumpAndSettle();

    verifyNever(() => repo.addTeacher(any()));
  });

  testWidgets('blocks submission when username is shorter than 4 chars',
      (tester) async {
    await pumpAddTeacher(tester, viewModel);
    selectFakeImage(tester);
    await tester.enterText(find.byKey(const Key('teacher_name_field')), 'Jane Doe');
    await tester.enterText(find.byKey(const Key('teacher_username_field')), 'jd');
    await tester.enterText(find.byKey(const Key('teacher_password_field')), 'password123');
    await tester.tap(find.byKey(const Key('teacher_save_button')));
    await tester.pumpAndSettle();

    verifyNever(() => repo.addTeacher(any()));
  });

  testWidgets('blocks submission when username has non-alphanumeric characters',
      (tester) async {
    await pumpAddTeacher(tester, viewModel);
    selectFakeImage(tester);
    await tester.enterText(find.byKey(const Key('teacher_name_field')), 'Jane Doe');
    await tester.enterText(find.byKey(const Key('teacher_username_field')), 'jane doe!');
    await tester.enterText(find.byKey(const Key('teacher_password_field')), 'password123');
    await tester.tap(find.byKey(const Key('teacher_save_button')));
    await tester.pumpAndSettle();

    verifyNever(() => repo.addTeacher(any()));
  });

  testWidgets('blocks submission when password is shorter than 8 chars',
      (tester) async {
    await pumpAddTeacher(tester, viewModel);
    selectFakeImage(tester);
    await tester.enterText(find.byKey(const Key('teacher_name_field')), 'Jane Doe');
    await tester.enterText(find.byKey(const Key('teacher_username_field')), 'jane_doe');
    await tester.enterText(find.byKey(const Key('teacher_password_field')), 'short1');
    await tester.tap(find.byKey(const Key('teacher_save_button')));
    await tester.pumpAndSettle();

    verifyNever(() => repo.addTeacher(any()));
  });

  testWidgets(
      'accepts an 8+ char letters-only password — letters+numbers is guidance, not a hard rule',
      (tester) async {
    await pumpAddTeacher(tester, viewModel);
    selectFakeImage(tester);
    await tester.enterText(find.byKey(const Key('teacher_name_field')), 'Jane Doe');
    await tester.enterText(find.byKey(const Key('teacher_username_field')), 'jane_doe');
    await tester.enterText(find.byKey(const Key('teacher_password_field')), 'abcdefgh');
    await tester.tap(find.byKey(const Key('teacher_save_button')));
    await tester.pumpAndSettle();

    verify(() => repo.addTeacher(any())).called(1);
  });

  testWidgets(
      'accepts an 8+ char digits-only password — letters+numbers is guidance, not a hard rule',
      (tester) async {
    await pumpAddTeacher(tester, viewModel);
    selectFakeImage(tester);
    await tester.enterText(find.byKey(const Key('teacher_name_field')), 'Jane Doe');
    await tester.enterText(find.byKey(const Key('teacher_username_field')), 'jane_doe');
    await tester.enterText(find.byKey(const Key('teacher_password_field')), '12345678');
    await tester.tap(find.byKey(const Key('teacher_save_button')));
    await tester.pumpAndSettle();

    verify(() => repo.addTeacher(any())).called(1);
  });

  testWidgets('blocks submission when no image was selected', (tester) async {
    await pumpAddTeacher(tester, viewModel);
    await tester.enterText(find.byKey(const Key('teacher_name_field')), 'Jane Doe');
    await tester.enterText(find.byKey(const Key('teacher_username_field')), 'jane_doe');
    await tester.enterText(find.byKey(const Key('teacher_password_field')), 'password123');
    await tester.tap(find.byKey(const Key('teacher_save_button')));
    await tester.pumpAndSettle();

    verifyNever(() => repo.addTeacher(any()));
  });

  testWidgets('blocks submission when the image is not jpg/jpeg/png',
      (tester) async {
    await pumpAddTeacher(tester, viewModel);
    selectFakeImage(tester, name: 'photo.gif');
    await tester.enterText(find.byKey(const Key('teacher_name_field')), 'Jane Doe');
    await tester.enterText(find.byKey(const Key('teacher_username_field')), 'jane_doe');
    await tester.enterText(find.byKey(const Key('teacher_password_field')), 'password123');
    await tester.tap(find.byKey(const Key('teacher_save_button')));
    await tester.pumpAndSettle();

    verifyNever(() => repo.addTeacher(any()));
  });

  testWidgets('blocks submission when the image is larger than 5MB',
      (tester) async {
    await pumpAddTeacher(tester, viewModel);
    selectFakeImage(tester, size: 6 * 1024 * 1024);
    await tester.enterText(find.byKey(const Key('teacher_name_field')), 'Jane Doe');
    await tester.enterText(find.byKey(const Key('teacher_username_field')), 'jane_doe');
    await tester.enterText(find.byKey(const Key('teacher_password_field')), 'password123');
    await tester.tap(find.byKey(const Key('teacher_save_button')));
    await tester.pumpAndSettle();

    verifyNever(() => repo.addTeacher(any()));
  });

  testWidgets('submits successfully when every field is valid', (tester) async {
    await pumpAddTeacher(tester, viewModel);
    selectFakeImage(tester);
    await tester.enterText(find.byKey(const Key('teacher_name_field')), 'Jane Doe');
    await tester.enterText(find.byKey(const Key('teacher_username_field')), 'jane_doe');
    await tester.enterText(find.byKey(const Key('teacher_password_field')), 'password123');
    await tester.tap(find.byKey(const Key('teacher_save_button')));
    await tester.pumpAndSettle();

    verify(() => repo.addTeacher(any())).called(1);
  });
}
