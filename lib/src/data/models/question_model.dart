import 'package:flutter/foundation.dart';

@immutable
class Question {
  final String questionText;
  final List<String> options;
  // The correct option index should NOT be sent to the student taking the test.
  // It's included here for model completeness but would be omitted from the API response for students.
  final int correctOptionIndex;

  const Question({
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionText: json['questionText'] as String,
      options: List<String>.from(json['options'] as List),
      // Handle cases where the correct answer isn't sent from the API
      correctOptionIndex: json['correctOptionIndex'] as int? ?? -1,
    );
  }
}