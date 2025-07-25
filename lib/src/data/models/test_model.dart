import 'package:flutter/foundation.dart';
import 'package:quick_dot_test/src/core/utils/test_id.dart';
 // Using the TestID from our previous conversation

@immutable
class Test {
  final TestID id; // Using the complex key we defined before
  final String testName;
  final int durationInMinutes;
  final int totalMarks;

  const Test({
    required this.id,
    required this.testName,
    required this.durationInMinutes,
    required this.totalMarks,
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: TestID.fromJson(json['id'] as Map<String, dynamic>),
      testName: json['testName'] as String,
      durationInMinutes: json['durationInMinutes'] as int,
      totalMarks: json['totalMarks'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toJson(),
      'testName': testName,
      'durationInMinutes': durationInMinutes,
      'totalMarks': totalMarks,
    };
  }
}