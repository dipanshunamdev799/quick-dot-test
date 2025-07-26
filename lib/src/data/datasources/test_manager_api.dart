import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quick_dot_test/src/core/utils/test_id.dart';
import 'package:quick_dot_test/src/data/models/question_model.dart';

// Custom Exception for API errors
class TestApiException implements Exception {
  final String message;
  TestApiException(this.message);
  @override
  String toString() => message;
}

// Data class for the result of a test submission
class TestSubmissionResult {
  final int marksObtained;
  final int totalMarks;
  TestSubmissionResult({required this.marksObtained, required this.totalMarks});
}

// Data class for the data needed to join a test session
class JoinedTestSessionData {
  final Map<int, Question> questions;
  final TestID testId;
  final Duration duration;
  final Timestamp timestamp;

  JoinedTestSessionData({
    required this.questions,
    required this.testId,
    required this.duration,
    required this.timestamp,
  });
}

/// A singleton class that simulates making API calls to a test management backend.
class TestManagerApi {
  // Singleton setup
  TestManagerApi._();
  static final TestManagerApi instance = TestManagerApi._();

  // Mock server data
  static const String _mockUniqueSessionId = 'QKDT-2025-JULY';
  static final Map<int, Question> _mockQuestions = {
    0: Question(questionText: 'What is the largest mammal?', options: ['Elephant', 'Blue Whale', 'Giraffe', 'Hippo'], correctOptionIndex: 1),
    1: Question(questionText: 'In what year did the Titanic sink?', options: ['1905', '1912', '1918', '1923'], correctOptionIndex: 1),
    2: Question(questionText: 'What is the chemical symbol for gold?', options: ['Ag', 'Go', 'Ge', 'Au'], correctOptionIndex: 3),
  };

  /// API call to generate questions from a PDF.
  Future<List<Question>> generateTestQuestions(int numberOfQuestions, File pdf) async {
    print('API: Generating $numberOfQuestions questions from ${pdf.path}...');
    await Future.delayed(const Duration(seconds: 3)); // Simulate processing
    return _mockQuestions.values.toList();
  }

  /// API call to create a new test session on the server.
  Future<String> createTestSession(Duration duration, Map<int, Question> questions, Timestamp timestamp) async {
    print('API: Creating test session with ${questions.length} questions...');
    await Future.delayed(const Duration(seconds: 1));
    return _mockUniqueSessionId; // Return the unique ID from the server
  }

  /// API call to join an existing test session.
  Future<JoinedTestSessionData> joinTestSession(String uniqueSessionId) async {
    print('API: Attempting to join session with ID: $uniqueSessionId');
    await Future.delayed(const Duration(seconds: 2));

    if (uniqueSessionId == _mockUniqueSessionId) {
      final testTimestamp = Timestamp.fromDate(DateTime(2025, 7, 26, 0, 5));
      return JoinedTestSessionData(
        questions: _mockQuestions,
        testId: TestID(testCreatorId: 'server-admin', testTimeStamp: testTimestamp),
        duration: const Duration(minutes: 2000000),
        timestamp: testTimestamp,
      );
    } else {
      throw TestApiException('Invalid Session ID. Please check the ID and try again.');
    }
  }

  /// API call to submit a user's answers.
  Future<TestSubmissionResult> submitTest(TestID testId, Map<int, int> answers) async {
    print('API: Submitting answers for test: ${testId.toJson()}');
    print('API: User answers: $answers');
    await Future.delayed(const Duration(seconds: 1));

    // Simulate calculating the score on the server
    int score = 0;
    answers.forEach((questionIndex, selectedOptionIndex) {
      if (_mockQuestions.containsKey(questionIndex) && _mockQuestions[questionIndex]!.correctOptionIndex == selectedOptionIndex) {
        score += 10; // 10 marks per correct answer
      }
    });

    return TestSubmissionResult(marksObtained: score, totalMarks: _mockQuestions.length * 10);
  }
}