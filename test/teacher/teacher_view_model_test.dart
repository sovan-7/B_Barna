import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/teacher/model/teacher_model.dart';
import 'package:bbarna/teacher/repo/teacher_repo.dart';
import 'package:bbarna/teacher/viewModel/teacher_view_model.dart';

class MockTeacherRepo extends Mock implements TeacherRepo {}

class TeacherModelFake extends Fake implements TeacherModel {}

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
  });

  // addTeacher's success path never touches Helper.showSnackBarMessage or
  // LoaderDialogs (both require a live navigatorKey.currentContext), so it's
  // safely testable with a plain `test()` — no widget pump needed.
  group('addTeacher (success path, plain unit tests)', () {
    test('hashes the password with sha256 before it ever reaches the repo',
        () async {
      when(() => repo.generateStorageKey()).thenReturn('key-1');
      when(() => repo.uploadTeacherImage(any(), any()))
          .thenAnswer((_) async => 'https://example.com/photo.jpg');
      when(() => repo.addTeacher(any())).thenAnswer((_) async {});

      const rawPassword = 'plaintext-password-123';
      await viewModel.addTeacher(
        name: 'Jane Doe',
        username: 'jane_doe',
        password: rawPassword,
        image: Uint8List.fromList([1, 2, 3]),
        moduleAccess: const ['COURSES'],
      );

      final captured =
          verify(() => repo.addTeacher(captureAny())).captured.single
              as TeacherModel;
      expect(captured.password, isNot(equals(rawPassword)));
      expect(captured.password,
          sha256.convert(utf8.encode(rawPassword)).toString());
    });

    test('normalizes username to lowercase before it reaches the repo',
        () async {
      when(() => repo.generateStorageKey()).thenReturn('key-1');
      when(() => repo.uploadTeacherImage(any(), any()))
          .thenAnswer((_) async => 'https://example.com/photo.jpg');
      when(() => repo.addTeacher(any())).thenAnswer((_) async {});

      await viewModel.addTeacher(
        name: 'Jane Doe',
        username: 'Jane_Doe',
        password: 'password123',
        image: Uint8List.fromList([1, 2, 3]),
        moduleAccess: const ['COURSES'],
      );

      final captured =
          verify(() => repo.addTeacher(captureAny())).captured.single
              as TeacherModel;
      expect(captured.username, 'jane_doe');
      expect(captured.docId, 'jane_doe');
    });

    test('uploads the image before creating the Firestore doc (never the reverse)',
        () async {
      when(() => repo.generateStorageKey()).thenReturn('key-1');
      when(() => repo.uploadTeacherImage(any(), any()))
          .thenAnswer((_) async => 'https://example.com/photo.jpg');
      when(() => repo.addTeacher(any())).thenAnswer((_) async {});

      await viewModel.addTeacher(
        name: 'Jane Doe',
        username: 'jane_doe',
        password: 'password123',
        image: Uint8List.fromList([1, 2, 3]),
        moduleAccess: const ['COURSES'],
      );

      verifyInOrder([
        () => repo.uploadTeacherImage(any(), any()),
        () => repo.addTeacher(any()),
      ]);
    });

    test('returns true and includes the uploaded image URL in the model',
        () async {
      when(() => repo.generateStorageKey()).thenReturn('key-1');
      when(() => repo.uploadTeacherImage(any(), any()))
          .thenAnswer((_) async => 'https://example.com/photo.jpg');
      when(() => repo.addTeacher(any())).thenAnswer((_) async {});

      final result = await viewModel.addTeacher(
        name: 'Jane Doe',
        username: 'jane_doe',
        password: 'password123',
        image: Uint8List.fromList([1, 2, 3]),
        moduleAccess: const ['COURSES'],
      );

      expect(result, isTrue);
      final captured =
          verify(() => repo.addTeacher(captureAny())).captured.single
              as TeacherModel;
      expect(captured.imageUrl, 'https://example.com/photo.jpg');
    });

    test('passes the selected moduleAccess through to the persisted model',
        () async {
      when(() => repo.generateStorageKey()).thenReturn('key-1');
      when(() => repo.uploadTeacherImage(any(), any()))
          .thenAnswer((_) async => 'https://example.com/photo.jpg');
      when(() => repo.addTeacher(any())).thenAnswer((_) async {});

      await viewModel.addTeacher(
        name: 'Jane Doe',
        username: 'jane_doe',
        password: 'password123',
        image: Uint8List.fromList([1, 2, 3]),
        moduleAccess: const ['COURSES', 'SUBJECT'],
      );

      final captured =
          verify(() => repo.addTeacher(captureAny())).captured.single
              as TeacherModel;
      expect(captured.moduleAccess, ['COURSES', 'SUBJECT']);
    });
  });

  // Failure paths call Helper.showSnackBarMessage, which needs a real
  // navigatorKey.currentContext — so these are testWidgets, pumping a
  // minimal MaterialApp wired to the app's real navigatorKey.
  group('addTeacher (failure paths, need a live navigator context)', () {
    testWidgets('never creates a Firestore doc if the image upload fails',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(body: SizedBox()),
      ));

      when(() => repo.generateStorageKey()).thenReturn('key-1');
      when(() => repo.uploadTeacherImage(any(), any()))
          .thenThrow(Exception('storage failure'));

      final result = await viewModel.addTeacher(
        name: 'Jane Doe',
        username: 'jane_doe',
        password: 'password123',
        image: Uint8List.fromList([1, 2, 3]),
        moduleAccess: const ['COURSES'],
      );

      expect(result, isFalse);
      verifyNever(() => repo.addTeacher(any()));
    });

    testWidgets('returns false when the username is already taken',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(body: SizedBox()),
      ));

      when(() => repo.generateStorageKey()).thenReturn('key-1');
      when(() => repo.uploadTeacherImage(any(), any()))
          .thenAnswer((_) async => 'https://example.com/photo.jpg');
      when(() => repo.addTeacher(any()))
          .thenThrow(UsernameTakenException('jane_doe'));

      final result = await viewModel.addTeacher(
        name: 'Jane Doe',
        username: 'jane_doe',
        password: 'password123',
        image: Uint8List.fromList([1, 2, 3]),
        moduleAccess: const ['COURSES'],
      );

      expect(result, isFalse);
    });
  });

  group('searchTeacher (plain unit tests, no navigator dependency)', () {
    setUp(() {
      viewModel.teacherList = [
        TeacherModel(
          docId: 'jane_doe',
          name: 'Jane Doe',
          imageUrl: 'x',
          username: 'jane_doe',
          password: 'x',
          timeStamp: 1,
          moduleAccess: const ['COURSES'],
        ),
        TeacherModel(
          docId: 'john_smith',
          name: 'John Smith',
          imageUrl: 'x',
          username: 'john_smith',
          password: 'x',
          timeStamp: 2,
          moduleAccess: const ['SUBJECT'],
        ),
      ];
      viewModel.copyTeacherList = viewModel.teacherList;
    });

    test('filters by name, case-insensitively', () {
      viewModel.searchTeacher(searchText: 'jane');
      expect(viewModel.teacherList, hasLength(1));
      expect(viewModel.teacherList.first.name, 'Jane Doe');
    });

    test('filters by username, case-insensitively', () {
      viewModel.searchTeacher(searchText: 'SMITH');
      expect(viewModel.teacherList, hasLength(1));
      expect(viewModel.teacherList.first.username, 'john_smith');
    });

    test('empty search text restores the full list', () {
      viewModel.searchTeacher(searchText: 'jane');
      viewModel.searchTeacher(searchText: '');
      expect(viewModel.teacherList, hasLength(2));
    });

    test('notifies listeners on search', () {
      var notified = false;
      viewModel.addListener(() => notified = true);
      viewModel.searchTeacher(searchText: 'jane');
      expect(notified, isTrue);
    });
  });
}
