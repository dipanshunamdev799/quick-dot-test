import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Timestamp

@immutable
class TestID {
  final String testCreatorId;
  final Timestamp testTimeStamp;

  const TestID({
    required this.testCreatorId,
    required this.testTimeStamp,
  });

  /// Converts this instance to a Map for sending to an API.
  Map<String, dynamic> toJson() {
    return {
      'testCreatorId': testCreatorId,
      // FIX: Convert Timestamp to DateTime first, then to a string.
      'testTimeStamp': testTimeStamp.toDate().toIso8601String(),
    };
  }

  /// Creates an instance from a Map (e.g., JSON from an API).
  factory TestID.fromJson(Map<String, dynamic> json) {
    return TestID(
      testCreatorId: json['testCreatorId'] as String,
      // FIX: Parse the string to DateTime, then convert it to a Timestamp.
      testTimeStamp: Timestamp.fromDate(DateTime.parse(json['testTimeStamp'] as String)),
    );
  }
}