import 'package:flutter/foundation.dart';
import 'package:quick_dot_test/src/core/utils/test_id.dart';

@immutable
class SubmissionModel {
  final String userId;
  final TestID testId;
  // Map of qustion index to the index of the option selected by the user.
  final Map<int, int> answers;
  final int marksObtained;

  const SubmissionModel({
    required this.userId,
    required this.testId,
    required this.answers,
    required this.marksObtained,
  });

  // This model is primarily for sending data to the server or receiving results.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'testId': testId.toJson(),
      'answers': answers,
    };
  }

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      userId: json['userId'] as String,
      testId: TestID.fromJson(json['testId'] as Map<String, dynamic>),
      answers: Map<int, int>.from(json['answers'] as Map),
      marksObtained: json['marksObtained'] as int,
    );
  }
}