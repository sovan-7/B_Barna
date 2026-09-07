import 'package:bbarna/resources/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Which bucket a class falls into on the [LiveClassList] tabs. Derived from
/// the class's start/end window against the current time — never stored in
/// Firestore, so it can't go stale.
enum LiveClassStatus { upcoming, live, past }

extension LiveClassStatusLabel on LiveClassStatus {
  String get label {
    switch (this) {
      case LiveClassStatus.upcoming:
        return "Upcoming";
      case LiveClassStatus.live:
        return "Live";
      case LiveClassStatus.past:
        return "Past";
    }
  }
}

class LiveClassModel {
  String docId = stringDefault;
  String title = stringDefault;
  String description = stringDefault;
  String youtubeLink = stringDefault;
  String teacherName = stringDefault;
  DateTime startDateTime;
  DateTime endDateTime;

  /// Written server-side by [LiveClassRepo] with `FieldValue.serverTimestamp()`
  /// — null only for a locally-built model that hasn't round-tripped through
  /// Firestore yet.
  DateTime? createdAt;
  DateTime? updatedAt;

  LiveClassModel({
    required this.docId ,
    required this.title,
    required this.description,
    required this.youtubeLink,
    required this.teacherName,
    required this.startDateTime,
    required this.endDateTime,
    this.createdAt,
    this.updatedAt,
  });

  /// Only the caller-editable fields. `createdAt`/`updatedAt` are owned by
  /// [LiveClassRepo] so the server clock — not the admin's browser — decides
  /// them.
  Map<String, dynamic> toMap() {
    return {
      "title": title.trim(),
      "description": description.trim(),
      "youtubeLink": youtubeLink.trim(),
      "teacherName": teacherName.trim(),
      "startDateTime": Timestamp.fromDate(startDateTime),
      "endDateTime": Timestamp.fromDate(endDateTime),
    };
  }

  LiveClassModel.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc)
      : docId = doc.id,
        title = doc.data()?["title"] ?? stringDefault,
        description = doc.data()?["description"] ?? stringDefault,
        youtubeLink = doc.data()?["youtubeLink"] ?? stringDefault,
        teacherName = doc.data()?["teacherName"] ?? stringDefault,
        startDateTime = _toDateTime(doc.data()?["startDateTime"]) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        endDateTime = _toDateTime(doc.data()?["endDateTime"]) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        createdAt = _toDateTime(doc.data()?["createdAt"]),
        updatedAt = _toDateTime(doc.data()?["updatedAt"]);

  /// Tolerates the three shapes a date can arrive in: a Firestore
  /// [Timestamp] (what we write), an int of millis (what a hand-edited or
  /// legacy doc might hold), or missing/garbage (null).
  static DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  /// Live is inclusive of both edges, so a class is never briefly in no
  /// bucket at all at the exact start/end instant.
  LiveClassStatus statusAt(DateTime now) {
    if (now.isBefore(startDateTime)) return LiveClassStatus.upcoming;
    if (now.isAfter(endDateTime)) return LiveClassStatus.past;
    return LiveClassStatus.live;
  }

  LiveClassStatus get status => statusAt(DateTime.now());
}
