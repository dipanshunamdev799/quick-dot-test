import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quick_dot_test/src/core/utils/test_id.dart';
import 'package:quick_dot_test/src/data/datasources/test_manager_api.dart';
import 'package:quick_dot_test/src/data/models/question_model.dart';

/// A singleton class to manage test creation, joining, and submission logic.
/// This acts as a bridge between the UI and the data sources.
class TestSessionManager {
  // Singleton setup
  TestSessionManager._();
  static final TestSessionManager instance = TestSessionManager._();

  // Instance of the data source
  final TestManagerApi _api = TestManagerApi.instance;

  /// Generates a list of questions based on a provided PDF document.
  Future<List<Question>> generateTestQuestions(int numberOfQuestions, File pdf) async {
    try {
      return await _api.generateTestQuestions(numberOfQuestions, pdf);
    } catch (e) {
      // Handle or re-throw exceptions
      print('Error in generateTestQuestions: $e');
      rethrow;
    }
  }

  /// Creates a test session with the given parameters and returns a unique session ID.
  Future<String> createTestSession({
    required Duration duration,
    required Map<int, Question> questions,
    required Timestamp timestamp,
  }) async {
    try {
      return await _api.createTestSession(duration, questions, timestamp);
    } catch (e) {
      print('Error in createTestSession: $e');
      rethrow;
    }
  }

  /// Allows a user to join an existing test session using its unique ID.
  Future<JoinedTestSessionData> joinTestSession(String uniqueSessionId) async {
    try {
      return await _api.joinTestSession(uniqueSessionId);
    } catch (e) {
      print('Error in joinTestSession: $e');
      rethrow;
    }
  }

  /// Submits the user's answers for a given test and returns the result.
  Future<TestSubmissionResult> submitTest({
    required TestID testId,
    required Map<int, int> answers,
  }) async {
    try {
      return await _api.submitTest(testId, answers);
    } catch (e) {
      print('Error in submitTest: $e');
      rethrow;
    }
  }
}