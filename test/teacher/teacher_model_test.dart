import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bbarna/teacher/model/teacher_model.dart';

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('TeacherModel', () {
    test('toMap() produces the expected Firestore field map', () {
      final model = TeacherModel(
        docId: 'jane_doe',
        name: 'Jane Doe',
        imageUrl: 'https://example.com/jane.jpg',
        username: 'jane_doe',
        password: 'hashed-password-value',
        timeStamp: 1700000000000,
        moduleAccess: const ['COURSES', 'SUBJECT'],
      );

      expect(model.toMap(), {
        'name': 'Jane Doe',
        'image_url': 'https://example.com/jane.jpg',
        'username': 'jane_doe',
        'password': 'hashed-password-value',
        'timeStamp': 1700000000000,
        'module_access': ['COURSES', 'SUBJECT'],
      });
    });

    test('fromDocumentSnapshot() parses a Firestore document correctly', () {
      final snapshot = MockDocumentSnapshot();
      when(() => snapshot.id).thenReturn('jane_doe');
      when(() => snapshot.data()).thenReturn({
        'name': 'Jane Doe',
        'image_url': 'https://example.com/jane.jpg',
        'username': 'jane_doe',
        'password': 'hashed-password-value',
        'timeStamp': 1700000000000,
        'module_access': ['COURSES', 'SUBJECT'],
      });

      final model = TeacherModel.fromDocumentSnapshot(snapshot);

      expect(model.docId, 'jane_doe');
      expect(model.name, 'Jane Doe');
      expect(model.imageUrl, 'https://example.com/jane.jpg');
      expect(model.username, 'jane_doe');
      expect(model.password, 'hashed-password-value');
      expect(model.timeStamp, 1700000000000);
      expect(model.moduleAccess, ['COURSES', 'SUBJECT']);
    });

    test(
        'fromDocumentSnapshot() falls back to codebase defaults for missing fields',
        () {
      final snapshot = MockDocumentSnapshot();
      when(() => snapshot.id).thenReturn('incomplete');
      when(() => snapshot.data()).thenReturn({
        'name': 'Incomplete Teacher',
      });

      final model = TeacherModel.fromDocumentSnapshot(snapshot);

      expect(model.name, 'Incomplete Teacher');
      expect(model.imageUrl, 'NA'); // stringDefault, from lib/resources/constant.dart
      expect(model.username, 'NA'); // stringDefault
      expect(model.password, 'NA'); // stringDefault
      expect(model.timeStamp, -1); // intDefault
      expect(model.moduleAccess, isEmpty);
    });
  });
}
